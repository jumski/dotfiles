.PHONY: install

SHELL := /bin/bash

all: sync

sync: refuse-dirty-repo pull install
	@echo "Repository synchronized."

install:
	@script/install

refuse-dirty-repo:
	@git diff --quiet && git diff --cached --quiet || { \
		echo "Error: The repository is dirty. Please commit or stash your changes."; \
		exit 1; \
	}

pull:
	git pull --ff-only && exit 1
