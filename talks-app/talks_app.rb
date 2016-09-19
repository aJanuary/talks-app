require 'sinatra/base'

class TalksApp < Sinatra::Base
  get '/' do
    'Hello, world!'
  end
end

