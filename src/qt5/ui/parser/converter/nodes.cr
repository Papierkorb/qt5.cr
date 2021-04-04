module Qt::Ui
  class Parser
    module Converter
      #########################################
      # Convert XML::Nodes into values
      #########################################

      # Translate the `XML::Node` to `Qt::Size`
      def node_to_size(node : XML::Node) : Qt::Size?
        Qt::Size.new(
          node.xpath_string("string(width[1])").not_nil!.to_i,
          node.xpath_string("string(height[1])").not_nil!.to_i,
        )
      rescue ex
        logger.error { "failed to translate node into size" }
        logger.error { ex.message }
        nil
      end

      # Translate the `XML::Node` to `Qt::Rect`
      def node_to_rect(node : XML::Node) : Qt::Rect?
        Qt::Rect.new(
          node.xpath_string("string(x[1])").not_nil!.to_i,
          node.xpath_string("string(y[1])").not_nil!.to_i,
          node.xpath_string("string(width[1])").not_nil!.to_i,
          node.xpath_string("string(height[1])").not_nil!.to_i,
        )
      rescue ex
        logger.error { "failed to translate node into rect" }
        logger.error { ex.message }
        nil
      end

      # Translate the `XML::Node` to `Qt::Color`
      def node_to_color(node : XML::Node) : Qt::Color
        Qt::Color.new(
          r: node.xpath_string("string(red[1])").not_nil!.to_i,
          g: node.xpath_string("string(green[1])").not_nil!.to_i,
          b: node.xpath_string("string(blue[1])").not_nil!.to_i,
          a: node["alpha"]? ? node["alpha"].to_i : 255
        )
      end

      # Translate the `XML::Node` to `Qt::Brush`
      def node_to_brush(node : XML::Node) : Qt::Brush
        brush_style = string_to_brush_style(node["brushstyle"])
        color_node = node.xpath_node("color")
        raise "unable to parse color from node" if color_node.nil?
        color = node_to_color(color_node)
        Qt::Brush.new(color: color, bs: brush_style)
      end
    end
  end
end
