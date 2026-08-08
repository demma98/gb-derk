# project
PROJECT_NAME := derk

# gb = Gameboy, gbcc = Gameboy Color compatible, gbc = Gameboy Color only
PROJECT_TYPE := gb


# rom
ROM_TITLE 	:= DERK	# truncated to 15 characters
ROM_VERSION := 0x00

SOURCE_DIR	:= ./src
BUILD_DIR 	:= ./build
DEBUG_DIR	:= ./debug
OBJECT_DIR	:= ./obj
INCLUDE_DIR	:= ./include


# toolchain
RGBASM	:= rgbasm
RGBLINK	:= rgblink
RGBFIX	:= rgbfix

TARGET_EXEC	:= $(PROJECT_NAME)


# extension file form type

ROM_EXT_gb	:= gb
ROM_EXT_gbcc:= gb
ROM_EXT_gbc	:= gbc

ROM_EXT		:= $(ROM_EXT_$(PROJECT_TYPE))

# rom name
ROM	:= $(BUILD_DIR)/$(PROJECT_NAME).$(ROM_EXT)

# flags
FIX_TYPE_gb		:=
FIX_TYPE_gbcc	:= -c
FIX_TYPE_gbc	:= -C

ASM_FLAGS	:= 
LINK_FLASG	:= -m $(DEBUG_DIR)/$(PROJECT_NAME).map -n $(DEBUG_DIR)/$(PROJECT_NAME).sym
FIX_FLAGS	:= -v -p 0 -t "$(ROM_TITLE)" -n $(ROM_VERSION) --non-japanese -f lhg $(FIX_TYPE_$(PROJECT_TYPE))


# find asm files
SOURCE_FILES	:= $(shell find $(SOURCE_DIR) -name "*.asm")
INCLUDE_FILES := $(shell find $(INCLUDE_DIR) -type f)
OBJECT_FILES	:= $(patsubst $(SOURCE_DIR)/%.asm, $(OBJECT_DIR)/%.o, $(SOURCE_FILES))


# targets
.PHONY: all create_dir fix

all: create_dir compile fix


# create directories if necessary
create_dir:
	@echo creating directories...
	@mkdir -p $(BUILD_DIR) $(DEBUG_DIR) $(OBJECT_DIR)


# compile rules
compile: $(OBJECT_FILES)

$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.asm $(INCLUDE_FILES)
	@mkdir -p $(dir $@)
	$(RGBASM) -o $@ $<


# link
$(ROM): $(OBJECT_FILES)
	$(RGBLINK) $(LINK_FLAGS) -o $@ $^

# fix
fix: $(ROM)
	$(RGBFIX) $(FIX_FLAGS) $<

#clear
clear:
	@rm -rf $(OBJECT_DIR)
