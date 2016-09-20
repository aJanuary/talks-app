require 's3'
require 'toml'
require 'library/talk'

class S3LibraryProvider
  def initialize(access_key_id, secret_access_key, bucket_name)
    @access_key_id = access_key_id
    @secret_access_key = secret_access_key
    @bucket_name = bucket_name
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

	talks << Talk.new(
	  talk_id,
	  parsed['title'],
	  parsed['date'],
	  parsed['presenter'],
	  parsed['description'],
	  []
	)
      end
    end
    talks.sort_by {|talk| talk.date}
  end
end

