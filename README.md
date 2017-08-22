# Crystal Bindings to Qt 5 <sup>Technology Preview</sup>

Bindings for the Qt5 Framework using [bindgen](https://github.com/Papierkorb/bindgen).

Please note that this is **not** production-ready – yet!

## Project Goals

* **Just Works™** - Drop the dependency into a project, and use it.
* Providing an API that feels native to Crystal
* Focus on the GUI components (That is, `QtCore`, `QtGui`, `QtWidgets`)

## Preview Checklist

What **works**:
* Generation of bindings that feel kinda native
* Sub-classing C++/Qt classes
  * Overriding virtual C++ methods!
* Connecting to Qt signals
* Instantiating pre-specified C++ template containers
  * `QList`, `std::vector`, and friends

What's **to be done**:
* Forwarding `qHash()` of wrapped types (to `Object#hash`)
* Integration with **LibEvent**: Right now, Qt blocks the whole thread.
* The rest of the billion Qt classes of interest

### Future

* Everything in the **to be done** category
* Integration for the `Qt Designer` UI designer
* Integration for `Qt Linguist`
  * Localization/Translation for your applications!
* UI test library, with adapter for `spec`
  * Also, actual tests - Let's catch whacko bugs right in the CI!
* Automated copy (and adaption) of the Qt documentation, for easy Crystal-specific docs
  * Haven't checked the license of the Qt docs yet though, maybe a legal issue?
* Proper bindgen documentation.  It being a complex project is no excuse to *not*
  having proper docs.

## Usage

Add this to your application's `shard.yml`:

```yaml
dependencies:
  qt5:
    github: Papierkorb/qt5.cr
    branch: master-ready-to-use
```

If you want to generate the bindings yourself, use:

```yaml
dependencies:
  qt5:
    github: Papierkorb/qt5.cr
    branch: master
```

And then run `crystal deps` and `lib/bindgen/tool.sh qt.yml` to generate them.

### Sample code

Have a look in [samples/](https://github.com/Papierkorb/qt5.cr/tree/master/samples)!

Though, to make this not look empty, here's the possibly simplest program imaginable:

```crystal
require "qt5" # Require it!

qApp = Qt::Application.new # Create the application

# Display something on the screen
label = Qt::Label.new "Hello from Crystal/Qt!"
label.show

Qt::Application.exec # And run it!
```

## Name rewriting rules

* Everything resides in the `Qt` module (As configured)
* Classes get their `Q` prefix stripped: `QWidget -> Qt::Widget`
  * This is the only manual rule.  All other rules are **automatic**.
* Method names get underscored: `addWidget() -> #add_widget`
  * Setter methods are rewritten: `setWindowTitle() -> #window_title=`
  * Getter methods are rewritten: `getWindowTitle() -> #window_title`
  * Bool getters are rewritten: `getAwesome() -> #awesome?`
  * `is` getters are rewritten: `isEmpty() -> #empty?`
  * `has` getters are rewritten: `hasSpace() -> #has_space?`
* On signal methods:
  * Keep their name for the `emit` version: `pressed() -> #pressed`
  * Get an `on_` prefix for the connect version: `#on_pressed do .. end`
* Enum fields get title-cased if not already: `color0 -> Color0`

## Dependencies

### Developing with these bindings

* `Qt5` of version Qt 5.9.x, development headers and libraries
* A modern C++ compiler

### What your user will need

* Only the `Qt5` libraries

## Contributing

1. Talk to `Papierkorb` in `#crystal-lang` about what you're gonna do.
2. You got the go-ahead?  The project's in an early state: Things may change without notice under you.
3. Then do the rest, PR and all.  You know the drill.

## Licenses

The Qt bindings, including the generated and manually-written parts, are subject
to the MPL-2 license.  You can find a copy attached of the full license text in
the `LICENSE` file.

This project claims no copyright on the `Qt framework` or of any of its
trademarks, source, or any other assets.

**Questions?** Contact [Papierkorb](https://github.com/Papierkorb).

## Contributors

- [Papierkorb](https://github.com/Papierkorb) Stefan Merettig - creator, maintainer
