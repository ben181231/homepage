.PHONY: help
help:  ## Show this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[33m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z\/_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: check/node
check/node:
	@which node > /dev/null || (echo "\"node\" not found" && return 1)

.PHONY: check/yarn
check/yarn:
	@which yarn > /dev/null || (echo "\"yarn\" not found" && return 1)

.PHONY: dep ## Install the dependencies for building the application
dep: check/node check/yarn
	@yarn install

.PHONY: clean
clean: ## Remove built assets
	@rm -rf dist
	@rm -rf elm-stuff

.PHONY: build/directories
build/directories:
	@mkdir -p dist
	@mkdir -p dist/js

.PHONY: build/copy
build/copy: build/directories ## Copy the static assets to destination directory
	@cp -r static/* dist

.PHONY: build/dev
build/dev: build/directories
	@yarn run -s elm make \
		src/Main.elm \
		--output dist/js/app.js

.PHONY: build/dist
build/dist: build/copy ## Build the distribution version of the application
	@yarn run -s elm make \
		src/Main.elm \
		--optimize \
		--output dist/js/app.js
	@yarn run -s uglifyjs dist/js/app.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | yarn run -s uglifyjs --mangle --output dist/js/app.js

.PHONY: server/static
server/static: build/directories ## Start a static file server on destination directory
	@yarn run -s serve dist
