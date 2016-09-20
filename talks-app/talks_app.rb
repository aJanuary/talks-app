require 'sinatra/base'

class TalksApp < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/public'

  before do
    @config = OpenStruct.new(settings.config)

    # Only get the library once, at the begining of the request.
    # If we call settings.library_store.library multiple times in a request,
    # it might return different values because a fetch happened in-between.
    @library = settings.library_provider.library

    halt 503, 'Waiting for library data' if @library.nil?
  end

  get '/' do
    erb :index, :locals => { :talks => @library.values }
  end

  get '/talk/:talk_id' do |talk_id|
    talk = @library[talk_id]
    erb :talk, :locals => { :talk => talk, :is_section => false }
  end

  get '/talk/:talk_id/files/:file_name' do |talk_id, file_name|
    talk = @library[talk_id]
    file = talk.file(file_name)
    redirect file.get_download_url
  end
end

