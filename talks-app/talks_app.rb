require 'sinatra/base'
require 'glorify'

class TalksApp < Sinatra::Base
  register Sinatra::Glorify
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
    handle_page(1)
  end

  get '/:page' do |page|
    handle_page(page.to_i)
  end

  get '/talk/:talk_id' do |talk_id|
    talk = @library[talk_id]
    halt 404 if talk.nil?
    erb :talk, :locals => { :talk => talk, :is_section => false }
  end

  get '/talk/:talk_id/files/:file_name' do |talk_id, file_name|
    talk = @library[talk_id]
    halt 404 if talk.nil?
    file = talk.file(file_name)
    halt 404 if file.nil?
    redirect file.get_download_url
  end

private
  def handle_page(page)
    halt 404 if page < 1
    num_talks = @library.values.size
    start_idx = (page - 1) * @config.page_size
    end_idx = start_idx + @config.page_size - 1
    talks = @library.values[start_idx..end_idx]
    halt 404 if talks.nil?
    
    erb :index, :locals => {
      :page => page,
      :num_pages => (num_talks / @config.page_size.to_f).ceil,
      :talks => talks
    }
  end
end

