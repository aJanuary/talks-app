module Library
  class Talk
    attr_reader :id, :title, :date, :presenter, :description,
      :embedded_files, :files, :sections

    def initialize(
      id,
      title,
      date,
      presenter,
      description,
      embedded_files,
      files,
      sections
    )
      @id = id
      @title = title
      @date = date
      @presenter = presenter
      @description = description
      @embedded_files = embedded_files
      @files = files
      @sections = sections
    end

    def embedded_file(file_name)
      return @embedded_files[file_name].file if @embedded_files[file_name]
      @sections.each do |section|
        section_file = section.embedded_file(file_name)
        return section_file if section_file
      end
      nil
    end

    def file(file_name)
      return @files[file_name] if @files[file_name]
      @sections.each do |section|
        section_file = section.file(file_name)
        return section_file if section_file
      end
      nil
    end
  end
end
