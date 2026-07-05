# ── Help ──────────────────────────────────────────────────────────────────────
.PHONY: help
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-35s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: ## Remove build artifacts from build folder
	@cd build && \
		rm -rf CMakeCache.txt CMakeFiles Makefile cmake_install.cmake src

.PHONY: all
all: ## Build all examples
	@mkdir -p build
	@cd build && \
		cmake -DCMAKE_BUILD_TYPE=Release .. && \
		make -j $(nproc)

.PHONY: all_debug
all_debug: ## Build all examples with Debug build
	@mkdir -p build
	@cd build && \
		cmake -DCMAKE_BUILD_TYPE=Debug .. && \
		make -j $(nproc)

.PHONY: build_example
build_example: ## Build individual example(s). usage make build_example EXAMPLES=01_hello_world
	@mkdir -p build
	@cd build && \
		cmake -DCMAKE_BUILD_TYPE=Debug -DBUILD_EXAMPLE=$(BUILD_EXAMPLE) .. && \
		make -j $(nproc)
