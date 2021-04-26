###############################################################################
#                                                                             #
# MAKEFILE for Cloak++                                                        #
#                                                                             #
# (c) Guy Wilson 2019                                                         #
#                                                                             #
###############################################################################

# Directories
SOURCE = src
BUILD = build
DEP = dep

# What is our target
TARGET = zip-test

# Tools
CPP = g++
C = gcc
LINKER = g++

# postcompile step
PRECOMPILE = @ mkdir -p $(BUILD) $(DEP)
# postcompile step
POSTCOMPILE = @ mv -f $(DEP)/$*.Td $(DEP)/$*.d

CPPFLAGS = -c -O2 -Wall -pedantic -fPIC -std=c++11 -I/opt/homebrew/include
CFLAGS = -c -O2 -Wall -pedantic -fPIC -I/opt/homebrew/include
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEP)/$*.Td

# Libraries
STDLIBS = -lstdc++
EXTLIBS = -lz

COMPILE.cpp = $(CPP) $(CPPFLAGS) $(DEPFLAGS) $(MGFLAGS) -o $@
COMPILE.c = $(C) $(CFLAGS) $(DEPFLAGS) $(MGFLAGS) -o $@
LINK.o = $(LINKER) $(STDLIBS) -L/opt/homebrew/Cellar/zlib/1.2.11/lib -L/opt/homebrew/lib -o $@

CSRCFILES = $(wildcard $(SOURCE)/*.c)
CPPSRCFILES = $(wildcard $(SOURCE)/*.cpp)
OBJFILES := $(patsubst $(SOURCE)/%.c, $(BUILD)/%.o, $(CSRCFILES)) $(patsubst $(SOURCE)/%.cpp, $(BUILD)/%.o, $(CPPSRCFILES))
OBJFILES := $(filter-out $(BUILD)/main.o, $(OBJFILES))
OBJFILES := $(filter-out $(BUILD)/node_export.o, $(OBJFILES))
DEPFILES = $(patsubst $(SOURCE)/%.c, $(DEP)/%.d, $(CSRCFILES)) $(patsubst $(SOURCE)/%.cpp, $(DEP)/%.d, $(CPPSRCFILES))

CTSTFILES = $(wildcard $(TEST)/*.c)
CPPTSTFILES = $(wildcard $(TEST)/*.cpp)
TSTOBJFILES = $(patsubst $(TEST)/%.c, $(BUILD)/%.o, $(CTSTFILES)) $(patsubst $(TEST)/%.cpp, $(BUILD)/%.o, $(CPPTSTFILES))
TSTDEPFILES = $(patsubst $(TEST)/%.c, $(DEP)/%.d, $(CTSTFILES)) $(patsubst $(TEST)/%.cpp, $(DEP)/%.d, $(CPPTSTFILES))

all: $(TARGET) $(LIBTARGET)

# Compile C/C++ source files
#
$(TARGET): $(OBJFILES) $(BUILD)/main.o $(TSTOBJFILES)
	$(LINK.o) $^ $(EXTLIBS)

$(BUILD)/%.o: $(SOURCE)/%.c
$(BUILD)/%.o: $(SOURCE)/%.c $(DEP)/%.d
	$(PRECOMPILE)
	$(COMPILE.c) $<
	$(POSTCOMPILE)

$(BUILD)/%.o: $(SOURCE)/%.cpp
$(BUILD)/%.o: $(SOURCE)/%.cpp $(DEP)/%.d
	$(PRECOMPILE)
	$(COMPILE.cpp) $<
	$(POSTCOMPILE)

$(BUILD)/%.o: $(TEST)/%.c
$(BUILD)/%.o: $(TEST)/%.c $(DEP)/%.d
	$(PRECOMPILE)
	$(COMPILE.c) $<
	$(POSTCOMPILE)

$(BUILD)/%.o: $(TEST)/%.cpp
$(BUILD)/%.o: $(TEST)/%.cpp $(DEP)/%.d
	$(PRECOMPILE)
	$(COMPILE.cpp) $<
	$(POSTCOMPILE)

.PRECIOUS = $(DEP)/%.d
$(DEP)/%.d: ;

-include $(DEPFILES)

install: $(TARGET)
	cp $(TARGET) /usr/local/bin

clean:
	rm -r $(BUILD)
	rm -r $(DEP)
	rm $(TARGET)
