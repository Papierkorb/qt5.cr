module Qt
  # Describes a 2D-point in an unknown space.
  struct Point
    getter unwrap : Binding::QPoint

    def to_unsafe : Binding::QPoint*
      pointerof(@unwrap)
    end

    def initialize(x : Int32 = 0, y : Int32 = 0)
      @unwrap = Binding::QPoint.new(xp: x, yp: y)
    end

    def initialize(@unwrap : Binding::QPoint)
    end

    def initialize(unwrap : Binding::QPoint*)
      @unwrap = unwrap.value
    end

    {% for field in %i[ x y ].map(&.id) %}
      # Returns the {{ field }} value
      def {{ field }} : Int32
        @unwrap.{{ field }}p
      end

      # Sets the {{ field }} value
      def {{ field }}=(value : Int32)
        @unwrap.{{ field }}p = value
      end
    {% end %}

    # Multiplies all axis with *factor*
    def *(factor : Number) : Point
      Point.new((x * factor).to_i, (y * factor).to_i)
    end

    # Divides all axis by *factor*
    def /(factor : Number) : Point
      Point.new((x / factor).to_i, (y / factor).to_i)
    end

    # Adds *value* to all axis
    def +(value : Number) : Point
      Point.new((x + value).to_i, (y + value).to_i)
    end

    # Substracts *value* from all axis
    def -(value : Number) : Point
      Point.new((x - value).to_i, (y - value).to_i)
    end

    # Adds the values of *other* to the axis of this point.
    def +(other : Point) : Point
      Point.new(x + other.x, y + other.y)
    end

    # Substracts the values of *other* to the axis of this point.
    def -(other : Point) : Point
      Point.new(x - other.x, y - other.y)
    end

    # Negates both axis.
    def - : Point
      Point.new(-x, -y)
    end

    # Returns `true` if all axis are zero.
    def null? : Bool
      x == 0 && y == 0
    end

    # Returns the sum of the absolute values of all axis.  Also known as the
    # manhattan length of an vector from the origin to the point.
    def manhattan_length : Int32
      x.abs + y.abs
    end
  end
end
