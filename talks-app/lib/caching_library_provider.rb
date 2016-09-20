require 'concurrent'

class CachingLibraryProvider
  def initialize(library_provider, interval, logger: nil)
    @library_provider = library_provider

    @library = Concurrent::AtomicReference.new
    @timer = Concurrent::TimerTask.new(
      execution_interval: interval, run_now: true
    ) do |task|
      begin
	logger.info('updating library cache') if logger
	@library.set(@library_provider.library)
      rescue Exception => e
	logger.error(e) if logger
      end
    end
  end

  def start
    @timer.execute
  end

  def library
    @library.get
  end
end

