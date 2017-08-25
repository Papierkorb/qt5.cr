require "../src/qt5"

# This sample shows how to override C++ (virtual) methods from Crystal code.

# 1. Create a class and inherit from your target class - Like normal.
class MyLabel < Qt::Label
  # 2. Look-up the definition of the event method(s), and match their prototype.
  #    Then, write the implementation - Like normal
  def mouse_press_event(event : Qt::MouseEvent) : Void
    self.text = "Event: Press\n#{event.buttons}"
  end

  # You can also rely on Crystals type-deduction, and leave out the argument
  # types.  Same goes for return type.
  def mouse_release_event(event)
    self.text = "Event: Release\n#{event.buttons}"
  end
end

# 4. And now, use the class - Like normal!
app = Qt::Application.new
label = MyLabel.new "Click me!"
label.resize 400, 100

label.show

# This is it: You don't have to do anything special at all.  Just write Crystal
# code like you're used to.  And override methods like that.  However, do keep
# in mind that this will *only* work for C++ `virtual` methods.  It won't have
# any effect in the C++-world for non-virtual methods.
Qt::Application.exec
