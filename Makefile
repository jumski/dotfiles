.PHONY: install

SHELL := /bin/bash

all: install

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
	git pull --ff-only

aur:
	@sudo echo -n && script/install_aur_packages

pacman:
	@sudo echo -n && script/install_pacman_packages

dotbot:
	@.dotbot/install

