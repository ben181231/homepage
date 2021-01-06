.PHONY: build
build:
	@elm make \
		src/Main.elm \
		--output dst/index.html

.PHONY: dev
dev:
	@sleep 1 && open http://localhost:8080/src/Main.elm &
	@elm reactor --port 8080
