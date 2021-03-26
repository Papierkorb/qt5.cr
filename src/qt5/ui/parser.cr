require "xml"
require "./parser/nodes"

module Qt::Ui
  class Parser
    spoved_logger

    include Qt::Ui::Parser::Nodes

    getter window : Qt::MainWindow
    private getter document : XML::Node

    def initialize(ui_file_path, @window)
      @document = XML.parse(File.read(ui_file_path))
    end

    def setup_ui
      ui = document.first_element_child
      raise "unable to parse document" if ui.nil?

      ui.children.select(&.element?).each do |child|
        parse_xml_node(child, window)
      end
    end

    private def parse_xml_node(node : XML::Node, parent : Qt::Widget) : Qt::LayoutItem | Qt::Widget | Nil
      case node.name
      when "widget"
        parse_widget_node(node, parent)
      when "spacer"
        parse_spacer_node(node, parent)
      else
        logger.warn { "qt ui xml node \"#{node.name}\" is not supported" }
        nil
      end
    end
  end
end
