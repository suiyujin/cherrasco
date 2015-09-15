require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'mysql2'
require 'redis'
require 'hiredis'
require 'yaml'
require 'json'

require './app/image'

class Main < Sinatra::Base
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
  end

  get '/redis/keys' do
    redis = redis_connect
    redis.keys
  end

  post '/upload' do
    begin
      image = Image.new(DateTime.now.strftime("%Y%m%d%H%M%S"), params[:image])
      redis = redis_connect
      redis.set(image.key, image.image_binary)
      # TODO: listに格納して、古いものは破棄するようにする

      status 200
      message = "uploadできたよ"
    rescue => e
      status 500
      message = "エラーです:#{e.message}"
    end
    { status: status, message: message }.to_json
  end
end
