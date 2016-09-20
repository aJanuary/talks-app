module Library
  class Talk
    attr_reader :id, :title, :date, :presenter, :description, :files

    def initialize(id, title, date, presenter, description, files)
      @id = id
      @title = title
      @date = date
      @presenter = presenter
      @description = description
      @files = files
    end
  end
end
