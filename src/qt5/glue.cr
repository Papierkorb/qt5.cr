module Qt
  # Converters used to turn binding-types into crystal-types.
  module Converter
    module QString
      def self.unwrap(wrapped : Binding::CrystalString) : String
        String.new(wrapped.ptr, wrapped.size)
      end

      def self.wrap(string : String) : Binding::CrystalString
        Binding::CrystalString.new(ptr: string.to_unsafe, size: string.bytesize)
      end
    end

    module TimeSpan
      NANO_PER_MILLI = 1_000_000

      def self.unwrap(msec : Int64) : Time::Span
        Time::Span.new(nanoseconds: msec * NANO_PER_MILLI)
      end

      def self.wrap(duration : Time::Span) : Int64
        duration.total_milliseconds.to_i64
      end
    end
  end
end
