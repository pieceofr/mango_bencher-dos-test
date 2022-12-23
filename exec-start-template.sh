#!/usr/bin/env bash
source ~/.bashrc
source ~/.profile
cd ~
[[ -d "mango_bencher-dos" ]]&& rm  -rf "mango_bencher-dos"
[[ -f "start-build-dependency.sh" ]]&& rm  "start-build-dependency.sh"
[[ -f "start-dost-test.sh" ]]&& rm "start-dos-test.sh"
