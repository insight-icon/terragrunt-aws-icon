SHELL := /bin/bash -euxo pipefail

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


install-deps-ubuntu:
	./scripts/install-deps-ubuntu.sh

install-deps-mac:
	./scripts/install-deps-brew.sh

clear-cache:
	find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \; && \
	find . -type d -name ".terraform" -prune -exec rm -rf {} \;

tg_cmd = terragrunt $(1) --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir $(2)

##########
# Register
##########
eip-register:
	$(call tg_cmd,apply,icon/label) ; \
	$(call tg_cmd,apply,icon/register)

eip-destroy:
	$(call tg_cmd,destroy,icon/register)

############################
# Single node in default vpc
############################
apply-prep-module:
	$(call tg_cmd,apply,icon/prep/eip) ; \
	$(call tg_cmd,apply,icon/prep/prep-module)

destroy-prep-module:
	$(call tg_cmd,destroy,icon/prep/prep-module)

###########################
# Single node in custom vpc
###########################
apply-prep-module-vpc: apply-network
	$(call tg_cmd,apply-all,icon/prep/prep-module-vpc)

destroy-prep-module-vpc:
	$(call tg_cmd,destroy,icon/prep/prep-module-vpc/prep) ; \
	$(MAKE) destroy-network

###############
# Network setup
###############
apply-network:
	$(call tg_cmd,apply,icon/label) ; \
	$(call tg_cmd,apply,icon/network/vpc) ; \
	$(call tg_cmd,apply,icon/vpc) ; \
	$(call tg_cmd,apply-all,icon/security-groups)

destroy-network:
	$(call tg_cmd,destroy-all,icon/security-groups) ; \
	$(call tg_cmd,destroy,icon/network/vpc)

######################
# git actions - WIP!!!
######################
.PHONY: clone-all
clone-all:
	meta git clone .; \
	python scripts/subdir_cmd.py clone_all

.PHONY: status-all
status-all:
	meta git status .; \
	python scripts/subdir_cmd.py status_all

.PHONY: pull-all
pull-all:
	meta git stash .; \
	meta git pull .; \
	meta git stash apply .; \
	python scripts/subdir_cmd.py stash_all ; \
	python scripts/subdir_cmd.py pull_all ; \
	python scripts/subdir_cmd.py stash_apply_all

.PHONY: branch-all
branch-all:
	meta git checkout -b ${b}; \
	python scripts/subdir_cmd.py branch_all ${b}

.PHONY: add-all
add-all:
	meta git add * .*; \
	python scripts/subdir_cmd.py add_all

.PHONY: commit-all
commit-all:
	meta git commit -m "${m}"; \
	python scripts/subdir_cmd.py commit_all message="${m}"

.PHONY: push-all
push-all:
	meta git commit -m "${m}"; \
	python scripts/subdir_cmd.py commit_all message="${m}"


