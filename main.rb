require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'json'

require './app/db_utils'
require './app/image_file_utils'
require './app/user'
require './app/robot'
require './app/image'
require './app/image_analyzer'

class Main < Sinatra::Base
  configure do
    set :in_process, false
    set :user, User.new
    set :robot, Robot.new
  end

  get '/redis/keys' do
    redis = redis_connect
    redis.keys
  end

  post '/init' do
    begin
      image = Image.new('background', params[:image])
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
    p "----- post /upload(#{Time.now}) -----"
    begin
      # 捕獲モード中は、下記のプロセスを行わない
      unless settings.in_process
        image = Image.new(DateTime.now.strftime("%Y%m%d%H%M%S"), params[:image])
        check_file_limit("./public/images/", "2015*.jpg")
        image.save_jpg_from_binary

        redis = redis_connect
        check_data_limit(redis)
        redis.lpush("images",
        {
          upload_time: image.upload_time,
          value: params[:image]
        }.to_json)

        ### 画像を解析
        previous_upload_time = redis.lindex("images", "1")
        # 古い画像ファイルを削除
        check_file_limit("./tmp/images/", "binarized_image*.png")
        check_file_limit("./public/images/", "diff_image*.png")

        image_analyzer = ImageAnalyzer.new(previous_upload_time, image.upload_time)

        if image_analyzer.exist_insect?
          ### 虫を発見した場合、捕獲行動を開始
          settings.in_process = true

          # ユーザーへ通知(発見から最初の一回のみ)
          user = settings.user
          user.send_insect_notification(image.upload_time) unless user.notified_flag

          # ロボットへ命令
          image_analyzer.make_command
          robot = settings.robot
          if robot.execute(image_analyzer.degree, image_analyzer.distance_m)
            # ユーザーへ通知
            user.send_insect_capture
            ### 虫を捕獲完了
            settings.in_process = false
          else
            ### 捕獲未完了
            settings.in_process = true
          end

          message = "robot catched insect."
        else
          message = "not exist insect."
        end
      else
        message = "robot is executing."
      end
      status 200
    rescue => e
      p e.message
      p $@
      status 500
      message = "error : #{e.message}"
    end
    { status: status, message: message }.to_json
  end

  helpers DBUtils, ImageFileUtils
end
