require 's3'
require 'toml'
require 'library/talk'
require 'library/file'

class S3LibraryProvider
  def initialize(access_key_id, secret_access_key, bucket_name, logger: nil)
    @access_key_id = access_key_id
    @secret_access_key = secret_access_key
    @bucket_name = bucket_name
    @logger = logger
  end

  def inspect
    "#<S3LibraryProvider:#{object_id}>"
  end

  def library
    service = S3::Service.new(
      access_key_id: @access_key_id,
      secret_access_key: @secret_access_key
    )
    bucket = service.bucket(@bucket_name)

    talks = []
    bucket.objects.each do |object|
      (talk_id, file) = object.key.split('/', 2)
      if file == 'talk.toml'
	content = object.content
	parsed = TOML::Parser.new(content).parsed

	@logger.info parsed if @logger
	talks << parse_talk(talk_id, parsed)
      end
    end
    talks.sort_by {|talk| talk.date}
  end

private
  def parse_talk(talk_id, data)
    files = (data['files'] || []).map do |file|
      Library::File.new(file['name'])
    end

    sections = (data['section'] || []).map do |section|
      parse_talk(nil, section)
    end

    Library::Talk.new(
      talk_id,
      data['title'],
      data['date'],
      data['presenter'],
      data['description'],
      files,
      sections
    )
  end
end

