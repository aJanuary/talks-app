require 'dotenv'
require './talks_app'
require './lib/s3-library-provider/s3_library_provider'

Dotenv.load

library_provider = S3LibraryProvider.new(
  ENV['S3_ACCESS_KEY_ID'],
  ENV['S3_SECRET_ACCESS_KEY'],
  ENV['S3_BUCKET_NAME']
)

TalksApp.set :library_provider, library_provider

run TalksApp

