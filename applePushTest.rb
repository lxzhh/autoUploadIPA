# encoding: utf-8

require "houston"

def pushText(text)
  apn = Houston::Client.development
  apn.certificate = File.read("/Users/redhatimac/Desktop/certif/apple_push_notification.pem")

  # An example of the token sent back when a device registers for notifications
  token = "<86060cfe 44800238 fde73bc3 9002c9f5 8230e53c fed33e25 9552f7e0 ac2fb867>"

  # Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
  notification = Houston::Notification.new(device: token)
  notification.alert = nil

  # Notifications can also change the badge count, have a custom sound, indicate available Newsstand content, or pass along arbitrary data.
  notification.badge = 1
  # notification.sound = "sosumi.aiff"
  notification.content_available = true
  notification.custom_data = {:CustParam => "7"}

  # And... sent! That's all it takes.
  apn.push(notification)

end

pushText("some message")

