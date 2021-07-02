.PHONY: all docs docs-edit docs-setup help
CODE_DIR = chain

all: help

build: ## Compile Lethean Blockchain
	$(MAKE) -C $(CODE_DIR)

docs: ## Documentation website, placed in ./public
	mkdocs build

docs-edit: ## Documentation webserver using local files with hot reload
	mkdocs serve

.ONESHELL:
docs-setup: ## Creates python virtual env and installs mkdocs
	python -m venv venv
	source ./venv/bin/activate
	pip install mkdocs-material
	pip install -r requirements.txt

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-30s\033[0m %s\n", $$1, $$2}'