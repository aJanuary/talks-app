require 'concurrent'

class CachingLibraryProvider
  def initialize(library_provider, interval)
    @library_provider = library_provider

    @library = Concurrent::AtomicReference.new
    Concurrent::TimerTask.new(execution_interval: interval) do |task|
      @library.set(@library_provider.library)
    end.execute
  end

  def library
    @library.get
  end
end

