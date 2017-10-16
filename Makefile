.PHONY: all compare_completeness compare_correctness clean patch alpha beta

.SUFFIXES:
.SUFFIXES: .asm .o .gbc .png .wav .wikitext
.SECONDEXPANSION:

BASE_DIR := baseroms
BUILD_DIR := build

ROMS_ALPHA := ${BUILD_DIR}/bugsite_alpha_en.gbc
BASEROM_ALPHA := ${BASE_DIR}/baserom_alpha.gbc
ROMS_BETA := ${BUILD_DIR}/bugsite_beta_en.gbc
BASEROM_BETA := ${BASE_DIR}/baserom_beta.gbc
ROMS_PATCH := ${BUILD_DIR}/bugsite_patch_en.gbc
BASEROM_PATCH := ${BASE_DIR}/baserom_patch.gbc

OBJS := component/bugvm/decode.o component/bugvm/optable.o component/bugvm/vm_state.o \
        component/windowmanager/contents_config.o component/windowmanager/drawframe.o \
        component/windowmanager/menu_config.o \
        component/mainscript/window.o \
		  component/lcdc/poke.o
OBJS_ALPHA := 
OBJS_BETA := 
OBJS_ALL := ${OBJS} ${OBJS_ALPHA} ${OBJS_BETA}

#Directory objects have to be treated separately since this makefile would
#otherwise attempt to run it through rgbasm and wonder why there's no .asm file
OBJS_DIR_ALPHA := versions/alpha/component/bugfs/directory.bugfs.o
OBJS_DIR_BETA := versions/beta/component/bugfs/directory.bugfs.o
OBJS_DIR_ALL := ${OBJS_DIR_ALPHA} ${OBJS_DIR_BETA}

OBJS_EXTRA := versions/alpha/script/encounters.atbl.o versions/beta/script/encounters.atbl.o \
	versions/alpha/script/monsters.atbl.o versions/beta/script/monsters.atbl.o \
	script/chips.atbl.o script/keyitems.atbl.o script/moves.atbl.o

#Only Python 3 is supported this time.
PYTHON := utilities/find_python.sh
PRET := pokemon-reverse-engineering-tools/pokemontools

$(foreach obj, $(OBJS), \
	$(eval $(obj:.o=)_dep := $(addprefix ${BUILD_DIR}/,$(shell $(PYTHON) utilities/scan_includes.py $(obj:.o=.asm)))) \
)

$(foreach obj, $(OBJS_ALPHA), \
	$(eval $(obj:.o=)_dep := $(addprefix ${BUILD_DIR}/,$(shell $(PYTHON) utilities/scan_includes.py $(obj:.o=.asm)))) \
)

$(foreach obj, $(OBJS_BETA), \
	$(eval $(obj:.o=)_dep := $(addprefix ${BUILD_DIR}/,$(shell $(PYTHON) utilities/scan_includes.py $(obj:.o=.asm)))) \
)

$(foreach obj, $(OBJS_DIR_ALL), \
	$(eval $(obj:.bugfs.o=)_dep := $(addprefix ${BUILD_DIR}/,$(shell $(PYTHON) utilities/bfsdeps.py $(obj:.bugfs.o=.bfs)))) \
)

# Link objects together to build a rom.
all: patch alpha beta

patch: $(ROMS_PATCH)

alpha: $(ROMS_ALPHA)

beta: $(ROMS_BETA)

# Assemble source files into objects.
# Use rgbasm -h to use halts without nops.
$(OBJS_ALL:%.o=${BUILD_DIR}/%.o): $(BUILD_DIR)/%.o : %.asm $$($$*_dep)
	@echo "Assembling" $<
	@mkdir -p $(dir $@)
	@rgbasm -h -o $@ $<

# Assemble the BugFS directory...
$(OBJS_DIR_ALL:%.bugfs.o=${BUILD_DIR}/%.bugfs.o): $(BUILD_DIR)/%.bugfs.o : %.bfs $$($$*_dep)
	@echo "Building BugFS filesystem" $<
	@mkdir -p $(dir $@)
	@$(PYTHON) utilities/bfsbuild.py $< $@ --basedir=$(BUILD_DIR)

$(ROMS_ALPHA): $(OBJS:%.o=${BUILD_DIR}/%.o) $(OBJS_DIR_ALPHA:%.o=${BUILD_DIR}/%.o) $(OBJS_ALPHA:%.o=${BUILD_DIR}/%.o) $(OBJS_EXTRA:%.o=${BUILD_DIR}/%.o)
	rgblink -n $(ROMS_ALPHA:.gbc=.sym) -m $(ROMS_ALPHA:.gbc=.map) -O $(BASEROM_ALPHA) -o $@ $^
	rgbfix -v -C -i BAUJ -k 2N -l 0x33 -m 0x1B -p 0 -r 3 -t "BUGSITE ALP" $@

$(ROMS_BETA): $(OBJS:%.o=${BUILD_DIR}/%.o) $(OBJS_DIR_BETA:%.o=${BUILD_DIR}/%.o) $(OBJS_BETA:%.o=${BUILD_DIR}/%.o) $(OBJS_EXTRA:%.o=${BUILD_DIR}/%.o)
	rgblink -n $(ROMS_BETA:.gbc=.sym) -m $(ROMS_BETA:.gbc=.map) -O $(BASEROM_BETA) -o $@ $^
	rgbfix -v -C -i BBUJ -k 2N -l 0x33 -m 0x1B -p 0 -r 3 -t "BUGSITE BET" $@

$(ROMS_PATCH): $(OBJS:%.o=${BUILD_DIR}/%.o) $(OBJS_DIR_BETA:%.o=${BUILD_DIR}/%.o) $(OBJS_BETA:%.o=${BUILD_DIR}/%.o)
	rgblink -n $(ROMS_PATCH:.gbc=.sym) -m $(ROMS_PATCH:.gbc=.map) -O $(BASEROM_PATCH) -o $@ $^
	rgbfix -C -i BBUJ -k 2N -l 0x33 -m 0x1B -p 0 -r 3 -t "BUGSITE BET" $@

# The compare target is a shortcut to check that the build doesn't change
# anything in the patch and to see how much left of the patch we need to reverse
# engineer. The compare targets should be removed once the patch is fully
# disassembled.
# More thorough comparison can be made by diffing the output of hexdump -C against both roms.
compare_correctness: $(ROMS_PATCH) $(BASEROM_PATCH)
	cmp $^

compare_completeness: $(ROMS_BETA) $(BASEROM_PATCH)
	cmp $^

# Remove files generated by the build process.
clean:
	rm -r build

#This rule is needed if we want make to not die. It expects to see .inc files in
#the build directory now that we moved all resources there. We DO want to see
#.inc files as dependencies but I can't be arsed to fiddle with any more arcane
#makefile bullshit to get it to not prefix .inc files.
$(BUILD_DIR)/%.inc: %.inc
	@mkdir -p $(dir $@)
	@cp $< $@

$(BUILD_DIR)/%.2bpp: %.png
	@echo "Building" $<
	@mkdir -p $(dir $@)
	@rgbgfx -d 2 -o $@ $<

$(BUILD_DIR)/%.1bpp: %.png
	@echo "Building" $<
	@mkdir -p $(dir $@)
	@rgbgfx -d 1 -o $@ $<

$(BUILD_DIR)/%.bof: %.bvm
	@echo "Assembling" $<
	@mkdir -p $(dir $@)
	@$(PYTHON) utilities/bvmasm.py $< --deffile script/bugvm_strings_npc.csv --deffile script/bugvm_strings_story.csv --deffile script/bugvm_strings_system.csv --autobalance --language English script/charmap.txt $@

$(BUILD_DIR)/%.palette.bin: %.bpal
	@echo "Assembling" $<
	@mkdir -p $(dir $@)
	@$(PYTHON) utilities/bpalasm.py $< $@

$(BUILD_DIR)/%.atbl.o: %.csv
	@echo "Building" $<
	@mkdir -p $(dir $@)
	@$(PYTHON) utilities/montable_compile.py --language=English $< script/charmap.txt $@

$(BUILD_DIR)/%.bin: %.bin
	@echo "Copying" $<
	@mkdir -p $(dir $@)
	@cp $< $@
