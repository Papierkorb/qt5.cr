module Qt
  # Describes a 2D-point in an unknown space.  Manual wrapper class for the
  # Qt types `QPoint` and `QPointF`.  See `Point` and `PointF` for easy use.
  struct PointBase(T, B)
    getter unwrap : B

    def to_unsafe : B
      @unwrap
    end

    def initialize(x = 0, y = 0)
      @unwrap = B.new(xp: T.new(x), yp: T.new(y))
    end

    def initialize(@unwrap : B)
    end

    {% for field in %i[ x y ].map(&.id) %}
      # Returns the {{ field }} value
      def {{ field }} : T
        @unwrap.{{ field }}p
      end

      # Sets the {{ field }} value
      def {{ field }}=(value : T)
        @unwrap.{{ field }}p = value
      end
    {% end %}

    # Multiplies all axis with *factor*
    def *(factor : Number) : self
      self.class.new(T.new(x * factor), T.new(y * factor))
    end

    # Divides all axis by *factor*
    def /(factor : Number) : self
      self.class.new(T.new(x / factor), T.new(y / factor))
    end

    # Adds *value* to all axis
    def +(value : Number) : self
      self.class.new(T.new(x + value), T.new(y + value))
    end

    # Substracts *value* from all axis
    def -(value : Number) : self
      self.class.new(T.new(x - value), T.new(y - value))
    end

    # Adds the values of *other* to the axis of this point.
    def +(other : PointBase) : self
      self.class.new(T.new(x + other.x), T.new(y + other.y))
    end

    # Substracts the values of *other* to the axis of this point.
    def -(other : PointBase) : self
      self.class.new(T.new(x - other.x), T.new(y - other.y))
    end

    # Negates both axis.
    def - : self
      self.class.new(-x, -y)
    end

    # Returns `true` if all axis are zero.
    def null? : Bool
      x == 0 && y == 0
    end

    # Returns the sum of the absolute values of all axis.  Also known as the
    # manhattan length of an vector from the origin to the point.
    def manhattan_length : T
      x.abs + y.abs
    end

    # Turns this point into a `Point` by casting the inner components.
    def to_point : Point
      Point.new(x.to_i, y.to_i)
    end

    # Turns this point into a `PointF` by casting the inner components.
    def to_pointf : PointF
      PointF.new(x.to_f, y.to_f)
    end

    def to_s(io)
      io << "#{x}, #{y}"
    end

    def inspect(io)
      io << "<Point: #{x}, #{y}>"
    end
  end

  # A 2D point with integer (`Int32`) accuracy.
  alias Point = PointBase(Binding::QPoint, Int32)

  # A 2D point with floating-point (`Float64`) accuracy.
  alias PointF = PointBase(Binding::QPointF, Float64)
end
