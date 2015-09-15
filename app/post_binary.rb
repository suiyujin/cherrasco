require 'net/http'
require 'uri'
require 'rmagick'

class PostBinary
  def initialize(file_name)
    @file_path = File.expand_path(File.dirname(__FILE__)).sub(/app/, "public/")
    @file_name = file_name
    @image_binary = "hogehoge"
  end

  def convert_image_to_binary
    magick_image = Magick::Image.read("#{@file_path}#{@file_name}").first
    @image_binary = magick_image.to_blob
  end

  def post
    uri = URI.parse("http://localhost:5000/upload")
    Net::HTTP.start(uri.host, uri.port) do |http|
      # リクエストインスタンス生成
      request = Net::HTTP::Post.new(uri.path)
      # ヘッダー部
      request["user-agent"] = "Ruby/#{RUBY_VERSION} MyHttpClient"
      # ボディ部
      request.set_form_data({ image: @image_binary })
      # 送信
      http.request(request)
    end
  end
end
