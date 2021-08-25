require "ini"

LOCK_FILE = "qt5.lock"
min_version = "5.0.0"

ENV["QT_SELECT"] = "5"

# 0. Is there a binding override?
if File.exists?("#{__DIR__}/../src/qt5/binding/binding_.cr")
  puts "" # Yes, there is.  Use it!
  exit 0
end

# 1. Find project root
project_root = nil
lib_path = File.expand_path("../../../", __DIR__)
if Dir.exists?(lib_path) && File.basename(lib_path) == "lib" && Dir.exists?("#{lib_path}/qt5.cr")
  project_root = File.expand_path("..", lib_path)
else
  project_root = File.expand_path("..", __DIR__)
end

# 2. Check for the lock file
lock_file_path = "#{project_root}/#{LOCK_FILE}"
if File.exists?(lock_file_path)
  lock_file = INI.parse(File.read(lock_file_path))
  section = lock_file[""]

  min_version = section["min_version"]? || min_version
  chosen_binding = section["binding"]?
end

if chosen_binding.nil?
  detected = nil

  Dir.cd(project_root) do
    detected = `crystal run '#{__DIR__}/decide_binding_slow.cr' -- #{min_version.inspect}`.strip

    unless $?.success?
      puts detected
      raise "Support script decide_binding_slow.cr failed"
    end
  end

  raise "This shouldn't happen." if detected.nil?
  min_version, chosen_binding = detected.split(' ') # Destructure

  STDERR.puts "Using Qt #{min_version} through #{chosen_binding}"
  STDERR.puts "This will be saved in #{lock_file_path}"

  File.open(lock_file_path, "w") do |h|
    h.puts <<-EOF
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ATTENTION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; This file configures which Qt5 version your program uses.
    ;
    ; IMPORTANT: If you change this file then clear your crystal cache!
    ;            On Linux: $ rm -r ~/.cache/crystal
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; What is the minimum Qt5 version you want to use?  This is only used if
    ; no "binding" (Below) is set.
    min_version = #{min_version}

    ; Don't check-in the following lines into your repository!
    ; Generated on #{Time.local}
    binding     = #{chosen_binding}
    EOF
  end
end

# Build static library on first use.
unless File.exists?("#{__DIR__}/../ext/binding_#{chosen_binding}.a")
  chosen_version = chosen_binding[/-qt([0-9.]+)$/, 1]

  STDERR.puts "Couldn't find built version of #{chosen_binding} for Qt#{chosen_version}"
  STDERR.puts "Building now!"

  # Calls out into the slow script again to set up the build environment.
  Process.run(
    "crystal",
    [
      "run", "#{__DIR__}/decide_binding_slow.cr",
      "--",
      min_version, "make",
    ],
    env: {"QT_VERSION" => chosen_version},
    output: STDERR,
    error: STDERR,
  )
end

puts chosen_binding
