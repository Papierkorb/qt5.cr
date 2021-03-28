require "uuid"

module Qt::Ui
  class Parser
    module LayoutItem
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
          self.data.layout_items[name] = spacer
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
        # orientation property is already taken care of for `Qt::SpacerItem` when created
        # by `#parse_spacer_node`
        return if node["name"] == "orientation" && item.is_a?(Qt::SpacerItem)

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
    end
  end
end
