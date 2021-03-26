require "./*"

module Qt::Ui
  class Parser
    module Nodes
      include Qt::Ui::Parser::LayoutItem
      include Qt::Ui::Parser::Layout
      include Qt::Ui::Parser::Widget

      abstract def logger

      # Translate the `XML::Node` to `Qt::Rect`
      private def node_to_rect(node : XML::Node) : Qt::Rect?
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

      # Translate the `XML::Node` to `Qt::Size`
      private def node_to_size(node : XML::Node) : Qt::Size?
        Qt::Size.new(
          node.xpath_string("string(width[1])").not_nil!.to_i,
          node.xpath_string("string(height[1])").not_nil!.to_i,
        )
      rescue ex
        logger.error { "failed to translate node into size" }
        logger.error { ex.message }
        nil
      end
    end
  end
end
