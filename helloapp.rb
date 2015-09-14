require 'rubygems'
require 'sinatra/base'
class HelloApp < Sinatra::Base
  get '/hello' do
    "Hello, world!"
  end
end
