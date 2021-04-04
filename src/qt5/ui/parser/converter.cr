require "spoved/logger"
require "./converter/*"

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
        when "palette"
          node_to_palette(element)
        when "enum", "set"
          property_node_to_enum(element)
        else
          raise "unsupported property class: #{element.name}"
        end
      end

      def property_node_to_enum(node : XML::Node)
        case node.content
        when /QSizePolicy/
          string_to_size_policy(node.content)
        when /QAbstractScrollArea/
          string_to_scroll_area(node.content)
        when /Qt::ScrollBar/
          string_to_scroll_bar_policy(node.content)
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
          {% if !sub_class.abstract? && !sub_class.name.includes?("Impl") && sub_class.name =~ /^Qt::/ %}
          when {{sub_class.name.gsub(/^Qt::/, "Q").id.stringify}}
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
      def spacer_from_orientation(orientation : String, size_type : String?) : Qt::SpacerItem?
        size_policy = (size_type.empty? || size_type.nil?) ? Qt::SizePolicy::Policy::Expanding : string_to_size_policy(size_type)
        case orientation
        when "Qt::Vertical"
          Qt::SpacerItem.vertical(size_policy)
        when "Qt::Horizontal"
          Qt::SpacerItem.horizontal(size_policy)
        else
          logger.warn { "unable to parse spacer orientation: \"#{orientation}\"" }
          nil
        end
      end
    end
  end
end
