module Qt::Ui
  class Parser
    module Converter
      spoved_logger

      extend self

      def property_node_to_val(node : XML::Node)
        element = node.first_element_child
        raise "empty property" if element.nil?

        case element.name
        when "bool"
          element.content == "true"
        when "size"
          node_to_size(element)
        when "rect"
          node_to_rect(element)
        when "number"
          element.content.to_i
        when "string"
          element.content
        when "enum", "set"
          property_node_to_enum(element)
        else
          raise "unsupported property class: #{element.name}"
        end
      end

      def property_node_to_enum(node : XML::Node)
        case node.content
        when /QTabWidget/
          string_to_tab_enum(node.content)
        when /Qt::Elide/
          string_to_elide_mode(node.content)
        when /Qt::Alig/
          string_to_alignment(node.content)
        when /QFrame/
          string_to_frame_enum(node.content)
        else
          raise "unsupported property enum: #{node.content}"
        end
      end

      #########################################
      # Convert strings to Qt::Objects
      #########################################

      # Convert Qt string to a crystal `Qt::Widget` instance.
      def widget_from_class(klass : String) : Qt::Widget?
        {% begin %}
          case klass
          {% for sub_class in Qt::Widget.all_subclasses %}
          {% if !sub_class.abstract? && !sub_class.name.includes?("Impl") %}
          when {{sub_class.id.gsub(/Qt::/, "Q").id.stringify}}
            {{sub_class.id}}.new
          {% end %}{% end %}
          when "QWidget"
            Qt::Widget.new
          else
            logger.warn { "widget \"#{klass}\" is not supported" }
            nil
          end
        {% end %}
      end

      # Convert Qt string to a crystal `Qt::Widget` instance. Will set *parent* for the created node.
      def widget_from_class(klass : String, parent : Qt::Widget?) : Qt::Widget?
        widget = widget_from_class(klass)
        widget.parent = parent if !parent.nil? && !widget.nil?
        widget
      end

      # Convert Qt class string to a crystal `Qt::Layout` instance. Will set *parent* for the created node.
      def layout_from_class(klass : String, parent : Qt::Widget) : Qt::Layout?
        case klass
        when "QGridLayout"
          Qt::GridLayout.new
        when "QFormLayout"
          Qt::FormLayout.new
        when "QBoxLayout"
          Qt::BoxLayout.new(Qt::BoxLayout::Direction::LeftToRight)
        when "QHBoxLayout"
          Qt::HBoxLayout.new
        when "QVBoxLayout"
          Qt::VBoxLayout.new
        when "QStackedLayout"
          Qt::StackedLayout.new
        else
          logger.warn { "widget #{klass} is not supported" }
          nil
        end
      end

      # Convert the orientation string to a spacer item
      def spacer_from_orientation(orientation : String) : Qt::SpacerItem?
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

      #########################################
      # Convert strings into values
      #########################################

      def string_to_tab_enum(string : String) : Qt::TabWidget::TabPosition | Qt::TabWidget::TabShape
        case string
        when "QTabWidget::North"
          Qt::TabWidget::TabPosition::North
        when "QTabWidget::South"
          Qt::TabWidget::TabPosition::South
        when "QTabWidget::West"
          Qt::TabWidget::TabPosition::West
        when "QTabWidget::East"
          Qt::TabWidget::TabPosition::East
        when "QTabWidget::Triangular"
          Qt::TabWidget::TabShape::Triangular
        when "QTabWidget::Rounded"
          Qt::TabWidget::TabShape::Rounded
        else
          raise "unable to convert #{string} to Qt::TabWidget::TabPosition or Qt::TabWidget::TabShape"
        end
      end

      def string_to_elide_mode(string : String) : Qt::TextElideMode
        case string
        when "Qt::ElideLeft"
          Qt::TextElideMode::Left
        when "Qt::ElideRight"
          Qt::TextElideMode::Right
        when "Qt::ElideMiddle"
          Qt::TextElideMode::Middle
        when "Qt::ElideNone"
          Qt::TextElideMode::None
        else
          raise "unable to convert #{string} to Qt::TextElideMode"
        end
      end

      # Will convert the provided string into a `Qt::Alignment` flag
      def string_to_alignment(string : String) : Qt::Alignment
        items = string.split('|').map do |s|
          string_to_alignment_single(s)
        end
        Qt::Alignment.new(items.map(&.value).sum)
      end

      # Will convert the provided string into a single `Qt::Alignment`
      def string_to_alignment_single(string : String) : Qt::Alignment
        case string
        when "Qt::AlignLeft"
          Qt::Alignment::AlignLeft
        when "Qt::AlignLeading"
          Qt::Alignment::AlignLeading
        when "Qt::AlignRight"
          Qt::Alignment::AlignRight
        when "Qt::AlignTrailing"
          Qt::Alignment::AlignTrailing
        when "Qt::AlignHCenter"
          Qt::Alignment::AlignHCenter
        when "Qt::AlignJustify"
          Qt::Alignment::AlignJustify
        when "Qt::AlignAbsolute"
          Qt::Alignment::AlignAbsolute
        when "Qt::AlignHorizontal_Mask"
          Qt::Alignment::AlignHorizontal_Mask
        when "Qt::AlignTop"
          Qt::Alignment::AlignTop
        when "Qt::AlignBottom"
          Qt::Alignment::AlignBottom
        when "Qt::AlignVCenter"
          Qt::Alignment::AlignVCenter
        when "Qt::AlignBaseline"
          Qt::Alignment::AlignBaseline
        when "Qt::AlignVertical_Mask"
          Qt::Alignment::AlignVertical_Mask
        when "Qt::AlignCenter"
          Qt::Alignment::AlignCenter
        else
          raise "unable to convert #{string} to Qt::Frame::Shape"
        end
      end

      # Will convert the provided string into a `Qt::Frame::Shape` or `Qt::Frame::Shadow`
      def string_to_frame_enum(string) : Qt::Frame::Shape | Qt::Frame::Shadow
        begin
          string_to_frame_shape(string)
        rescue
          string_to_frame_shadow(string)
        end
      rescue ex
        raise "unable to convert #{string} to Qt::Frame::Shape or Qt::Frame::Shadow"
      end

      # Will convert the provided string into a `Qt::Frame::Shape`
      def string_to_frame_shape(string) : Qt::Frame::Shape
        case string
        when "QFrame::NoFrame"
          Qt::Frame::Shape::NoFrame
        when "QFrame::Box"
          Qt::Frame::Shape::Box
        when "QFrame::Panel"
          Qt::Frame::Shape::Panel
        when "QFrame::WinPanel"
          Qt::Frame::Shape::WinPanel
        when "QFrame::Hline"
          Qt::Frame::Shape::Hline
        when "QFrame::Vline"
          Qt::Frame::Shape::Vline
        when "QFrame::StyledPanel"
          Qt::Frame::Shape::StyledPanel
        else
          raise "unable to convert #{string} to Qt::Frame::Shape"
        end
      end

      # Will convert the provided string into a `Qt::Frame::Shadow`
      def string_to_frame_shadow(string) : Qt::Frame::Shadow
        case string
        when "QFrame::Plain"
          Qt::Frame::Shadow::Plain
        when "QFrame::Raised"
          Qt::Frame::Shadow::Raised
        when "QFrame::Sunken"
          Qt::Frame::Shadow::Sunken
        else
          raise "unable to convert #{string} to Qt::Frame::Shadow"
        end
      end

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
    end
  end
end
