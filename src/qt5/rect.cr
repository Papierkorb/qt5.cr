module Qt
  class Rect
    def to_s(io)
      io << "#{width}x#{height} @ #{x},#{y}"
    end

    def inspect(io)
      io << "<Rect: "
      to_s(io)
      io << ">"
    end
  end

  class RectF
    def to_s(io)
      io << "#{width}x#{height} @ #{x},#{y}"
    end

    def inspect(io)
      io << "<RectF: "
      to_s(io)
      io << ">"
    end
  end
end
