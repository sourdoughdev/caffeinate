# Caffeinate
A simple wrapper for sending Starbucks eGifts.

## Installing Caffeinate
### RubyGems.org
```
% gem install caffeinate
```

### Bundler
```
# Gemfile
gem 'caffeinate'
```
## Usage
Before getting started you'll need to make sure that you a Starbucks.com account and that you have setup a default credit card on file.

CVN is attached to your credit card on file. Starbucks.com requires you to confirm your card on file before making the payment.

Card Theme is chosen from the eGift anytime themes. You can select from 0 to 7 (there are only 8 anytime cards). Here is a selection of the cards - far left begins at 0.

Once you have instantiated a caffeinate object, you just need to call send_egift. If an error occurs, caffeinate will throw an error i.e. user authentication failed, CVN is incorrect, etc.

If an error isn't thrown, the egift will be sent to your recipient. You'll get a confirmation that the eGift is processing. This should be sent to the email address you registered with your Starbucks.com account.

```
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
```

```
begin
  @caffeinate.send_egift
rescue Exception => ex
  puts "ERROR (#{ex.class}) => #{ex.message}"
end
```

## Limitations
Currently, I have only tested this gem with Starbucks.com eGifts. The eGift should work fine in North America.

The only payment method available is the on-file default credit card in your Starbucks.com account.

You can only send anytime eGifts. cardTheme can be set to one of the anytime card themes (starts at zero). I felt that since most cards tend to be seasonal, anytime eGifts would be most stable. In the future it would be best to add support for picking card themes.

Message is limited to 150 characters. Any extra characters will be left out.

## Contributing
If you find a bug, or want to help add some more test cases, feel free to fork the project.

## Changelog
0.01 - initial release

## Roadmap
0.02 - add support to store the confirmation token on the success page.

0.03 - add support for more than anytime eGift themes