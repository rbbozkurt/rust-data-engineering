SHELL := /bin/bash

SUBDIRS := $(wildcard */.)

.PHONY: help format lint test all $(SUBDIRS)

help: ## Display this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

rust-version: ## Show Rust toolchain versions
	@echo "Rust command-line utility versions:"
	@rustc --version
	@cargo --version
	@rustfmt --version
	@rustup --version
	@clippy-driver --version

format: ## Format the code
	@for dir in $(SUBDIRS); do \
		if [ -f "$$dir/Makefile" ]; then \
			echo "Formatting with Makefile in $$dir"; \
			$(MAKE) -C $$dir format; \
		elif [ -f "$$dir/Cargo.toml" ]; then \
			echo "Formatting with Cargo in $$dir"; \
			cd $$dir && cargo fmt && cd ..; \
		else \
			echo "Skipping $$dir, no Makefile or Cargo.toml found"; \
		fi \
	done

lint: ## Lint the code
	@for dir in $(SUBDIRS); do \
		if [ -f "$$dir/Makefile" ]; then \
			echo "Linting with Makefile in $$dir"; \
			$(MAKE) -C $$dir lint; \
		elif [ -f "$$dir/Cargo.toml" ]; then \
			echo "Linting with Cargo in $$dir"; \
			cd $$dir && cargo clippy && cd ..; \
		else \
			echo "Skipping $$dir, no Makefile or Cargo.toml found"; \
		fi \
	done

test: ## Run the tests
	@for dir in $(SUBDIRS); do \
		if [ -f "$$dir/Makefile" ]; then \
			echo "Testing with Makefile in $$dir"; \
			$(MAKE) -C $$dir test; \
		elif [ -f "$$dir/Cargo.toml" ]; then \
			echo "Testing with Cargo in $$dir"; \
			cd $$dir && cargo test && cd ..; \
		else \
			echo "Skipping $$dir, no Makefile or Cargo.toml found"; \
		fi \
	done

all: format lint test ## Run all the checks and tests
