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

    delegate get_widget, get_layout, get_layout_item, get_action, to: @data

    def initialize(ui_file_path, @window : Qt::MainWindow = Qt::MainWindow.new)
      @data = Qt::Ui::Data.new(@window)
      @document = XML.parse(File.read(ui_file_path))
    end

    def window : Qt::MainWindow
      self.data.base_widget.as(Qt::MainWindow)
    end

    def parse! : Parser
      ui = document.first_element_child
      raise "unable to parse document" if ui.nil?

      ui.children.select(&.element?).each do |child|
        parse_xml_node(child, window)
      end

      associate_actions
      update_window

      self
    end

    private def parse_xml_node(node : XML::Node, parent : Qt::Widget) : Qt::LayoutItem | Qt::Widget | Nil
      case node.name
      when "class"
        # ignore
      when "widget"
        parse_widget_node(node, parent)
      when "spacer"
        parse_spacer_node(node, parent)
      else
        logger.warn { "qt ui xml node \"#{node.name}\" is not supported" }
        nil
      end
    end

    # Set the windows `central_widget`, `menu_bar`, and `status_bar` if those widgets
    # have been created
    private def update_window
      central_widget = self.data.get_widget("centralwidget")
      if central_widget
        window.central_widget = central_widget
      end

      menu_bar = self.data.get_widget("menubar")
      if menu_bar && menu_bar.is_a?(Qt::MenuBar)
        window.menu_bar = menu_bar
      end

      status_bar = self.data.get_widget("statusbar")
      if status_bar && status_bar.is_a?(Qt::StatusBar)
        window.status_bar = status_bar
      end
    end

    private def associate_actions
      self.data.widget_actions.each do |w_name, action_list|
        action_list.each do |a_name|
          associate_action(w_name, a_name)
        end
      end
    end
  end
end
