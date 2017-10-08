module Qt
  VERSION = "0.1.0"

  # Run-time version of the used Qt libraries.  The version may differ from the
  # version used at link-time.  See `Qt::QT_VERSION_STR` for the link-time
  # version.
  def self.version : String
    String.new(Qt.q_version)
  end
end
