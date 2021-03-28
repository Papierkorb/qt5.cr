require "spoved/logger"

# Container class to hold all the generated items from `Qt::Parser`
class Qt::Ui::Data
  spoved_logger

  # Name of the root `Qt::Widget`
  getter root_name : String

  def initialize(@root_name : String); end

  macro add_node_container(name, klass, hash = false)
    {% if hash %}
    getter {{name.id}}s : Hash(String, {{klass}}) = Hash(String, {{klass}}).new
    {% else %}
    getter {{name.id}}s : Set({{klass}}) = Set({{klass}}).new
    {% end %}
    # Return generated `{{klass}}` by name, or nil if not found
    def get_{{name.id}}(name : String) : {{klass}}?
      self.get_{{name.id}}!(name)
    rescue ex
      logger.warn { "unable to fetch {{name.id}} with name #{name}" }
      nil
    end

    def get_{{name.id}}!(name : String) : {{klass}}
      {% if hash %}
      self.{{name.id}}s[name]
      {% else %}
      self.{{name.id}}s.find { |w| w.object_name == name }.not_nil!
      {% end %}
    end
  end

  add_node_container(:widget, Qt::Widget)
  add_node_container(:layout, Qt::Layout)
  add_node_container(:action, Qt::Action, true)
  add_node_container(:widget_action, Array(String), true)
  add_node_container(:widget_attribute, Array(XML::Node), true)
  add_node_container(:layout_item, Qt::LayoutItem, true)

  def add(item, name : String = "")
    case item
    when Qt::LayoutItem
      self.layout_items[name] = item
    when Qt::Action
      self.actions[name] = item
    when Qt::Widget
      self.widgets << item
    when Qt::Layout
      self.layouts << item
    end
  end

  # Will add the action(s) to the list for widget with *name*
  #  for association later via `#associate_actions`
  def add_action(name : String, list : Array(String))
    list.each { |a| self.add_action(name, a) }
  end

  # :ditto:
  def add_action(name : String, a_name : String)
    self.widget_actions[name] = Array(String).new unless self.widget_actions[name]?
    self.widget_actions[name] << a_name unless self.widget_actions[name].includes?(a_name)
  end

  # Will add the attribute to the list for widget with *name*
  #  for association later via `#associate_attributes`
  def add_attribute(name : String, assoc : XML::Node)
    self.widget_attributes[name] = Array(XML::Node).new unless self.widget_attributes[name]?
    self.widget_attributes[name] << assoc unless self.widget_attributes[name].includes?(assoc)
  end

  # Will return a `Qt::Widget` with the defined `#root_name`. or raise an error
  def root : Qt::Widget
    get_widget!(self.root_name)
  end

  # Will associate any actions in `widget_actions` with existing widgets.
  # This should be done after all actions and widgets are created.
  def associate_actions
    self.widget_actions.each do |w_name, action_list|
      action_list.each do |a_name|
        associate_action(w_name, a_name)
      end
    end
  end

  # Will attempt to associate the `Qt::Action` identified by *a_name* with a
  #  `Qt::Widget` identified by *w_name*
  private def associate_action(w_name, a_name)
    widget = self.get_widget(w_name)
    case widget
    when Qt::MenuBar
      menu = self.get_widget(a_name)
      if menu.is_a?(Qt::Menu)
        logger.info { "adding menu with name: #{a_name} to widget: #{w_name}" }
        widget.add_action(menu.menu_action)
      else
        logger.warn { "unable to find action with name: #{a_name} to associate with widget: #{w_name}" }
      end
    when Qt::Widget
      action = self.get_action(a_name)
      if action
        logger.info { "adding action with name: #{a_name} to widget: #{w_name}" }
        widget.add_action(action)
      else
        logger.warn { "unable to find action with name: #{a_name} to associate with widget: #{w_name}" }
      end
    else
      logger.warn { "unable to find widget with name: #{w_name} to associate actions with" }
    end
  end

  def associate_attributes
    self.widget_attributes.each do |w_name, attr_list|
      attr_list.each do |node|
        associate_attribute(w_name, node)
      end
    end
  end

  def associate_attribute(w_name : String, node : XML::Node)
    widget = self.get_widget!(w_name)
    parent = self.get_widget!(widget.parent_widget.object_name)
    case parent
    when Qt::TabWidget
      handle_tab_widget_attributes(widget, parent, node)
    else
      raise "unsupported attribute: #{node["name"]}"
    end
  end

  private def handle_tab_widget_attributes(widget, parent, node)
    case node["name"]
    when "title"
      tab_text = Qt::Ui::Parser::Converter.property_node_to_val(node).as(String)
      logger.info &.emit("adding tab to widget",
        widget: parent.object_name, tab: widget.object_name, text: tab_text,
      )
      parent.add_tab(widget, tab_text)
    else
      raise "unsupported tab attribute: #{node["name"]}"
    end
  end

  # Set the `central_widget`, `menu_bar`, and `status_bar` properties of the
  #  root object if those widgets have been created and the root object is a
  #  `Qt::MainWindow`.
  #
  # ```
  # data.update_window(
  #   central_widget_name: "centralwidget",
  #   menu_bar_name: "menubar",
  #   status_bar_name: "statusbar",
  # )
  # ```
  def update_window(central_widget_name : String? = nil, menu_bar_name : String? = nil, status_bar_name : String? = nil)
    window = self.root
    if window.is_a?(Qt::MainWindow)
      unless central_widget_name.nil?
        cw = self.get_widget(central_widget_name)
        if cw
          window.central_widget = cw
        end
      end

      unless menu_bar_name.nil?
        mb = self.get_widget(menu_bar_name)
        if mb && mb.is_a?(Qt::MenuBar)
          window.menu_bar = mb
        end
      end

      unless status_bar_name.nil?
        sb = self.get_widget(status_bar_name)
        if sb && sb.is_a?(Qt::StatusBar)
          window.status_bar = sb
        end
      end
    end
  end
end
