require 'sinatra/base'

class TalksApp < Sinatra::Base
  get '/' do
    settings.library_provider.get_library.map {|t| t.title}
  end
end

