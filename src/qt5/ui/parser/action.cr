module Qt::Ui
  class Parser
    module Action
      # Qt::Ui.parse_node_props(Qt::Action, ["text"])

      # Parse the XML action node
      #
      # ```xml
      #  <action name="actionOpen">
      #   <property name="text">
      #    <string>Open</string>
      #   </property>
      #  </action>
      # ```
      def parse_action_node(node : XML::Node, parent : Qt::Widget) : Qt::Action?
        action = Qt::Action.new(parent)
        name = node["name"].not_nil!

        logger.debug &.emit("created action",
          crystal_klass: action.class.to_s,
          klass: "action",
          name: name,
          parent: parent.object_name
        )

        raise "action with name: #{name} already exists!" if self.data.get_action(name)

        node.children.select(&.element?).each do |child|
          parse_xml_node(child, action)
        end

        # Append new action to our list
        self.data.add(action, name)
        action
      end
    end
  end
end
