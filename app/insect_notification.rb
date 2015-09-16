require 'bundler/setup'
require 'apns'
APNS.host = 'gateway.sandbox.push.apple.com'
APNS.pem  = '/var/www/cherrasco/config/server_certificates_development.pem'
APNS.port = 2195

#device_token = 'ba11ac578913bae7444415ba9f3111dd007372e41cbae8d6f8556c25de8fdf1b' # 送りたい端末のdevice token
device_token = '8f1ca6e6ffdd3c754a0c455599de012288bbf8040c979ac6a875a7f7568fc962'
APNS.send_notification(device_token, :alert => '虫を発見しました！', :badge => 1, :sound => 'default')
