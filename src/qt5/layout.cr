module Qt
  class Layout
    # Adds *widget* to the layout.
    def <<(widget : Widget) : self
      add_widget(widget)
      self
    end

    # Adds *layout* to the layout.
    def <<(layout : Layout) : self
      add_layout(layout)
      self
    end

    # Adds *layout_item* to the layout.
    def <<(layout_item : LayoutItem) : self
      add_item(layout_item)
      self
    end
  end
end
