$:.unshift('lib').uniq!

require 'dotenv'

require File.expand_path('talks_app', File.dirname(__FILE__))

require 's3_library_provider'
require 'caching_library_provider'

Dotenv.load

library_provider = S3LibraryProvider.new(
  ENV['S3_ACCESS_KEY_ID'],
  ENV['S3_SECRET_ACCESS_KEY'],
  ENV['S3_BUCKET_NAME']
)

library_provider = CachingLibraryProvider.new(library_provider, 10)

TalksApp.set :library_provider, library_provider

run TalksApp

