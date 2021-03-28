module Qt::Ui
  macro set_node_property(node, item, k, m_name)
    logger.trace &.emit("set_node_property",
        node: {{node}}["name"],
        item: {{item}}.class.to_s,
        method: {{m_name.id.stringify}},
        klass: {{k.stringify}},
      )
    {% klass = k.resolve %}
    {% meth = klass.methods.find { |m| m.name == "#{m_name.id}=" } %}

    {% if !meth %}{% for sub_class in klass.resolve.all_subclasses %}
    {% if sub_class.methods.find { |m| m.name == "#{m_name.id}=" } %}
    {% meth = sub_class.methods.find { |m| m.name == "#{m_name.id}=" } %}
    {% end %}{% end %}{% end %}

    {% if meth %}
      {% arg = meth.args.first %}
      {% if arg.restriction %}
      logger.trace &.emit("property_node_to_val", node: {{node}}.to_s, arg: {{arg.restriction.id.stringify}})
      val = property_node_to_val({{node}})
      if val.is_a?({{arg.restriction}})
        {{item}}.{{m_name.id}} = val
      else
        logger.error &.emit("incorrect value type",
          node: {{node}}["name"],
          expected: {{arg.restriction.id.stringify}},
          real: val.class.to_s,
          item: {{item}}.class.to_s,
          method: {{m_name.id.stringify}},
          klass: {{k.stringify}},
        )
        raise "incorrect value type"
      end
      {% else %}
      raise "no type restriction for {{m_name}} for {{klass}}"
      {% end %}
    {% else %}

    raise "unable to set property {{m_name}} for {{klass}}"
    {% end %}
  end

  macro parse_node_props(k, items)
    {% klass = k.resolve %}
    {% map = {} of StringLiteral => HashLiteral(TypeNode, Method) %}

    {% for i in items %}
      {% map[i] = {} of TypeNode => Method %}
      {% method = i.id.underscore %}
      {% meth = klass.methods.find { |m| m.name == "#{method.id}=" } %}
      {% if meth %}
        {% map[i][klass] = meth %}
      {% end %}

      {% for sub_class in klass.resolve.all_subclasses %}
        {% if sub_class.methods.find { |m| m.name == "#{method.id}=" } %}
          {% meth = sub_class.methods.find { |m| m.name == "#{method.id}=" } %}
          {% map[i][sub_class] = meth %}
        {% end %}
      {% end %}
    {% end %}


    {% for i, ks in map %}
      {% method = i.id.underscore %}
      {% for klus, m in ks %}
        {% m_name = "_parse_xml_node_#{klus.id.underscore.gsub(/::/, "_")}_to_#{i.id}".id %}
        def {{m_name}}(node : XML::Node, item : {{klus}})
          Qt::Ui.set_node_property(node, item, {{klus.id}}, {{method.id.stringify}})
        end
      {% end %}
    {% end %}

    def parse_node_property(node : XML::Node, item : {{klass}})
      case node["name"]
      {% for i, ks in map %}
      {% method = i.id.underscore %}

      when {{i.id.stringify}}
        case item
        {% for klus, m in ks %}
        {% m_name = "_parse_xml_node_#{klus.id.underscore.gsub(/::/, "_")}_to_#{i.id}".id %}
        when {{klus}}
          {{m_name.id}}(node, item)
        {% end %}
        else
          raise "#{item.class} property \"#{node["name"]}\" is not supported"
        end
      {% end %}
      else
        logger.warn { "#{item.class} property \"#{node["name"]}\" is not supported" }
      end
    end
  end
end
