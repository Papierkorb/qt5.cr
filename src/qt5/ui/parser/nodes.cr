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
    end
  end
end
