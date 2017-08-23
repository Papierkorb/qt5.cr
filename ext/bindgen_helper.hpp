/* This file is part of bindgen
 *   See: https://github.com/Papierkorb/bindgen
 *
 * This file is licensed under the following "public domain" license.
 * IT APPLIES ONLY TO THIS FILE `bindgen_helper.h` AND NOT TO ANY OTHER FILE.
 *
 * This is free and unencumbered software released into the public domain.
 *
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 *
 * In jurisdictions that recognize copyright laws, the author or authors
 * of this software dedicate any and all copyright interest in the
 * software to the public domain. We make this dedication for the benefit
 * of the public at large and to the detriment of our heirs and
 * successors. We intend this dedication to be an overt act of
 * relinquishment in perpetuity of all present and future rights to this
 * software under copyright law.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * For more information, please refer to <http://unlicense.org/>
 */

 /*********************** TAKE CARE WHEN CHANGING THINGS ***********************
 * This file may be a symlink, pointing at the `bindgen_helper.hpp` inside the *
 * shard installation directory of `bindgen`.  It is *not* a local copy!   If  *
 * you want to make changes, make sure that you have your own copy first, and  *
 * only then do changes.  Otherwise a bindgen update may override your changes.*
 ******************************************************************************/

#include <gc/gc.h> // Boehm GC
#include <cstring>

// Helper structure to transfer a `String` between C++ and Crystal.
struct CrystalString {
  char *ptr;
  int size;
};

/* Wrapper for a Crystal `Proc`. */
template<typename T, typename ... Args>
struct CrystalProc {
  union {
    T (*withSelf)(void *, Args ...);
    T (*withoutSelf)(Args ...);
  };

  void *self;

  CrystalProc() : withSelf(nullptr), self(nullptr) { }

  inline bool isValid() const {
    return (withSelf != nullptr);
  }

  /* Fun fact: If the Crystal `Proc` doesn't capture any context, it won't
   * allocate any - But also don't expect any!  We have to accomodate for this
   * by only passing `this->self` iff it is non-NULL.
   */

  T operator()(Args ... arguments) const {
    if (this->self) {
      return this->withSelf(this->self, arguments...);
    } else {
      return this->withoutSelf(arguments...);
    }
  }
};
