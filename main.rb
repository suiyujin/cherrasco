require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'json'

require './app/db_utils'
require './app/image_file_utils'
require './app/image'

class Main < Sinatra::Base
  get '/redis/keys' do
    redis = redis_connect
    redis.keys
  end

  post '/upload' do
    begin
      image = Image.new(DateTime.now.strftime("%Y%m%d%H%M%S"), params[:image])
      check_file_limit
      image.save_jpg_from_binary

      redis = redis_connect
      check_data_limit(redis)
      redis.lpush("images",
      {
        upload_time: image.upload_time,
        value: params[:image]
      }.to_json)

      status 200
      message = "uploadできたよ"
    rescue => e
      status 500
      message = "エラーです:#{e.message}"
    end
    { status: status, message: message }.to_json
  end

  helpers DBUtils, ImageFileUtils
end
