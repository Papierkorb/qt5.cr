module Qt
  class Object
    # Returns the hash of the underlying QObject pointer.
    def hash(hasher)
      @unwrap.hash(hasher)
    end

    # Compares this to *other* by testing the underlying QObject pointers.
    def ==(other : Object)
      @unwrap == other.to_unsafe
    end
  end
end
