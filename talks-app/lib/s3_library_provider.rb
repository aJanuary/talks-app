require 's3'
require 'toml'
require 'library/talk'
require 'library/file'

class S3File < Library::File
  def initialize(
    talk_id,
    name,
    access_key_id,
    secret_access_key,
    bucket_name
  )
    super(name)

    @talk_id = talk_id
    @access_key_id = access_key_id
    @secret_access_key = secret_access_key
    @bucket_name = bucket_name
  end

  def inspect
    "#<S3File:#{object_id}>"
  end

  def get_download_url
    service = S3::Service.new(
      access_key_id: @access_key_id,
      secret_access_key: @secret_access_key
    )
    bucket = service.bucket(@bucket_name)
    object = bucket.objects.find("#{@talk_id}/#{name}")
    object.temporary_url
  end
end

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
	talks << parse_talk(talk_id, parsed)
      end
    end
    Hash[talks.sort_by {|talk| talk.date}.map {|talk| [talk.id, talk]}]
  end

private
  def parse_talk(talk_id, data)
    files = Hash[(data['files'] || []).map do |file|
      S3File.new(
	talk_id,
	file['name'],
	@access_key_id,
	@secret_access_key,
	@bucket_name
      )
    end.map {|file| [file.name, file]}]

    sections = (data['section'] || []).map do |section|
      parse_talk(talk_id, section)
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

