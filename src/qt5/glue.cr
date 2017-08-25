module Qt
  lib Binding
    alias QMetaObjectConnection = Void
  end

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
      def self.unwrap(msec : Int64) : Time::Span
        ticks = Time::Span::TicksPerMillisecond * msec
        Time::Span.new(ticks)
      end

      def self.wrap(duration : Time::Span) : Int64
        duration.ticks / Time::Span::TicksPerMillisecond
      end
    end
  end
end
