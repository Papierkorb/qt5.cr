module Qt
  class Url
    @[Flags]
    enum FormattingOptions : UInt32
      # This thing is actually a combination from the following two enums.  And
      # it's not documented.  As there's little reason to extend `bindgen` for a
      # QUrl-local feature, we'll create this flags type manually.

      # Secondly, the enum `UrlFormattingOption` has a `None` constant.  This is
      # a flags type however, and Crystal doesn't like us adding one.  This
      # isn't too bad, as Qt's `None` is zero, same as what Crystal will
      # generate.

      {% for name in FormattingOption.constants.reject { |x| x.stringify == "None" } %}
        {{ name }} = {{ FormattingOption.constant(name) }}
      {% end %}

      {% for name in ComponentFormattingOption.constants %}
        {{ name }} = {{ ComponentFormattingOption.constant(name) }}
      {% end %}
    end
  end
end
