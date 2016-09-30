require 's3'
require 'toml'
require 'library/talk'
require 'library/file'
require 'library/embedded_file'

class S3File < Library::File
  def initialize(
    talk_id,
    name,
    type,
    access_key_id,
    secret_access_key,
    bucket_name
  )
    super(name, type)

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
    Hash[talks.sort_by {|talk| talk.date}.reverse.map {|talk| [talk.id, talk]}]
  end

private
  def parse_file(talk_id, file)
    S3File.new(
      talk_id,
      file['name'],
      file['type'],
      @access_key_id,
      @secret_access_key,
      @bucket_name
    )
  end

  def parse_talk(talk_id, data)
    files = Hash[(data['files'] || []).map do |file|
      parse_file(talk_id, file)
    end.map {|file| [file.name, file]}]

    embedded_files = Hash[(data['embed'] || []).map do |embedded|
      file = parse_file(talk_id, embedded)
      aspect_ratio = embedded['aspect_ratio'].split(':').map {|x| x.to_i}
      Library::EmbeddedFile.new(file, aspect_ratio)
    end.map {|embedded_file| [embedded_file.file.name, embedded_file]}]

    sections = (data['section'] || []).map do |section|
      parse_talk(talk_id, section)
    end

    Library::Talk.new(
      talk_id,
      data['title'],
      data['date'],
      data['presenter'],
      data['description'],
      embedded_files,
      files,
      sections
    )
  end
end
