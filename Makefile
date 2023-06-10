BUILD_SCRIPTS_DIR := ./
SRC_DIR := ./src/
BUILD_DIR := ./build/
CURA_DOCS_DIR := ./cura_docs/

PYTHON := python3
YAML_TO_JSON := $(BUILD_SCRIPTS_DIR)/yaml_to_json.py

OBJS := $(BUILD_DIR)/resources/definitions/creator_pro.def.json \
	$(BUILD_DIR)/resources/definitions/creatorpro_extruder_base.def.json \
	$(BUILD_DIR)/resources/extruders/creatorpro_extruder_1.def.json \
	$(BUILD_DIR)/resources/extruders/creatorpro_extruder_2.def.json \
	$(BUILD_DIR)/resources/meshes/FlashForge_CreatorPro.stl

# Cura 5.3.1 https://github.com/Ultimaker/Cura/releases/tag/5.3.1
CURA_GIT_REPO_DIR := $(BUILD_DIR)/Cura.git/
CURA_GIT_REPO_URL := https://github.com/Ultimaker/Cura.git
CURA_GIT_REF := ac43ddd91ee7e373a3ae5d62fd7061f130847f7a
# Cura's GitHub Wiki. Latest commit at the time of writing this script
CURA_WIKI_GIT_REPO_DIR := $(BUILD_DIR)/Cura.Wiki.git/
CURA_WIKI_GIT_REPO_URL := https://github.com/Ultimaker/Cura.wiki.git
CURA_WIKI_GIT_REF := 672c7dd96e26173d617dbb772bd0e4e753163ad3


.PHONY: build
build: $(OBJS)

$(BUILD_DIR)/%.def.json: $(SRC_DIR)/%.def.yml $(YAML_TO_JSON)
	mkdir -p -- $(@D)
	cat $< | $(PYTHON) $(YAML_TO_JSON) > $@

$(BUILD_DIR)/%.stl: $(SRC_DIR)/%.stl
	mkdir -p -- $(@D)
	cp -- $< $@


.PHONY: download_cura_docs
download_cura_docs: $(CURA_DOCS_DIR)/fdmprinter.def.json \
	$(CURA_DOCS_DIR)/fdmextruder.def.json \
	$(CURA_DOCS_DIR)/wiki

$(CURA_DOCS_DIR)/fdmprinter.def.json: $(CURA_GIT_REPO_DIR)/resources/definitions/fdmprinter.def.json
	mkdir -p -- $(@D)
	cp -- $< $@

$(CURA_DOCS_DIR)/fdmextruder.def.json: $(CURA_GIT_REPO_DIR)/resources/definitions/fdmextruder.def.json
	mkdir -p -- $(@D)
	cp -- $< $@

$(CURA_DOCS_DIR)/wiki: $(CURA_WIKI_GIT_REPO_DIR)
	mkdir -p -- $@
	git -C $< checkout-index -f -a --prefix=$$(realpath $@)/

# GitHub does not support `git archive --remote=`, so we're using
# checkout magic to download the files that we want without
# downloading the whole repo.
$(CURA_GIT_REPO_DIR):
	git clone --depth=1 --filter=blob:none --sparse --single-branch --no-checkout -- $(CURA_GIT_REPO_URL) $@
	git -C $@ fetch --depth=1 origin $(CURA_GIT_REF)
	git -C $@ reset --hard $(CURA_GIT_REF)
	git -C $@ sparse-checkout init

$(CURA_GIT_REPO_DIR)/%: $(CURA_GIT_REPO_DIR)
	git -C $(BUILD_DIR)/Cura.git sparse-checkout add $*

$(CURA_WIKI_GIT_REPO_DIR):
	mkdir -p -- $(@D)
	git clone --depth=1 --filter=blob:none --single-branch --no-checkout -- $(CURA_WIKI_GIT_REPO_URL) $@
	git -C $@ fetch --depth=1 origin $(CURA_WIKI_GIT_REF)
	git -C $@ reset --hard $(CURA_WIKI_GIT_REF)
	git -C $@ checkout $(CURA_WIKI_GIT_REF) .


.PHONY: install
install: build
	sh install.sh


.PHONY: clean
clean:
	rm -rf -- $(BUILD_DIR) $(CURA_DOCS_DIR)
