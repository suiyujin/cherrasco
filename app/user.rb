require 'apns'

class User
  DEVICE_TOKEN = 'ba11ac578913bae7444415ba9f3111dd007372e41cbae8d6f8556c25de8fdf1b'
  #DEVICE_TOKEN = '8f1ca6e6ffdd3c754a0c455599de012288bbf8040c979ac6a875a7f7568fc962'

  attr_reader :notified_flag

  def initialize
    APNS.host = 'gateway.sandbox.push.apple.com'
    APNS.pem = "#{File.expand_path(File.dirname(__FILE__)).sub(/app/, "config/")}server_certificates_development.pem"
    APNS.port = 2195

    @notified_flag = false
  end

  def send_insect_notification
    send_notification('虫を発見しました！')
    @notified_flag = true
  end

  def send_insect_execution
    send_notification('虫を駆除しました！')
    @notified_flag = false
  end

  private

  def send_notification(alert)
    APNS.send_notification(
      DEVICE_TOKEN,
      {
        alert: alert,
        badge: 1,
        sound: 'default'
      }
    )
    p "notified!!"
  end
end
