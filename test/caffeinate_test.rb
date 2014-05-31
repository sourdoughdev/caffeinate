require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/pride'

require 'caffeinate'

class TestCaffeinate < Minitest::Test
  def setup
    @caffeinate = 
      Caffeinate::Caffeinate.new(
        :userEmail      => "myemail@mydomain.com", 
        :userPassword   => "password1",
        :senderName     => "Sunny",
        :senderEmail    => "sender-email@mydomain.com",
        :recipientName  => "Thomas",
        :recipientEmail => "thomas@tamcgoey.com",
        :message        => "Thanks Message Here!",
        :amount         => "5",
        :cvn            => "123",
        :cardTheme      => 3
      )
  end

  def test_caffeinate_login_credentials_set_properly
    assert_equal "myemail@mydomain.com", @caffeinate.userEmail
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