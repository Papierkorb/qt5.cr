require "./converter"
require "./macros"
require "./*"

module Qt::Ui
  class Parser
    module Nodes
      include Qt::Ui::Parser::Converter

      include Qt::Ui::Parser::LayoutItem
      include Qt::Ui::Parser::Layout
      include Qt::Ui::Parser::Action

      abstract def data : Qt::Ui::Data
      abstract def logger

      Qt::Ui.parse_node_props(Qt::Object, [
        "geometry", "windowTitle", "text", "title", "placeholderText", "clearButtonEnabled",
        "editable", "margin", "enabled", "frameShape", "frameShadow", "alignment",
        "maximumSize", "minimumSize", "autoFillBackground", "widgetResizable",
        "verticalScrollBarPolicy", "iconSize", "currentIndex", "usesScrollButtons",
        "documentMode", "tabsClosable", "movable", "tabBarAutoHide", "tabsClosable",
        "elideMode", "tabPosition", "sizeAdjustPolicy", "styleSheet", "palette",
        "checkable",
      ])

      def parse_xml_node(node : XML::Node, parent : Qt::Object? = nil)
        logger.trace &.emit("parsing xml node",
          type: node.name,
          name: node["name"]?,
          parent: parent.class.to_s
        )
        case node.name
        when "class"
          # ignore
        when "widget"
          validate!(parent, Qt::Widget?)
          parse_widget_node(node, parent)
        when "spacer"
          validate!(parent, Qt::Widget)
          parse_spacer_node(node, parent)
        when "layout"
          validate!(parent, Qt::Widget)
          parse_layout_node(node, parent)
        when "property"
          validate!(parent, Qt::Object)
          parse_node_property(node, parent)
        when "action"
          validate!(parent, Qt::Widget)
          parse_action_node(node, parent)
        when "resources", "connections"
          # Known, unsupported
          nil
        when "addaction"
          validate!(parent, Qt::Object)
          logger.debug &.emit "found action association", item: parent.object_name, action: node["name"]
          self.data.add_action(parent.object_name, node["name"].not_nil!)
        when "attribute"
          validate!(parent, Qt::Object)
          logger.debug &.emit "found attribute", item: parent.object_name, action: node["name"]
          self.data.add_attribute(parent.object_name, node)
        else
          logger.warn { "qt ui xml node \"#{node.name}\" is not supported" }
          nil
        end
      end

      #########################################
      # Qt::Widgets
      #########################################

      # Parse the XML widget node
      private def parse_widget_node(node : XML::Node, parent : Qt::Widget? = nil) : Qt::Widget?
        widget = widget_from_class(node["class"], parent)

        if widget.nil?
          logger.warn &.emit "unable to create widget", klass: node["class"], name: node["name"]
          return
        else
          # Append new widget to our list
          self.data.add(widget)
          logger.debug &.emit("created widget",
            crystal_klass: widget.class.to_s,
            klass: node["class"],
            name: node["name"],
            parent: parent.nil? ? "" : parent.object_name
          )
        end

        widget.object_name = node["name"] if node["name"]?

        node.children.select(&.element?).each do |child|
          parse_xml_node(child, widget)
        end

        widget
      end
    end
  end
end
