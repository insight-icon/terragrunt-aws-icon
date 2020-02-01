#!/usr/bin/env bash
brew install terraform terragrunt packer ansible python nodejs git
npm i -g meta
pip3 install preptools cookiecutter awscli
pip install fire

# Verify
ansible --version
cookiecutter --version
terragrunt -v
terraform -v
packer -v
meta --version
