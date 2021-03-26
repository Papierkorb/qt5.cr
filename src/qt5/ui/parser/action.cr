module Qt::Ui
  class Parser
    module Action
      abstract def logger
      abstract def data : Qt::Ui::Data

      # Parse the XML action node
      #
      # ```xml
      #  <action name="actionOpen">
      #   <property name="text">
      #    <string>Open</string>
      #   </property>
      #  </action>
      # ```
      protected def parse_action_node(node : XML::Node, parent : Qt::Widget) : Qt::Action?
        action = Qt::Action.new(parent)
        name = node["name"].not_nil!

        logger.info &.emit("created action",
          crystal_klass: action.class.to_s,
          klass: "action",
          name: name,
          parent: parent.object_name
        )

        raise "action with name: #{name} already exists!" if self.data.get_action(name)

        parse_action_sub_nodes(node, action)

        # Append new action to our list
        self.data.actions[name] = action
        action
      end

      private def parse_action_sub_nodes(node, item)
        node.children.select(&.element?).each do |child|
          case child.name
          when "property"
            parse_action_property(child, item)
          else
            logger.warn { "action sub node for \"#{child.name}\" is not currently supported" }
          end
        end
      end

      # Parse the property node for the provided `Qt::Action`
      private def parse_action_property(node : XML::Node, action : Qt::Action)
        case node["name"]
        when "text"
          string = node.first_element_child.try &.content
          action.text = string if string
        else
          logger.warn { "action property #{node["name"]} is not supported for #{action.class}" }
        end
      end

      def associate_action(w_name, a_name)
        widget = self.data.get_widget(w_name)
        case widget
        when Qt::MenuBar
          menu = self.data.get_widget(a_name)
          if menu.is_a?(Qt::Menu)
            logger.info { "adding menu with name: #{a_name} to widget: #{w_name}" }
            widget.add_action(menu.menu_action)
          else
            logger.warn { "unable to find action with name: #{a_name} to associate with widget: #{w_name}" }
          end
        when Qt::Widget
          action = self.data.get_action(a_name)
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
    end
  end
end
