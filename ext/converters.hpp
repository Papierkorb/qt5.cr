#include <gc/gc.h> // Boehm GC
#include <cstring>
#include <QtCore/qbytearray.h>
#include <QtCore/qstring.h>

#include "bindgen_helper.hpp"

// Converts a QString into a CrystalString, whose definition is mirrored in
// Crystal and is then turned into a Crystal `String`.
static CrystalString qstring_to_crystal(const QString &str) {
  // FIXME: This is horrible.
  QByteArray utf8 = str.toUtf8();
  int size = utf8.size();

  char *buffer = static_cast<char *>(GC_MALLOC_ATOMIC(size));
  memcpy(buffer, utf8.constData(), size);

  return CrystalString{ buffer, size };
}
