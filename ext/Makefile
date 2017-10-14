CXXFLAGS := -Wall -Werror -Wno-unused-function -fPIC -fno-rtti -I$(QT_INCLUDE_DIR) -I.
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
	$(CC) -std=c++11 -c -o $@ $< $(CXXFLAGS)

.PHONY: clean
