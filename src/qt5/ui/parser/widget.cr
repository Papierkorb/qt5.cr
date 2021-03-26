module Qt::Ui
  class Parser
    module Widget
      abstract def logger
      abstract def parse_layout_node(node : XML::Node, parent : Qt::Widget) : Qt::Layout?
      abstract def parse_action_node(node : XML::Node, parent : Qt::Widget) : Qt::Action?
      abstract def data : Qt::Ui::Data

      # Convert Qt string to a crystal `Qt::Widget` instance. Will set *parent* for the created node.
      private def widget_from_class(klass : String, parent : Qt::Widget) : Qt::Widget?
        {% begin %}
          case klass
          {% for sub_class in Qt::Widget.all_subclasses %}
          {% valid = false %}
          {% if !sub_class.abstract? && !sub_class.name.includes?("Impl") %}
            {% for m in sub_class.methods %}
              {% if m.name == "initialize" && m.args.size == 1 && m.args.first.name == "parent" %}
                {% valid = true %}
              {% end %}
          {% end %}
          {% if valid %}
          when {{sub_class.id.gsub(/Qt::/, "Q").id.stringify}}
            {{sub_class.id}}.new(parent)
          {% end %}{% end %}{% end %}
          when "QWidget"
            Qt::Widget.new(parent)
          else
            logger.warn { "widget \"#{klass}\" is not supported" }
            nil
          end
        {% end %}
      end

      # Parse the XML widget node
      private def parse_widget_node(node : XML::Node, parent : Qt::Widget) : Qt::Widget?
        widget = (node["class"]? && node["class"] == "QMainWindow") ? self.window : widget_from_class(node["class"], parent)

        if widget.nil?
          logger.warn &.emit "unable to create widget", klass: node["class"], name: node["name"]
          return
        else
          # Append new widget to our list
          self.data.widgets << widget
          logger.info &.emit("created widget",
            crystal_klass: widget.class.to_s,
            klass: node["class"],
            name: node["name"],
            parent: parent.object_name
          )
        end

        widget.object_name = node["name"] if node["name"]?

        parse_widget_sub_nodes(node, widget)

        widget
      end

      private def parse_widget_sub_nodes(node, widget)
        node.children.select(&.element?).each do |child|
          case child.name
          when "property"
            parse_widget_property(child, widget)
          when "layout"
            parse_layout_node(child, widget)
          when "widget"
            parse_widget_node(child, widget)
          when "action"
            parse_action_node(child, widget)
          when "addaction"
            # Append the action association to be completed later
            self.data.widget_actions[widget.object_name] = Array(String).new unless self.data.widget_actions[widget.object_name]?
            self.data.widget_actions[widget.object_name] << child["name"].not_nil!

            logger.notice &.emit "found action association", widget: widget.object_name, action: child["name"]
          else
            logger.warn { "widget sub node for \"#{child.name}\" is not currently supported" }
          end
        end
      end

      # Parse the property node for the provided `Qt::Widget`
      private def parse_widget_property(node : XML::Node, widget : Qt::Widget)
        case node["name"]
        when "geometry"
          rect = node_to_rect(node.xpath_node("rect").not_nil!)
          widget.geometry = rect unless rect.nil?
        when "windowTitle"
          set_widget_property("window_title")
        when "text"
          set_widget_property("text")
        when "title"
          set_widget_property("title")
        when "maximumSize"
          size = node_to_size(node.xpath_node("size").not_nil!)
          widget.maximum_size = size unless size.nil?
        else
          logger.warn { "widget property #{node["name"]} is not supported for #{widget.class}" }
        end
      end

      private macro set_widget_property(method)
        case widget
        {% begin %}
        {% for sub_class in Qt::Widget.all_subclasses %}
        {% if !sub_class.abstract? && sub_class.has_method?("#{method.id}=") %}
        when {{sub_class.id}}
          string = node.first_element_child.try &.content
          widget.{{method.id}} = string if string
        {% end %}{% end %}{% end %}
        else
          logger.warn { "widget property #{node["name"]} is not supported for #{widget.class}" }
        end
      end
    end
  end
end
