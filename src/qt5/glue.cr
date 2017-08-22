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
  end
end
