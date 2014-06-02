require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/pride'

require 'caffeinate'

class TestCaffeinate < Minitest::Test
  def setup
    @caffeinate = 
      Caffeinate::Caffeinate.new(
        :userEmail              => "login@example.com", 
        :userPassword           => "password1",
        :senderName             => "Sunny",
        :senderEmail            => "sunny@example.com",
        :recipientName          => "Thomas",
        :recipientEmail         => "thomas@example.com",
        :message                => "Thanks Bud!",
        :amount                 => "5",
        :cardTheme              => 3,
        :paymentMethod          => :gift,
#       :cvn                    => "123",
        :dev                    => true
      )
  end

  def test_caffeinate_login_credentials_set_properly
    assert_equal "login@example.com", @caffeinate.userEmail
    assert_equal "password1", @caffeinate.userPassword
  end

  def test_caffeinate_send_egift
    begin
      @caffeinate.send_egift
    rescue Exception => ex
      puts "ERROR (#{ex.class}) => #{ex.message}"
    end
  end

end