module Qt
  abstract class GraphicsObject
    def paint(painter : Painter, option : StyleOptionGraphicsItem, widget : Widget? = nil) : Void
      paint(painter, option, widget.not_nil!)
    end
  end

  abstract class GraphicsItem
    def paint(painter : Painter, option : StyleOptionGraphicsItem, widget : Widget? = nil) : Void
      paint(painter, option, widget.not_nil!)
    end
  end
end
