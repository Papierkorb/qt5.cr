require "semantic_version"
require "xml"
require "spoved/logger"

require "../../qt5"

require "./data"
require "./parser/nodes"
require "./factory"

module Qt::Ui
  class Parser
    spoved_logger

    include Qt::Ui::Parser::Nodes

    getter data : Qt::Ui::Data
    private getter document : XML::Node

    delegate get_widget, get_layout, get_layout_item, get_action,
      associate_actions, associate_attributes, to: @data

    def initialize(@document : XML::Node, name : String)
      @data = Qt::Ui::Data.new(name)
    end

    def initialize(ui_file_path)
      doc = XML.parse(File.read(ui_file_path))

      ui = doc.first_element_child
      raise "unable to parse document" if ui.nil?
      # Grab the class element
      r = ui.children.select(&.element?).find(&.name.==("class"))
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
      self.document.children.select(&.element?).each do |child|
        parse_xml_node(child)
      end

      associate_actions
      associate_attributes

      logger.trace { "parse end" }

      self
    end

    macro validate!(item, typ)
      unless {{item}}.is_a?({{typ}})
        raise "{{item}} must be a {{typ}}"
      end
    end
  end
end
