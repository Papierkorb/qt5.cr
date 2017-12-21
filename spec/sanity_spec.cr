require "./spec_helper"

describe "Qt bindings" do
  it "works" do
    # If we even get here, it means the bindings are sane enough to link on this
    # system.  There's a good chance other things will work too.
    puts "Qt version: #{Qt.version}, linked against #{Qt::QT_VERSION_STR}"
  end
end
