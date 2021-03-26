require "../../src/qt5/ui/parser"

# Create the application first
app = Qt::Application.new

# Create a `Qt::Ui::Parser` instance and provide it our creator schema
ui_schema = File.join(File.dirname(__FILE__), "mainwindow.ui")
ui_parser = Qt::Ui::Parser.new(ui_schema)

# Parse the ui
ui_parser.parse!

# We're ready for showtime
ui_parser.window.show

# And now, start it!
Qt::Application.exec
