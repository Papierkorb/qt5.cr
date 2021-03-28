module Qt::Ui
  class Parser
    module Layout
      # Parse the XML layout node
      protected def parse_layout_node(node : XML::Node, parent : Qt::Widget) : Qt::Layout?
        layout = layout_from_class(node["class"], parent)
        if layout.nil?
          logger.warn &.emit("unable to create layout", klass: node["class"], name: node["name"])
          return
        else
          # Append new layout to our list
          self.data.add(layout)
          logger.info &.emit("created layout",
            crystal_klass: layout.class.to_s,
            klass: node["class"],
            name: node["name"],
            parent: parent.object_name
          )
        end

        layout.object_name = node["name"] if node["name"]?

        if parent.layout.is_a?(Qt::LayoutImpl)
          parent.layout = layout
        end

        parse_layout_node(node, parent, layout)

        layout
      end

      # Parse the XML node for the provided `Qt::GridLayout` *layout*
      private def parse_layout_node(node : XML::Node, parent : Qt::Widget, layout : Qt::Layout)
        node.children.select(&.element?).each do |child|
          case child.name
          when "item"
            parse_layout_item(child, parent, layout)
          when "property"
            parse_layout_property(child, layout)
          else
            logger.warn { "grid layout sub node \"#{child.name}\" is not supported" }
          end
        end
      end

      private def parse_layout_item(node : XML::Node, parent : Qt::Widget, layout : Qt::GridLayout)
        row, column = node["row"].to_i, node["column"].to_i
        node.children.select(&.element?).each do |child|
          item = parse_xml_node(child, parent)
          case item
          when Qt::Layout, Qt::Widget, Qt::LayoutItem
            logger.debug { "Adding #{item.is_a?(Qt::Object) ? item.object_name : item} to #{layout.object_name} at #{row} #{column}" }
            layout[column, row] = item
          else
            logger.warn { "unable to add item #{node["class"]} to #{layout.object_name}" }
          end
        end
      end

      private def parse_layout_item(node : XML::Node, parent : Qt::Widget, layout : Qt::Layout)
        node.children.select(&.element?).each do |child|
          item = parse_xml_node(child, parent)
          case item
          when Qt::Widget
            logger.debug { "Adding widget #{item.object_name} to #{layout.object_name}" }
            layout.add_widget(item)
          when Qt::LayoutItem
            logger.debug { "Adding item #{item} to #{layout.object_name}" }
            layout.add_item(item)
          end
        end
      end

      private def parse_layout_property(node : XML::Node, layout : Qt::Layout)
        case node["name"]
        when "leftMargin"
          margins = layout.contents_margins
          string = node.first_element_child.try &.content
          if string
            layout.contents_margins = Qt::Margins.new(
              left: string.to_i,
              top: margins.top,
              right: margins.right,
              bottom: margins.bottom,
            )
          end
        when "topMargin"
          margins = layout.contents_margins
          string = node.first_element_child.try &.content
          if string
            layout.contents_margins = Qt::Margins.new(
              left: margins.left,
              top: string.to_i,
              right: margins.right,
              bottom: margins.bottom,
            )
          end
        when "rightMargin"
          margins = layout.contents_margins
          string = node.first_element_child.try &.content
          if string
            layout.contents_margins = Qt::Margins.new(
              left: margins.left,
              top: margins.top,
              right: string.to_i,
              bottom: margins.bottom,
            )
          end
        when "bottomMargin"
          margins = layout.contents_margins
          string = node.first_element_child.try &.content
          if string
            layout.contents_margins = Qt::Margins.new(
              left: margins.left,
              top: margins.top,
              right: margins.right,
              bottom: string.to_i,
            )
          end

          # parse_grid_layout_properties(leftMargin, :to_i)
        else
          logger.warn { "gridlayout property \"#{node["name"]}\" is not supported for #{layout.class}" }
        end
      end
    end
  end
end
