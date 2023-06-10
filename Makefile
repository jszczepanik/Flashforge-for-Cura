BUILD_SCRIPTS_DIR := ./
SRC_DIR := ./src/
BUILD_DIR := ./build/

PYTHON := python3
YAML_TO_JSON := $(BUILD_SCRIPTS_DIR)/yaml_to_json.py

OBJS := $(BUILD_DIR)/resources/definitions/creator_pro.def.json \
	$(BUILD_DIR)/resources/definitions/creatorpro_extruder_base.def.json \
	$(BUILD_DIR)/resources/extruders/creatorpro_extruder_1.def.json \
	$(BUILD_DIR)/resources/extruders/creatorpro_extruder_2.def.json \
	$(BUILD_DIR)/resources/meshes/FlashForge_CreatorPro.stl

.PHONY: build
build: $(OBJS)

$(BUILD_DIR)/%.def.json: $(SRC_DIR)/%.def.yml $(YAML_TO_JSON)
	@mkdir -p -- $(@D)
	@cat $< | $(PYTHON) $(YAML_TO_JSON) > $@

$(BUILD_DIR)/%.stl: $(SRC_DIR)/%.stl
	@mkdir -p -- $(@D)
	@cp -- $< $@

.PHONY: install
install: build
	@sh install.sh

.PHONY: clean
clean:
	@rm -rf -- build
