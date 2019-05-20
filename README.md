# Crystal Bindings to Qt 5 <sup>Beta</sup>

Bindings for the Qt5 Framework using [bindgen](https://github.com/Papierkorb/bindgen).

### Platform support

| System            | Status           | Qt version | OOTB?   |
| ----------------- | ---------------- | ---------- | ------- |
| ArchLinux         | **Works always** | 5.12       | **YES** |
| Ubuntu 17.04      | **Works**        | 5.9        | **YES** |
| Ubuntu 16.04      | **Works**        | 5.5        | **YES** |
| MacOS             | Help wanted      | ?          | ?       |
| Windows           | Help wanted      | ?          | ?       |
| Other systems     | Help wanted      | ?          | ?       |

**Ready-to-use Qt versions:** 5.5 to 5.12

## Project Goals

* **Just Works™** - Drop the dependency into a project, and use it.
* Providing an API that feels native to Crystal
* Focus on the GUI components (That is, `QtCore`, `QtGui`, `QtWidgets`)

## Usage

Add this to your application's `shard.yml`:

```yaml
dependencies:
  qt5:
    github: Papierkorb/qt5.cr
    branch: master-ready-to-use
```

Your users will **require the Qt5 libraries** on their system.

### Additional development dependencies

Using your systems package manager:

* **ArchLinux** `pacman -S qt5-base`
* **Debian** `apt-get install qtbase5-dev`
* **Ubuntu** `apt-get install qtbase5-dev`

### Sample code

Have a look in [samples/](https://github.com/Papierkorb/qt5.cr/tree/master/samples)!

A short **Hello World** snippet looks like this:

```crystal
require "qt5" # Require it!

qApp = Qt::Application.new # Create the application

# Display something on the screen
label = Qt::Label.new "Hello from Crystal/Qt!"
label.show

Qt::Application.exec # And run it!
```

![hello-qt](https://raw.githubusercontent.com/Papierkorb/qt5.cr/master/images/hello-qt.png)

### A note on Qt's license

A common misconception is that you have to pay for Qt to use it in closed-source
applications.

This project assumes you'll link to Qt dynamically.  In this case, you can use
**Qt free of charge** including for **closed-source, commercial applications**
under the terms of the **LGPL**.

You can build closed-source applications using Crystal, this shard, and Qt
**for free**.

**Note**: This section is to combat this misconception, the authors of `qt5.cr`
are in no way responsible to check if the same terms apply **in your jurisdiction**.

## Generating the bindings

If you want to work on `qt5.cr` itself, or have a custom build of Qt you want to
use, you'll have to generate the bindings yourself.

These steps can be followed from a project using `qt5.cr`, or from within
`qt5.cr` itself.  For the latter, just check out the `master` branch instead
of changing a `shard.yml`.

**Important**: For this you'll also have to meet the dependencies of bindgen.

### Naming scheme

As `qt5.cr` supports many different versions of Qt on different platforms,
generated bindings follow a naming scheme.  The scheme is as follows:

* `KERNEL-LIB_C-ARCH-qtVERSION`, e.g. `linux-gnu-x86_64-qt5.10`
* `KERNEL` is the OS kernel, e.g. `linux`, `darwin`, `windows`
* `LIB_C` is the lib C name, e.g. `gnu`, `musl`, `win32`
* `ARCH` is the architecture, e.g. `i686`, `x86_64`, `arm`
* `VERSION` is the Qt version, e.g. `5.5`, `5.6`, ...

The naming scheme is not strictly enforced.  However, it should always end with
`-qtVERSION`!

### Generating all binding versions

The `master-ready-to-use` branch is built using this method:

1. Change into the `qt5.cr` directory
2. If you want to change which bindings to generate, edit `support/generate_bindings.cr`
3. Run `crystal support/generate_bindings.cr`

The script will automatically download, unpack, build and generate all
configured versions of Qt.  It'll store the Qt5 versions in a directory called
`download_cache/`.  Subsequent invocations of that script will use these cached
assets.  **The first run may take a long time**.

### Generating a specific binding version

1. Use the `master` branch of `qt5.cr` in your `shard.yml`
2. Run `crystal deps` to download dependencies
3. Decide which version of Qt to use, and build the scheme (See above)
4. Export the binding scheme: `export BINDING_PLATFORM=linux-gnu-x86_64-qt5.10`
5. If you're not using your systems Qt: `export QMAKE=/path/to/qmake`
6. Run bindgen: `lib/bindgen/tool.sh qt.yml --stats`
7. Verify: `crystal spec`

## Future things to do

* Forwarding `qHash()` of wrapped types (to `Object#hash`)
* Integration with **LibEvent**: Right now, Qt blocks the whole thread.
* The rest of the billion Qt classes of interest
* Everything in the **to be done** category
* Integration for the `Qt Designer` UI designer
* Integration for `Qt Linguist`
  * Localization/Translation for your applications!
* UI test library, with adapter for `spec`
  * Also, actual tests - Let's catch whacko bugs right in the CI!
* Automated copy (and adaption) of the Qt documentation, for easy Crystal-specific docs
  * The Qt Docs license should allow this if done correctly

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
