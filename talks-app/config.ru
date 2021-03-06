$:.unshift('lib').uniq!

require File.expand_path('talks_app', File.dirname(__FILE__))

require 'dotenv'
require 'toml'
require 'logger'
require 's3_library_provider'
require 'caching_library_provider'

Dotenv.load

logger = Logger.new(STDOUT)
use Rack::CommonLogger, logger

config = TOML.load_file(File.expand_path('config.toml', File.dirname(__FILE__)))

library_provider = S3LibraryProvider.new(
  ENV['S3_ACCESS_KEY_ID'],
  ENV['S3_SECRET_ACCESS_KEY'],
  config['s3']['bucket_name'],
  logger: logger
)

interval = config['caching']['interval']
library_provider = CachingLibraryProvider.new(
  library_provider,
  interval,
  logger: logger
)
library_provider.start

TalksApp.set :library_provider, library_provider
TalksApp.set :config, config['web']

run TalksApp

