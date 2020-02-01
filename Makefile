SHELL := /bin/bash -euo pipefail

## ---------------------------------------------------------------------------------
## Makefile to run terragrunt commands to setup P-Rep nodes for the ICON Blockchain.
## ---------------------------------------------------------------------------------

help: 								## Show help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

install-deps-ubuntu:  				## Install basics to run node on ubuntu - developers should do it manually
	./scripts/install-deps-ubuntu.sh

install-deps-mac:					## Install basics to run node on mac - developers should do it manually
	./scripts/install-deps-brew.sh

clear-cache:						## Clear the terragrunt and terraform caches
	find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \; && \
	find . -type d -name ".terraform" -prune -exec rm -rf {} \;

configs-prompt:						## Prompt user to enter values into configs
	cookiecutter .

configs-from-config:				## No input generation of config files from config.yaml
	cookiecutter . --config-file=config.yaml --no-input

tg_cmd = terragrunt $(1) --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir $(2)
##########
# Register
##########
eip-register:						## Register the node by creating a static website with the appropriate information and elastic IP.  Idempotent
	$(call tg_cmd,apply,icon/label) ; \
	$(call tg_cmd,apply,icon/register)

eip-destroy:						## De-register the IP address and take down website.  Does not deregister the node
	$(call tg_cmd,destroy,icon/register)

############################
# Single node in default vpc
############################
apply-prep-module:					## Apply the simplest P-Rep node configuration
	$(call tg_cmd,apply,icon/prep/eip) ; \
	$(call tg_cmd,apply,icon/prep/prep-module)

destroy-prep-module:				## Destroy the simplest P-Rep node configuration
	$(call tg_cmd,destroy,icon/prep/prep-module)

###########################
# Single node in custom vpc
###########################
apply-prep-module-vpc: 				 ## Apply P-Rep node in custom VPC
	$(call tg_cmd,apply-all,icon/prep/prep-module-vpc)

destroy-prep-module-vpc:			## Destroy P-Rep node in custom VPC
	$(call tg_cmd,destroy,icon/prep/prep-module-vpc/prep) ;

#######################
# HA node in custom vpc
#######################
apply-prep-ha: 				 ## Apply HA P-Rep node in custom VPC
	$(call tg_cmd,apply-all,icon/prep/prep-ha)

destroy-prep-ha:			## Destroy HA P-Rep node in custom VPC
	$(call tg_cmd,destroy-all,icon/prep/prep-ha) ;

###############
# Network setup
###############
apply-network:						## Apply custom VPC
	$(call tg_cmd,apply,icon/label) ; \
	$(call tg_cmd,apply-all,icon/network) ; \
	$(call tg_cmd,apply,icon/vpc) ; \
	$(call tg_cmd,apply-all,icon/security-groups)

destroy-network:					## Destroy custom VPC
	$(call tg_cmd,destroy-all,icon/security-groups) ; \
	$(call tg_cmd,destroy-all,icon/network)

#######################
# Monitoring single ec2
#######################
apply-monitoring-ec2: 				## Apply prometheus node in custom VPC
	$(call tg_cmd,apply-all,icon/monitoring/monitoring-ec2)

destroy-monitoring-ec2:				## Destroy prometheus node in custom VPC
	$(call tg_cmd,destroy-all,icon/monitoring/monitoring-ec2)

#################
# HIDS single ec2
#################
apply-hids-ec2: 					## Apply wazuh with elasticsearch node in custom VPC
	$(call tg_cmd,apply-all,icon/hids/hids-ec2)

destroy-hids-ec2:					## Destroy HIDS with elasticsearch node in custom VPC
	$(call tg_cmd,destroy-all,icon/hids/hids-ec2)

###########
# Consul HA
###########
apply-consul-ha: 				## Apply consul cluster in custom VPC
	$(call tg_cmd,apply-all,icon/consul/consul-ha)

destroy-consul-ha:				## Destroy consul cluster in custom VPC
	$(call tg_cmd,destroy-all,icon/consul/consul-ha)

##########
# Vault HA
##########
apply-vault-ha: 				## Apply vault cluster in custom VPC
	$(call tg_cmd,apply-all,icon/vault/vault-ha)

destroy-vault-ha:				## Destroy vault cluster in custom VPC
	$(call tg_cmd,destroy-all,icon/vault/vault-ha)


######################
# git actions - WIP!!!
######################
.PHONY: clone-all					## Clone all the sub repos
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


