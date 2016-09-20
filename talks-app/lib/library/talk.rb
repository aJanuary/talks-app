module Library
  class Talk
    attr_reader :id, :title, :date, :presenter, :description, :files, :sections

    def initialize(id, title, date, presenter, description, files, sections)
      @id = id
      @title = title
      @date = date
      @presenter = presenter
      @description = description
      @files = files
      @sections = sections
    end
  end
end
