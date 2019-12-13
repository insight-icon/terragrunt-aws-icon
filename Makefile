SHELL := /usr/bin/env bash

.PHONY: help
help:
	@echo 'Usage:'
	@echo '    install-ubuntu 		Install basics to run node on mac - developers should do it manually'
	@echo '    install-mac 			Install basics to run node on ubuntu - developers should do it manually'
	@echo '    eip-register 		Register a wallet with an ICON network'
	@echo '    apply-prep-module 	Deploy a P-Rep node on ICON'
	@echo '    destroy-prep-module 	Destroy the a P-Rep node on ICON'
	@echo '    apply-prep-module 	Destroy the a P-Rep node on ICON'
	@echo '    destroy-prep-module 	Destroy the a P-Rep node on ICON'
	@echo '    clear-cache			Clear the cache of files left by terragrunt'
	@echo '    WARNING - git actions are still a WIP - PR welcome!'
	@echo '    make clone-all   						Clones all the sub repos'
	@echo '    make pull-all   							Stashes, then pulls, stash apply on all the sub repos'
	@echo '    make add-all   							Adds all the file on all the sub repos'
	@echo '    make status-all   						git status on all the the sub repos'
	@echo '    make b="<your branch name>" branch-all 	Branches all the sub repos'
	@echo '    make m="<your commit message" commit-all Clones all the sub repos'
	@echo '    make push-all 							Pushes all the sub repos'


.PHONY: install-ubuntu
install-ubuntu:
	./scripts/install-deps-ubuntu.sh

.PHONY: install-mac
install-mac:
	./scripts/install-deps-brew.sh

.PHONY: eip-register
eip-register:
	terragrunt apply --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/register

.PHONY: apply-prep-module
apply-prep-module:
	terragrunt apply-all --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/prep/prep-module

.PHONY: destroy-prep-module
destroy-prep-module:
	terragrunt destroy-all --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-exclude-external-dependencies --terragrunt-working-dir icon/prep/prep-module

.PHONY: apply-prep-basic
apply-prep-basic deploy-prep:
	terragrunt apply-all --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/prep/prep-basic

.PHONY: destroy-prep-basic
destroy-prep-basic:
	terragrunt destroy-all --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-exclude-external-dependencies --terragrunt-working-dir icon/prep/prep-basic

.PHONY: clear-cache
clear-cache:
	./scripts/clear-cache.sh

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

.PHONY: branch-all
branch-all:
	meta git checkout -b ${b}; \
	python scripts/make/subdir_cmd.py branch_all ${b}

.PHONY: add-all
add-all:
	meta git add * .*; \
	python scripts/make/subdir_cmd.py add_all

.PHONY: commit-all
commit-all:
	meta git commit -m "${m}"; \
	python scripts/make/subdir_cmd.py commit_all message="${m}"

.PHONY: push-all
push-all:
	meta git commit -m "${m}"; \
	python scripts/make/subdir_cmd.py commit_all message="${m}"


