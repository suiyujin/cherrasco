class Image
  attr_reader :upload_time, :image_binary

  def initialize(now_strftime, image_hex)
    @upload_time = now_strftime
    @image_binary = normalize_image_binary(image_hex)
  end

  def save_jpg_from_binary
    save_path = File.expand_path(File.dirname(__FILE__)).sub(/app/, "tmp/images/")
    file_name = "#{@upload_time}.jpg"

    File.open("#{save_path}#{file_name}", "wb") do |save_file|
      save_file.write(@image_binary)
    end
  end

  private

  def normalize_image_binary(image_hex)
    # アプリから受け取った16進文字列をバイナリに変換
    image_hex.gsub(/(\<|\>|\s)/, '').hex2bin
  end
end

class String
  def hex2bin
    s = self
    raise "Not a valid hex string" unless s =~ /^[\da-fA-F]+$/
    s = '0' + s if (s.length & 1) != 0
    s.scan(/../).map { |b| b.to_i(16) }.pack('C*')
  end

  def bin2hex
    self.unpack('C*').map { |b| "%02X" % b }.join('')
  end
end
