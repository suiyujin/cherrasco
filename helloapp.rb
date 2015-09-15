require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'mysql2'
require 'yaml'

class HelloApp < Sinatra::Base
  helpers do
    def mysql_connect
      db = YAML.load_file('./db/database.yml')
      Mysql2::Client.new(
        :host => db["mysql2"]["host"],
        :username => db["mysql2"]["username"],
        :password => db["mysql2"]["password"],
        :database => db["mysql2"]["database"]
      )
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
end
