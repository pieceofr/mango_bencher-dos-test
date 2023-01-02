#!/usr/bin/env bash
set -x
source ~/.bashrc
source ~/.profile
cd ~
upload_file() {
	gsutil cp  $1 gs://mango_bencher-dos/$2

}

[[ ! "$BUILD_DEPENDENCY_BENCHER_DIR" ]]&& echo no BUILD_DEPENDENCY_BENCHER_DIR && exit 1
[[ ! "$BUILD_DEPENDENCY_CONFIGUERE_DIR" ]]&& echo no BUILD_DEPENDENCY_CONFIGUERE_DIR && exit 1
ls -al
# upload_file $BUILD_DEPENDENCY_CONFIGUERE_DIR/$HOSTNAME-keeper.log Log
# upload_file $BUILD_DEPENDENCY_BENCHER_DIR/target/release/$HOSTNAME-TLOG.csv Log
# upload_file $BUILD_DEPENDENCY_BENCHER_DIR/target/release/$HOSTNAME-BLOCK.csv Log
# upload_file $BUILD_DEPENDENCY_BENCHER_DIR/target/release/$HOSTNAME-error.txt Log

upload_file $HOME/$HOSTNAME-keeper.log Log
upload_file $HOME/$HOSTNAME-TLOG.csv Log
upload_file $HOME/$HOSTNAME-BLOCK.csv Log
upload_file $HOME/$HOSTNAME-error.txt Log
