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
      @cvn            = params[:cvn]
    
      @cardTheme      = params[:cardTheme] # currently only supports anytime cards

      @session = nil
    end  

    def send_egift 
      a = Mechanize.new { |agent|
        agent.follow_meta_refresh = true
      }

      a.get(SITE_URL) do |page|
        authenticate a, page
        add_egift_to_shopping_cart a, page
        select_and_confirm_payment_method
        purchase_egift a
      end
    end


    private

    # Authentication
    def authenticate a, page
        sign_in a, page
        raise "Unable to login." if @session.nil?
    end

    def sign_in a, page
      @session  = a.click(page.link_with(:text => /Sign In/))
      @session = authenticate_session @session
      @session = nil if not_logged_in? @session
    end

    def authenticate_session signin_page
      signin_page.form_with(:action => '/account/signin?returnurl=%2F') do |form|
          account_field = form.field_with(:id => 'Account_UserName')
          account_field.value = @userEmail
          password_field = form.field_with(:id => 'Account_PassWord')
          password_field.value = @userPassword
        end.submit
    end

    def not_logged_in? session
      (session.title) == ACCOUNT_SIGN_IN
    end

    # Add eGift to Shopping Cart
    def add_egift_to_shopping_cart a, page
      purchase_egift_card a, page
      raise "Unable to use particular card theme." if @cardTheme.between?(0, ) 
      raise "Unable to add eGift to shopping cart." if @session.nil?
      confirm_shopping_cart_egift_amount  
    end

    def purchase_egift_card a, page
      navigate_to_egift_page a, page
      add_egift_card_to_cart
      @session = nil if shopping_cart_not_updated? @session
    end

    def shopping_cart_not_updated? session
      (session.title) == EGIFT_PURCHASE_PAGE
    end

    def navigate_to_egift_page a, page
      puts 'Navigating to eGift select page.'
      @session = a.click(page.link_with(:text => /Starbucks Card eGift/))
      @session = a.click(@session.link_with(:href => /anytime/))
      puts 'Adding anytime eGift Card to shopping cart'
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
      @session = @session.form_with(:action => '/shop/UpdateeGiftCart')
      @session = @session.submit(@session.button_with(:name => /checkout/))
    end


    # Select and Confirm Payment Method
    def select_and_confirm_payment_method
      select_payment_method
      confirm_payment_method
    end

    def select_payment_method
      @session = @session.form_with(:id => 'checkoutForm') do |form|
        form.radiobuttons_with(:name => 'paymentOption')[PAYMENT_METHOD].check
      end.submit
    end

    def confirm_payment_method
      @session = @session.form_with(:id => 'checkoutForm') do |form|
        cvn_field = form.field_with(:id => 'PaymentMethod_CVN')
        cvn_field.value = @cvn
        form.button_with(:value => 'next')
      end.submit
    end


    # Purchase eGift
    def purchase_egift a
      finalize_purchase a
      
      raise "Unable to charge default card on file. Check card number or CVN." if @session.nil?
    end

    def finalize_purchase a
      puts 'Purchasing eGift'
      @session = a.click(@session.link_with(:text => /Purchase/))
      @session = nil if card_not_charged? @session
    end

    def card_not_charged? session
      (session.title) == CARD_CHARGE_FAILED_PAGE
    end

  end
end