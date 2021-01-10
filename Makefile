.PHONY: help
help:
	@echo "You can run \"make\" with the following targets:"
	@echo "  - dep: install the dependencies for building the application"
	@echo "  - clean: remove built assets"
	@echo "  - build/copy: copy the static assets to destination directory"
	@echo "  - build/dev: build the development version of the application"
	@echo "  - build/dist: build the distribution version of the application"
	@echo "  - server/static: start a static file server on destination directory"

.PHONY: check/node
check/node:
	@which node > /dev/null || (echo "\"node\" not found" && return 1)

.PHONY: check/yarn
check/yarn:
	@which yarn > /dev/null || (echo "\"yarn\" not found" && return 1)

.PHONY: check/python3
check/python3:
	@which python3 > /dev/null || (echo "\"python3\" not found" && return 1)

.PHONY: check/uglifyjs
check/uglifyjs:
	@which uglifyjs > /dev/null || (echo "\"uglifyjs\" not found" && return 1)

.PHONY: dep
dep: check/node check/yarn
	@which uglifyjs > /dev/null || yarn global add uglify-js

.PHONY: clean
clean:
	@rm -rf dst
	@rm -rf elm-stuff

.PHONY: build/directories
build/directories:
	@mkdir -p dst
	@mkdir -p dst/js

.PHONY: build/copy
build/copy: build/directories
	@cp -r static/* dst

.PHONY: build/dev
build/dev: build/directories
	@elm make \
		src/Main.elm \
		--output dst/js/app.js

.PHONY: build/dist
build/dist: check/uglifyjs build/copy
	@elm make \
		src/Main.elm \
		--optimize \
		--output dst/js/app.js
	@uglifyjs dst/js/app.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output dst/js/app.js

.PHONY: server/static
server/static: build/directories check/python3
	@sleep 1 && open http://localhost:8000 &
	@cd dst && python -m http.server 2> /dev/null
