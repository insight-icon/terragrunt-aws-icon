SHELL := /usr/bin/env bash

.PHONY: help
help:
	@echo 'Usage:'
	@echo '    install-ubuntu 				Install basics to run node on mac - developers should do it manually'
	@echo '    install-mac 					Install basics to run node on ubuntu - developers should do it manually'
	@echo '    eip-register 				Register a wallet with an ICON network'
	@echo '    apply-prep-module 			Deploy a P-Rep node on ICON in default VPC'
	@echo '    destroy-prep-module 			Destroy the a P-Rep node on ICON from default VPC'
	@echo '    apply-prep-module-vpc 		Deploy the a P-Rep node on ICON within a VPC'
	@echo '    destroy-prep-module-vpc 		Destroy the a P-Rep node on ICON within VPC'
	@echo '    clear-cache					Clear the cache of files left by terragrunt'
	@echo '    WARNING - git actions are still a WIP - PR welcome!'
	@echo '    make clone-all   						Clones all the sub repos'
	@echo '    make pull-all   							Stashes, then pulls, stash apply on all the sub repos'
	@echo '    make add-all   							Adds all the file on all the sub repos'
	@echo '    make status-all   						git status on all the the sub repos'
	@echo '    make b="<your branch name>" branch-all 	Branches all the sub repos'
	@echo '    make m="<your commit message" commit-all Clones all the sub repos'
	@echo '    make push-all 							Pushes all the sub repos'


.PHONY: install-deps-ubuntu
install-deps-ubuntu:
	./scripts/install-deps-ubuntu.sh

.PHONY: install-deps-mac
install-deps-mac:
	./scripts/install-deps-brew.sh

.PHONY: clear-cache
clear-cache:
	find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \; && \
	find . -type d -name ".terraform" -prune -exec rm -rf {} \;

############
# Setup node
############
.PHONY: apply-all
apply-all: eip-register

.PHONY: destroy-all
destroy-all:

.PHONY: eip-register
eip-register:
	terragrunt apply --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/label; \
	terragrunt apply --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/register

.PHONY: apply-network
apply-network:
	terragrunt apply --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/label; \
	terragrunt apply --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/network/vpc; \
	terragrunt apply --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/vpc; \
	terragrunt apply-all --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/security-groups

.PHONY: destroy-network
destroy-network:
	terragrunt destroy --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-exclude-external-dependencies --terragrunt-working-dir icon/network/vpc
	terragrunt destroy-all --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/network/security-groups

######
# prep
######
.PHONY: apply-prep-module
apply-prep-module:
	terragrunt apply-all --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/prep/prep-module

.PHONY: destroy-prep-module
destroy-prep-module:
	terragrunt destroy-all --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-exclude-external-dependencies --terragrunt-working-dir icon/prep/prep-module

.PHONY: apply-prep-module-vpc
apply-prep-module-vpc:
	terragrunt apply-all --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/prep/prep-module-vpc

.PHONY: destroy-prep-module-vpc
destroy-prep-module-vpc:
	terragrunt destroy-all --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir icon/prep/prep-module-vpc

######################
# git actions - WIP!!!
######################

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
	python scripts/make/subdir_cmd.py stash_all ; \
	python scripts/make/subdir_cmd.py pull_all ; \
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


