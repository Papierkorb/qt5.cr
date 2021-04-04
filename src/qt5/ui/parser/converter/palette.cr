module Qt::Ui
  class Parser
    module Converter
      # Translate the `XML::Node` to `Qt::Palette`
      def node_to_palette(node : XML::Node) : Qt::Palette
        palette = Qt::Palette.new
        node.children.select(&.element?).each do |child|
          parse_palette_node(child, palette)
        end
        logger.trace { "created palette #{palette}" }
        palette
      end

      private def parse_palette_node(node : XML::Node, palette : Qt::Palette)
        color_group = string_to_color_group(node.name)
        node.children.select(&.element?).each do |child|
          case child.name
          when "colorrole"
            color_role = string_to_color_role(child["role"])
            parse_palette_color_role(child, palette, color_group, color_role)
          else
            logger.warn { "palette node \"#{child.name}\" is not supported" }
          end
        end
      end

      private def parse_palette_color_role(node : XML::Node, palette : Qt::Palette,
                                           color_group : Qt::Palette::ColorGroup,
                                           color_role : Qt::Palette::ColorRole)
        node.children.select(&.element?).each do |child|
          case child.name
          when "brush"
            brush = node_to_brush(child)
            logger.trace &.emit("setting brush",
              color_group: color_group.to_s,
              color_role: color_role.to_s,
              brush: brush.to_s)
            palette.set_brush(color_group, color_role, brush)
          else
            logger.warn { "palette colorrole \"#{child.name}\" is not supported" }
          end
        end
      end
    end
  end
end
