#!/usr/bin/env crystal

# This script downloads all sources of all supported Qt5 versions, and then
# proceed to generate all bindings for all configured platforms.
#
# This script is what the `ready-to-use` branches are built by.

require "file_utils"
require "colorize"
require "ini"

configurations = [
#      OS       LIBC   ARCH      Qt     Clang target triplet      Ptr  Endian
  { "linux", "gnu", "x86_64", "5.5",  "x86_64-unknown-linux-gnu", 8, "little" },
  { "linux", "gnu", "x86_64", "5.6",  "x86_64-unknown-linux-gnu", 8, "little" },
  { "linux", "gnu", "x86_64", "5.7",  "x86_64-unknown-linux-gnu", 8, "little" },
  { "linux", "gnu", "x86_64", "5.8",  "x86_64-unknown-linux-gnu", 8, "little" },
  { "linux", "gnu", "x86_64", "5.9",  "x86_64-unknown-linux-gnu", 8, "little" },
  { "linux", "gnu", "x86_64", "5.10", "x86_64-unknown-linux-gnu", 8, "little" },
]

TEMPDIR = File.real_path("#{__DIR__}/../download_cache")

struct QtVersion
  getter name : String
  delegate to_s, to: @name

  def initialize(@name)
  end

  def download_url
    "https://download.qt.io/archive/qt/#{@name}/#{@name}.0/single/qt-everywhere-opensource-src-#{@name}.0.tar.xz"
  end

  def archive_path
    "#{TEMPDIR}/qt-everywhere-opensource-src-#{@name}.0.tar.xz"
  end

  def path
    "#{TEMPDIR}/qt-everywhere-opensource-src-#{@name}.0"
  end
end

class TargetPlatform
  getter os : String
  getter libc : String
  getter arch : String
  getter qt : QtVersion
  getter triple : String
  getter pointer_size : Int32
  getter endian : String

  def initialize(@os, @libc, @arch, qt, @triple, @pointer_size, @endian)
    @qt = QtVersion.new(qt)
  end

  def target
    "#{@os}-#{@libc}-#{@arch}-qt#{@qt}"
  end
end

def report(current, total, message)
  cur_s = (current + 1).to_s
  total_s = total.to_s

  step_s = "#{cur_s.ljust(total_s.size)}/#{total_s}".colorize.mode(:bold)
  puts "(#{step_s})  #{message}"
end

def report_step(message)
  puts "=> #{message}".colorize.mode(:bold)
end

def download_missing_qts(versions)
  urls = versions
    .reject{|v| File.file? v.archive_path}
    .map{|v| v.download_url}

  if urls.empty?
    report_step "All Qt sources already present"
    return
  end

  arguments = [ "--remote-name-all", "--location" ] + urls

  report_step "Downloading missing Qt sources"
  Dir.cd TEMPDIR do
    system("curl", arguments)
  end
end

def unpack_qts(versions)
  files = versions
    .reject{|v| Dir.exists? v.path}
    .map{|v| v.archive_path}

  if files.empty?
    report_step "All Qt sources already unpacked"
    return
  end

  report_step "Unpacking Qt sources"
  files.each_with_index do |file, idx|
    report(idx, files.size, "Unpacking #{file}")
    system("tar", [ "-C", TEMPDIR, "-xf", file ])
  end
end

def get_qt_modules_from_gitmodules(version)
  # This is actually how they're aggregating which modules exist in `qt.pro`
  modules_file = "#{version.path}/.gitmodules"

  if File.exists? modules_file
    data = INI.parse File.read(modules_file)
    data
      .reject{|_, v| v["qt"]? == "false"}
      .map{|k, _| k[/submodule "qt(.*)"/, 1]?}
  end
end

def get_qt_modules_from_qtpro(version)
  # For Qt5.5 and below
  pro_file = "#{version.path}/qt.pro"

  if File.exists? pro_file
    File.each_line(pro_file)
      .grep(/^addModule\(qt/)
      .map{|x| x[/addModule\(qt([^,)]+)/, 1]?}
      .to_a
  end
end

def get_qt_modules(version) : Array(String)
  modules = get_qt_modules_from_gitmodules(version)
  modules ||= get_qt_modules_from_qtpro(version)

  if modules
    modules
      .compact
      .select{|name| Dir.exists?("#{version.path}/qt#{name}")}
  else
    Array(String).new
  end
end

def configure_qts(versions)
  keep_modules = { "base" }
  list = versions.reject{|v| File.executable? "#{v.path}/qtbase/bin/qmake"}

  if list.empty?
    report_step "All Qt sources already configured"
    return
  end

  report_step "Configuring Qt versions"
  list.each_with_index do |qt, idx|
    report(idx, list.size, "Configuring Qt#{qt}")

    skip_modules = get_qt_modules(qt).reject{|x| keep_modules.includes? x}
    skip_args = skip_modules.flat_map{|x| [ "-skip", x ]}

    Dir.cd qt.path do
      system( # Build QMake of this version
        "./configure",
        [
          "-opensource", "-confirm-license",
          "-nomake", "examples",
          "-nomake", "tests",
          "-nomake", "tools",
          "-prefix", "#{qt.path}/qtbase",
        ] + skip_args,
      )

      unless $?.success?
        STDERR.puts "Failed to configure Qt#{qt} in #{qt.path} - Abort."
        exit 2
      end
    end

    # Use QMake to generate all missing include files
    system("make", [ "-C", qt.path, "qmake_all" ])

    unless $?.success?
      STDERR.puts "Failed to generate headers for Qt#{qt} in #{qt.path} - Abort."
      exit 2
    end
  end
end

# Kick off
FileUtils.mkdir_p(TEMPDIR)
platforms = configurations.map{|x| TargetPlatform.new(*x)}
versions = platforms.map(&.qt).uniq

# Download and unpack Qt sources
download_missing_qts(versions)
unpack_qts(versions)
configure_qts(versions)

# Run bindgen for all configured platforms
report_step "Generating bindings for all platforms"
platforms.each_with_index do |platform, idx|
  env = { # Set environment variables for `config/find_paths.yml`
    "QTDIR" => platform.qt.path,
    "QMAKE" => "#{platform.qt.path}/qtbase/bin/qmake",
    # "QT_INCLUDE_DIR" => Auto configured,
    "QT_LIBS_DIR" => "#{platform.qt.path}/qtbase/libs",
    "TARGET_TRIPLE" => platform.triple,
    "BINDING_PLATFORM" => platform.target,
  }

  args = [ # Arguments to bindgen
    "qt.yml",
    "--var", "architecture=#{platform.arch}",
    "--var", "libc=#{platform.libc}",
    "--var", "os=#{platform.os}",
    "--var", "pointersize=#{platform.pointer_size}",
    "--var", "endian=#{platform.endian}",
  ]

  report(idx, platforms.size, "Generating #{platform.target}")
  bindgen = Process.run( # Run bindgen
    command: "lib/bindgen/tool.sh",
    args: args,
    env: env,
    shell: false,
    output: STDOUT,
    error: STDERR,
  )

  unless bindgen.success?
    STDERR.puts "Failed to build #{platform.target} using Qt#{platform.qt} on #{platform.triple} - Abort."
    exit 1
  end
end
