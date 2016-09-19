require 'sinatra/base'

class TalksApp < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/public'

  before do
    # Only get the library once, at the begining of the request.
    # If we call settings.library_store.library multiple times in a request,
    # it might return different values because a fetch happened in-between.
    @library = settings.library_provider.library

    halt 503, 'Waiting for library data' if @library.nil?
  end

  get '/' do
    erb :index
  end
end

