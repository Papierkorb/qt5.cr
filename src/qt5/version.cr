module Qt
  VERSION = "0.1.0"

  QT_VERSION = (QT_VERSION_MAJOR << 16) | (QT_VERSION_MINOR << 8) | QT_VERSION_PATCH

  # Run-time version of the used Qt libraries.  The version may differ from the
  # version used at link-time.  See `Qt::QT_VERSION_STR` for the link-time
  # version.
  def self.version : String
    String.new(Qt.q_version)
  end
end
