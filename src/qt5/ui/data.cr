# Container class to hold all the generated items from `Qt::Parser`
class Qt::Ui::Data
  spoved_logger

  getter base_widget : Qt::Widget
  getter widgets : Set(Qt::Widget) = Set(Qt::Widget).new
  getter widget_actions : Hash(String, Array(String)) = Hash(String, Array(String)).new
  getter layouts : Set(Qt::Layout) = Set(Qt::Layout).new
  getter layout_items : Hash(String, Qt::LayoutItem) = Hash(String, Qt::LayoutItem).new
  getter actions : Hash(String, Qt::Action) = Hash(String, Qt::Action).new

  def initialize(@base_widget : Qt::Widget)
  end

  # Return generated `Qt::Widget` by name, or nil if not found
  def get_widget(name : String) : Qt::Widget?
    self.widgets.find { |w| w.object_name == name }
  end

  # Return generated `Qt::Layout` by name, or nil if not found
  def get_layout(name : String) : Qt::Layout?
    self.layouts.find { |x| x.object_name == name }
  end

  # Return generated `Qt::LayoutItem` item by name, or `nil` if not found
  def get_layout_item(name : String) : Qt::LayoutItem?
    self.layout_items[name]?
  end

  def get_action(name : String) : Qt::Action?
    self.actions[name]?
  end
end
