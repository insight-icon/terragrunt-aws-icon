import os
from shutil import rmtree, move

PROJECT_DIR = os.path.realpath(os.path.curdir)
PARENT_DIR = os.path.dirname(PROJECT_DIR)

config_files = ['account.tfvars', 'global.yaml', 'region.tfvars', 'secrets.yaml', 'nodes.yaml']

for f in config_files:
    move(os.path.join(PROJECT_DIR, f), os.path.join(PARENT_DIR, f))

rmtree(PROJECT_DIR)
