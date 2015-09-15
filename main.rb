require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'mysql2'
require 'redis'
require 'hiredis'
require 'yaml'
require 'json'
require "fileutils"

require './app/image'

class Main < Sinatra::Base
  LIMIT_NUM_DATA = 3

  helpers do
    def load_config_file
      YAML.load_file('./db/config.yml')
    end

    def mysql_connect
      config = load_config_file
      Mysql2::Client.new(
        :host => config["mysql2"]["host"],
        :username => config["mysql2"]["username"],
        :password => config["mysql2"]["password"],
        :database => config["mysql2"]["database"]
      )
    end

    def redis_connect
      config = load_config_file
      Redis.new(config["hiredis"])
    end

    def check_file_limit
      # tmp/images/にn個より多い場合は最新のn個を残して破棄
      Dir.chdir("./tmp/images/") do
        image_files = Dir.glob("*.jpg").sort
        if image_files.size > LIMIT_NUM_DATA
          FileUtils.rm(image_files[0, image_files.size - LIMIT_NUM_DATA])
        end
      end
    end

    def check_data_limit(redis)
      # listにn個以上ある場合は最新のn-1個を残して破棄
      if redis.llen("images").to_i > LIMIT_NUM_DATA
        redis.ltrim("images", 0, LIMIT_NUM_DATA - 1)
      end
    end
  end

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
end
