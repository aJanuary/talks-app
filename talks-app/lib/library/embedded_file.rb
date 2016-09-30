module Library
  class EmbeddedFile
    attr_reader :file, :aspect_ratio

    def initialize(file, aspect_ratio)
      @file = file
      @aspect_ratio = aspect_ratio
    end

    def scale(max_width)
      (max_width / @aspect_ratio[0].to_f).to_i
    end

    def width(max_width)
      scale(max_width) * @aspect_ratio[0]
    end

    def height(max_width)
      scale(max_width) * @aspect_ratio[1]
    end
  end
end
