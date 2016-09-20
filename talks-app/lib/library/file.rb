module Library
  class File
    attr_reader :name, :type

    def initialize(name, type)
      @name = name
      @type = type || 'file'
    end
  end
end
