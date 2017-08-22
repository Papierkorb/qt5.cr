require "../src/qt5"

# Create the application first
qApp = Qt::Application.new

# We'll use a normal widget as window
window = Qt::Widget.new
window.window_title = "Hello, World!"

# We need to give it a layout
layout = Qt::VBoxLayout.new
window.layout = layout

# Create a label and a button, and push it into the layout
button = Qt::PushButton.new "Click me!"
label = Qt::Label.new "Click the button!"

layout << button << label

# On every press on `button`, we want to change the label.
counter = 0

button.on_pressed do # This is how you connect to the `pressed` signal
  counter += 1
  label.text = "You pressed #{counter} times!"
end

# We're ready for showtime
window.show

# And now, start it!
Qt::Application.exec
