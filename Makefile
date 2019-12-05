SHELL := /usr/bin/env bash

.PHONY: help
help:
	@echo 'Usage:'
	@echo '    make clone-all        .'


.PHONY: all
all:
	meta git clone .; \
	python scripts/make/subdir_cmd.py clone_all

.PHONY: clone-all
clone-all:
	meta git clone .; \
	python scripts/make/subdir_cmd.py clone_all

.PHONY: status-all
status-all:
	meta git status .; \
	python scripts/make/subdir_cmd.py status_all

.PHONY: pull-all
pull-all:
	meta git stash .; \
	meta git pull .; \
	meta git stash apply .; \
	python scripts/make/subdir_cmd.py stash_all
	python scripts/make/subdir_cmd.py pull_all
	python scripts/make/subdir_cmd.py stash_apply_all


.PHONY: make-meta-all
make-meta-all:
	python scripts/make/subdir_cmd.py status_all

