CXXFLAGS := -Wall -Wno-unused-function -fPIC -fno-rtti -I$(QT_INCLUDE_DIR) -I.
CPPFILES := qt_binding_$(BINDING_PLATFORM).cpp
OBJFILES := $(CPPFILES:.cpp=.o)
LIBFILE  := binding_$(BINDING_PLATFORM).a

CC ?= g++
AR ?= ar
RM ?= rm

all: $(LIBFILE)

clean:
	$(RM) -f $(OBJFILES)
	$(RM) -f $(LIBFILE)

$(LIBFILE): $(OBJFILES)
	$(AR) rcs $@ $^

%.o: %.cpp
	$(CC) -std=c++11 -c -o $@ $< $(CXXFLAGS)

.PHONY: clean
