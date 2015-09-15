require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'mysql2'
require 'redis'
require 'hiredis'
require 'yaml'

class HelloApp < Sinatra::Base
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

  get '/hello' do
    "Hello, world!"
  end

  get '/users/:id' do
    client = mysql_connect
    name = ""
    client.query("SELECT name FROM test WHERE id = #{params[:id]}").each do |result|
      name = result["name"]
    end
    name
  end

  get '/redis/keys' do
    redis = redis_connect
    redis.keys
  end
end
