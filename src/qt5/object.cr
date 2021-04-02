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

    def parent? : Qt::Object?
      val = Binding.bg_QObject_parent_(self)
      return nil if val.null?
      Object.new(unwrap: val)
    end
  end

  class Widget
    def parent_widget? : Widget?
      val = Binding.bg_QWidget_parentWidget_(self)
      return nil if val.null?
      Widget.new(unwrap: val)
    end
  end
end
