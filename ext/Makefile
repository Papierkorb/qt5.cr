CXXFLAGS := -fPIC -fno-rtti -I/usr/include/qt -I.
CPPFILES := qt_binding.cpp
OBJFILES := $(CPPFILES:.cpp=.o)

CC ?= g++
AR ?= ar
RM ?= rm

all: binding.a

clean:
	$(RM) -f $(OBJFILES)
	$(RM) -f binding.a

binding.a: $(OBJFILES)
	$(AR) rcs $@ $^

%.o: %.cpp
	$(CC) -c -o $@ $< $(CXXFLAGS)

.PHONY: clean
