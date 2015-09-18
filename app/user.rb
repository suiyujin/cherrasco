require 'apns'

class User
  #mu
  DEVICE_TOKEN = 'ba11ac578913bae7444415ba9f3111dd007372e41cbae8d6f8556c25de8fdf1b'
  #DEVICE_TOKEN = 'ba11ac578913bae7444415ba9f3111dd007372e41cbae8d6f8556c25de8fdf1'
  #pe
  #DEVICE_TOKEN = '8f1ca6e6ffdd3c754a0c455599de012288bbf8040c979ac6a875a7f7568fc962'

  attr_reader :notified_flag

  def initialize
    APNS.host = 'gateway.sandbox.push.apple.com'
    APNS.pem = "#{File.expand_path(File.dirname(__FILE__)).sub(/app/, "config/")}server_certificates_development.pem"
    APNS.port = 2195

    @notified_flag = false
  end

  def send_insect_notification(image_name)
    send_notification('虫を発見しました！',1,"http://52.69.192.37/images/"+image_name+".jpg")
    @notified_flag = true
  end

  def send_insect_capture
    send_notification('虫を捕獲しました！',0,"")
    @notified_flag = false
  end

  private

  def send_notification(alert,mode,image_url)
    APNS.send_notification(
      DEVICE_TOKEN,
      {
        alert: alert,
        badge: 1,
        sound: 'default',
        other: {
          mode: mode,
          image_url: image_url
        }
      }
    )
    p "notified!!"
  end
end
