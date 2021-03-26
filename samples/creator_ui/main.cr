require "../../src/qt5/ui/parser"

spoved_logger :trace, bind: true, clear: true, dispatcher: :sync

# Allow user to select file and load collection
def open_file(checked : Bool)
  # Show a "Open file..." dialog
  file_url = Qt::FileDialog.get_open_file_url

  unless file_url.empty? # Did the user choose something?
    file_path = file_url.to_local_file
    begin
      puts "load file: #{file_path}"
    rescue ex
      puts "unable to load file: #{file_path}"
    end
  end
end

# Create the application first
app = Qt::Application.new

# Create a `Qt::Ui::Parser` instance and provide it our creator schema
ui_schema = File.join(File.dirname(__FILE__), "mainwindow.ui")
ui_parser = Qt::Ui::Parser.new(ui_schema)

# Parse the ui
ui_parser.parse!

# Parsed objects are available vi `Qt::Ui::Parser#data`

# Fetch the open action and associate our `open_file` method to it
open_action = ui_parser.data.get_action("actionOpen").not_nil!
open_action.status_tip = "Open file"
open_action.shortcut = Qt::KeySequence.from_string("Ctrl+O")
# Clicking on "Open" ...
open_action.on_triggered &->open_file(Bool)

# We're ready for showtime
ui_parser.window.show

# And now, start it!
Qt::Application.exec
