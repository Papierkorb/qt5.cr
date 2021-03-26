require "uuid"

module Qt::Ui
  class Parser
    module LayoutItem
      abstract def logger

      getter layout_items : Hash(String, Qt::LayoutItem) = Hash(String, Qt::LayoutItem).new

      # Return generated `Qt::LayoutItem` item by name, or `nil` if not found
      def get_layout_item(name : String) : Qt::LayoutItem?
        self.layout_items[name]?
      end

      private def spacer_from_orientation(orientation : String) : Qt::SpacerItem?
        case orientation
        when "Qt::Vertical"
          Qt::SpacerItem.vertical
        when "Qt::Horizontal"
          Qt::SpacerItem.horizontal
        else
          logger.warn { "unable to parse spacer orientation: \"#{orientation}\"" }
          nil
        end
      end

      # Parse the XML spacer node
      private def parse_spacer_node(node : XML::Node, parent : Qt::Widget) : Qt::SpacerItem?
        name = node["name"]? || UUID.random.to_s
        orientation = node.xpath_string("string(property[@name='orientation'][1]/enum[1])")
        spacer = spacer_from_orientation(orientation)
        if spacer.nil?
          logger.warn &.emit("unable to create spacer", orientation: orientation, name: name)
          return
        else
          # Append new spacer to our layout items list
          self.layout_items[name] = spacer
          logger.info &.emit("created spacer",
            crystal_klass: spacer.class.to_s,
            klass: spacer.class.to_s,
            name: name,
            parent: parent.object_name
          )
        end

        node.children.select(&.element?).each do |child|
          case child.name
          when "property"
            parse_layout_item_property(child, spacer)
          else
            logger.warn { "spacer sub node \"#{child.name}\" is not supported" }
          end
        end

        spacer
      end

      # Parse the property node for the provided `Qt::LayoutItem`
      private def parse_layout_item_property(node : XML::Node, item : Qt::LayoutItem)
        case node["name"]
        when "sizeHint"
          size = node_to_size(node.xpath_node("size").not_nil!)
          if !size.nil? && item.is_a?(Qt::SpacerItem)
            item.change_size(size.width, size.height, item.size_policy.horizontal_policy, item.size_policy.vertical_policy)
          else
            logger.warn { "layout item property #{node["name"]} is not supported for #{item.class}" }
          end
        else
          logger.warn { "layout item property #{node["name"]} is not supported for #{item.class}" }
        end
      end

      private macro set_layout_item_property(method)
        {% begin %}
          case item
          {% for sub_class in Qt::LayoutItem.all_subclasses %}
          {% if !sub_class.abstract? && sub_class.has_method?("#{method.id}=") %}
          when {{sub_class.id}}
            string = node.first_element_child.try &.content
            item.{{method.id}} = string if string
          {% end %}{% end %}
          else
            logger.warn { "layout item property #{node["name"]} is not supported for #{item.class}" }
          end
        {% end %}
      end
    end
  end
end
