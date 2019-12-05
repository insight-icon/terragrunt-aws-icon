#!/usr/bin/env bash

for d in ../*/*/*/ ; do
    find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
done

#for d in global/*/*/ ; do
#    find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
#done
