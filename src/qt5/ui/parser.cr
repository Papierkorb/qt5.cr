require "semantic_version"
require "xml"
require "spoved/logger"

require "../../qt5"

require "./data"
require "./parser/nodes"

module Qt::Ui
  class Parser
    spoved_logger

    include Qt::Ui::Parser::Nodes

    getter data : Qt::Ui::Data
    private getter document : XML::Node

    delegate get_widget, get_layout, get_layout_item, get_action,
      associate_actions, associate_attributes, to: @data

    def initialize(ui_file_path)
      doc = XML.parse(File.read(ui_file_path))

      ui = doc.first_element_child
      raise "unable to parse document" if ui.nil?
      # Grab the class element
      r = ui.children.select(&.element?).find { |c| c.name == "class" }
      raise "unable to parse root document" if r.nil?
      name = r.content

      @document = ui
      @data = Qt::Ui::Data.new(name)
      check_schema_version!
    end

    def window : Qt::MainWindow
      self.data.base_widget.as(Qt::MainWindow)
    end

    private def check_schema_version!
      ver = self.document["version"]?

      raise "no document version found" if ver.nil?
      ver = ver + ".0" if ver =~ /^\d+\.\d+$/
      unless (SemanticVersion.parse(ver) <=> SemanticVersion.parse("4.0.0")) >= 0
        raise "document version #{ver} not supported"
      end
    end

    def parse! : Parser
      logger.trace { "parse start" }
      # find root node
      # root_node = self.document.xpath_node("//widget[@name=#{data.root_name}]")

      self.document.children.select(&.element?).each do |child|
        parse_xml_node(child)
      end

      associate_actions
      associate_attributes

      logger.trace { "parse end" }

      self
    end

    Qt::Ui.parse_node_props(Qt::Object, [
      "geometry", "windowTitle", "text", "title", "placeholderText", "clearButtonEnabled",
      "editable", "margin", "enabled", "frameShape", "frameShadow", "alignment",
      "maximumSize", "minimumSize", "autoFillBackground",

    ])

    Qt::Ui.parse_node_props(Qt::TabWidget, [
      "iconSize", "currentIndex", "usesScrollButtons", "documentMode", "tabsClosable", "movable", "tabBarAutoHide", "tabsClosable", "elideMode",
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
      when "addaction"
        validate!(parent, Qt::Object)
        logger.info &.emit "found action association", item: parent.object_name, action: node["name"]
        self.data.add_action(parent.object_name, node["name"].not_nil!)
      when "attribute"
        validate!(parent, Qt::Object)
        logger.info &.emit "found attribute", item: parent.object_name, action: node["name"]
        self.data.add_attribute(parent.object_name, node)
      else
        logger.warn { "qt ui xml node \"#{node.name}\" is not supported" }
        nil
      end
    end

    macro validate!(item, typ)
      unless {{item}}.is_a?({{typ}})
        raise "{{item}} must be a {{typ}}"
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
        logger.info &.emit("created widget",
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
