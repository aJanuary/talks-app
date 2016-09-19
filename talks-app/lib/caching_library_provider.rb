require 'concurrent'

class CachingLibraryProvider
  def initialize(library_provider, interval)
    @library_provider = library_provider

    @library = Concurrent::AtomicReference.new
    @timer = Concurrent::TimerTask.new(
      execution_interval: interval, run_now: true
    ) do |task|
      @library.set(@library_provider.library)
    end
  end

  def start
    @timer.execute
  end

  def library
    @library.get
  end
end

