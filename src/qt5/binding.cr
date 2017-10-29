# This file automatically requires the binding/*.cr as chosen in the "qt5.lock"
# file.  This file is located in your projects root.
#
# If this file doesn't exist yet, it will be generated.

{% begin %}
  {% use_binding = run("#{__DIR__}/../../support/decide_binding_fast.cr") %}
  require {{ "./binding/binding_" + use_binding.strip.stringify }}
{% end %}
