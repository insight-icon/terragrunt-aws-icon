import os
from distutils.dir_util import copy_tree
from shutil import copy

config_folders = ["icon", "packer", "ansible", "Makefile", "terragrunt.hcl"]

for i in config_folders:
    if os.path.isdir("../" + i):
        copy_tree("../" + i, i)
    else:
        copy("../" + i, i)
