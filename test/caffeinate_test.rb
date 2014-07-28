require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/pride'

require 'caffeinate'

class TestCaffeinate < Minitest::Test
  def setup
    @caffeinate = 
      Caffeinate::Caffeinate.new(
        :userEmail              => "useremailhere@test.com", 
        :userPassword           => "password1",
        :senderName             => "Sunny",
        :senderEmail            => "senderemail@test.com",
        :recipientName          => "Buddy",
        :recipientEmail         => "buddy@test.com",
        :message                => "A robot must protect its own existence as long as such protection does not conflict with the First or Second Law.",
        :amount                 => "5",
        :cardTheme              => 3,
        :paymentMethod          => :gift,
#       :cvn                    => "123",
        :dev                    => true
      )
  end

  def test_caffeinate_login_credentials_set_properly
    assert_equal "useremailhere@test.com", @caffeinate.userEmail
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