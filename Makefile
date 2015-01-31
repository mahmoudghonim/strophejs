SHELL		?= /usr/env/bin/bash
BOWER		?= node_modules/.bin/bower
GRUNT		?= ./node_modules/.bin/grunt
PHANTOMJS	?= ./node_modules/.bin/phantomjs
SRC_DIR = src
DOC_DIR = doc
DOC_TEMP = doc-temp
PLUGIN_DIR = plugins
NDPROJ_DIR = ndproj

STROPHE 	= strophe.js
STROPHE_MIN = strophe.min.js

all: normal min
normal: stamp-bower $(STROPHE)
min: stamp-bower $(STROPHE_MIN)

stamp-npm: package.json
	npm install
	touch stamp-npm

stamp-bower: stamp-npm bower.json
	$(BOWER) install
	touch stamp-bower

$(STROPHE): stamp-bower
	@@echo "Building" $(STROPHE) "..."
	$(GRUNT) concat
	@@echo

$(STROPHE_MIN): $(STROPHE)
	@@echo "Building" $(STROPHE_MIN) "..."
	$(GRUNT) min

doc:
	@@echo "Building Strophe documentation..."
	@@if [ ! -d $(NDPROJ_DIR) ]; then mkdir $(NDPROJ_DIR); fi
	@@if [ ! -d $(DOC_DIR) ]; then mkdir $(DOC_DIR); fi
	@@if [ ! -d $(DOC_TEMP) ]; then mkdir $(DOC_TEMP); fi
	@@cp $(STROPHE) $(DOC_TEMP)
	@@naturaldocs -r -ro -q -i $(DOC_TEMP) -i $(PLUGIN_DIR) -o html $(DOC_DIR) -p $(NDPROJ_DIR)
	@@echo "Documentation built."
	@@echo

release:
	@@$(GRUNT) release
	@@echo "Release created."
	@@echo

check:: stamp-bower normal
	$(PHANTOMJS) node_modules/qunit-phantomjs-runner/runner-list.js tests/strophe.html

clean:
	rm -f stamp-npm stamp-bower
	rm -rf node_modules bower_components
	@@echo "Cleaning" node_modules "..."
	@@rm -rf node_modules
	@@echo "Cleaning" $(STROPHE) "..."
	@@rm -f $(STROPHE)
	@@echo "Cleaning" $(STROPHE_MIN) "..."
	@@rm -f $(STROPHE_MIN)
	@@echo "Cleaning minified plugins..."
	@@rm -f $(PLUGIN_FILES_MIN)
	@@echo "Cleaning documentation..."
	@@rm -rf $(NDPROJ_DIR) $(DOC_DIR) $(DOC_TEMP)
	@@echo "Done."
	@@echo

.PHONY: all normal min doc release clean check
