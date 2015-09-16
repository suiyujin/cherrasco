require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'json'

require './app/db_utils'
require './app/image_file_utils'
require './app/user'
require './app/image'

class Main < Sinatra::Base
  configure do
    set :user, User.new
  end

  get '/redis/keys' do
    redis = redis_connect
    redis.keys
  end

  post '/init' do
    begin
      image = Image.new('00000000000000', params[:image])
      image.save_jpg_from_binary

      status 200
      message = "uploadできたよ"
    rescue => e
      status 500
      message = "エラーです:#{e.message}"
    end
    { status: status, message: message }.to_json
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

      ### 画像を解析

      ### 虫を発見した場合、下記を実行
      # ユーザーへ通知(発見から最初の一回のみ)
      user = settings.user
      user.send_insect_notification unless user.notified_flag

      # ロボットへ命令

      ### 虫を駆除完了
      # ユーザーへ通知
      user.send_insect_execution

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
