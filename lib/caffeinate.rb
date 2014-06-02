require 'mechanize'
require 'caffeinate/version'
require 'caffeinate/starbuck'

module Caffeinate
  class Caffeinate
    attr_accessor :session, :userEmail, :userPassword

    def initialize(params = {})
      @userEmail      = params[:userEmail]
      @userPassword   = params[:userPassword] 
    
      @senderName     = params[:senderName]
      @senderEmail    = params[:senderEmail]

      @recipientName  = params[:recipientName]
      @recipientEmail = params[:recipientEmail]
      @message        = params[:message]
      @amount         = params[:amount]    
      @cardTheme      = params[:cardTheme] # currently only supports anytime cards

      @paymentMethod  = params[:paymentMethod]
      @cvn            = params[:cvn]

      @dev            = params[:dev]

      @session = nil
    end  

    def send_egift 
      a = Mechanize.new 

      a.get(SITE_URL) do |page|
        check_required_fields_are_set
        authenticate a, page
        add_egift_to_shopping_cart a, page
        select_and_confirm_payment_method
        purchase_egift a
      end
    end

    private

    def check_required_fields_are_set
      puts 'Checking if all required fields are set.' if @dev
      if @userEmail.nil?
        raise 'User Email is not set.'
      elsif @userPassword.nil?
        raise 'User Password is not set.'
      elsif @senderName.nil?
        raise 'Sender Name is not set.'
      elsif @senderEmail.nil?
        raise 'Sender Email is not set.'
      elsif @recipientName.nil?
        raise 'Recipient Name is not set.'
      elsif @recipientEmail.nil?
        raise 'Recipient Email is not set.'
      elsif @message.nil?
        raise 'Message is not set.'
      elsif @amount.nil? 
        raise 'Message is not set.'
      elsif @cardTheme.nil?
        raise 'Card theme is not set.'
      elsif @paymentMethod.nil?
        raise 'Payment Method is not set'
      end
    end

    # Authentication
    def authenticate(a, page)
      puts 'Authenticating account.' if @dev
      sign_in a, page
      raise "Unable to login." if @session.nil?
    end

    def sign_in(a, page)
      @session  = a.click(page.link_with(:text => /Sign In/))
      @session = authenticate_session @session
      @session = nil if not_logged_in? @session
    end

    def authenticate_session(signin_page)
      signin_page.form_with(:action => '/account/signin?returnurl=%2F') do |form|
          account_field = form.field_with(:id => 'Account_UserName')
          account_field.value = @userEmail
          password_field = form.field_with(:id => 'Account_PassWord')
          password_field.value = @userPassword
        end.submit
    end

    def not_logged_in?(session)
      (session.title) == ACCOUNT_SIGN_IN
    end

    # Add eGift to Shopping Cart
    def add_egift_to_shopping_cart(a, page)
      purchase_egift_card a, page
      raise "Unable to use particular card theme." unless @cardTheme.between?(0, CARD_THEME_OPTIONS_MAX) 
      raise "Unable to add eGift to shopping cart." if @session.nil?
      confirm_shopping_cart_egift_amount  
    end

    def purchase_egift_card(a, page)
      puts 'Navigating to eGift Page.' if @dev
      navigate_to_egift_page a, page
      puts 'Adding eGift to Cart.' if @dev
      add_egift_card_to_cart
      @session = nil if shopping_cart_not_updated? @session
    end

    def shopping_cart_not_updated?(session)
      (session.title) == EGIFT_PURCHASE_PAGE
    end

    def navigate_to_egift_page(a, page)
      @session = a.click(page.link_with(:text => /Starbucks Card eGift/))
      @session = a.click(@session.link_with(:href => /anytime/))
    end

    def add_egift_card_to_cart
      @session = @session.form_with(:id => 'ecardform') do |form|
        form.radiobuttons_with(:name => 'selected_theme')[@cardTheme].check

        recipient_name_field = form.field_with(:id => 'recipient_name')
        recipient_name_field.value = @recipientName

        recipient_email_field = form.field_with(:id => 'recipient_email')
        recipient_email_field.value = @recipientEmail

        message_field = form.field_with(:id => 'message')
        message_field.value = @message

        amount_field = form.field_with(:id => 'amount')
        amount_field.value = @amount

        sender_name_field = form.field_with(:id => 'sender_name')
        sender_name_field.value = @senderName

        sender_email_field = form.field_with(:id => 'sender_email')
        sender_email_field.value = @senderEmail

      end.submit
    end

    def confirm_shopping_cart_egift_amount
      puts 'Confirming eGift Amount.' if @dev
      @session = @session.form_with(:action => '/shop/UpdateeGiftCart')
      @session = @session.submit(@session.button_with(:name => /checkout/))
    end


    # Select and Confirm Payment Method
    def select_and_confirm_payment_method
      select_payment_method
      confirm_payment_method
    end

    def select_payment_method
      puts 'Selecting Payment Method.' if @dev
      @session = @session.form_with(:id => 'checkoutForm') do |form|
        case @paymentMethod
          when :credit
            form.radiobuttons_with(:name => 'paymentOption')[PAYMENT_METHOD_CREDIT].check
          when :gift
            form.radiobuttons_with(:name => 'paymentOption')[PAYMENT_METHOD_GIFT].check
          else
            raise "Unable to select payment method (Credit or Gift Card Allowed Only)."
        end
      end.submit
    end

    def confirm_payment_method
      puts 'Confirming Payment Method.' if @dev
      case @paymentMethod
        when :credit
          confirm_credit_payment_method
          check_credit_cvn_set
          raise "Credit Card CVN is not set." if @session.nil?
        when :gift
          confirm_gift_payment_method
          check_gift_card_balance
          raise "Gift card balance is too low. Please refill default card." if @session.nil?
        else
          raise "Unable to select payment method."
      end
    end

    def confirm_gift_payment_method
      @session = @session.form_with(:id => 'checkoutForm') do |form|
        form.radiobuttons_with(:name => 'Card.CardId')[DEFAULT_GIFT_CARD].check
        form.button_with(:value => 'next')
      end.submit
    end

    def check_gift_card_balance
      puts 'Checking gift card balance' if @dev
      @session = nil if gift_card_balance_low? @session
    end

    def gift_card_balance_low?(session)
      (session.title) != GIFT_CARD_BALANCE_IS_FULL
    end

    def confirm_credit_payment_method
      @session = @session.form_with(:id => 'checkoutForm') do |form|
        cvn_field = form.field_with(:id => 'PaymentMethod_CVN')
        cvn_field.value = @cvn
        form.button_with(:value => 'next')
      end.submit
    end

    def check_credit_cvn_set 
      @session = nil if @cvn.nil?
    end

    # Purchase eGift
    def purchase_egift(a)
      puts 'Purchasing eGift.' if @dev
      finalize_purchase a
      raise "Unable to charge default credit card on file." if @session.nil?
    end

    def finalize_purchase(a)
      puts 'Finalizing Purchase.' if @dev
      @session = a.click(@session.link_with(:text => /Purchase/))
      (@session = nil if card_not_charged? @session) if @paymentMethod.eql? :credit
    end

    def card_not_charged?(session)
      (session.title) == CARD_CHARGE_FAILED_PAGE
    end
  end
end