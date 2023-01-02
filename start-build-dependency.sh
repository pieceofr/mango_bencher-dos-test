#!/usr/bin/env bash
## env
set -ex
## Check ENV
[[ ! "$BUILD_DEPENDENCY_BENCHER_DIR" ]]&& BUILD_DEPENDENCY_BENCHER_DIR=$HOME/mango_bencher
[[ ! "$BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR" ]]&& BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR=$HOME/mango_bencher/deps
[[ ! "$BUILD_DEPENDENCY_CONFIGUERE_DIR" ]]&& BUILD_DEPENDENCY_CONFIGUERE_DIR=$HOME/configure_mango
[[ ! "$SOLANA_BUILD_BRANCH" ]]&&[[ ! "$SOLANA_GIT_COMMIT" ]]&& echo No SOLANA_BUILD_BRANCH or SOLANA_GIT_COMMIT > env.output && exit 1
[[ ! "$SOLANA_REPO" ]]&& echo no SOLANA_REPO=$SOLANA_REPO&& exit 1
[[ ! "$MANGO_BENCHER_REPO" ]]&&  echo no MANGO_BENCHER_REPO=$MANGO_BENCHER_REPO&& exit 1
[[ ! "$MANGO_BENCHER_BRANCH" ]]&&  echo no MANGO_BENCHER_BRANCH=$MANGO_BENCHER_BRANCH&& exit 1
[[ ! "$MANGO_CONFIGURE_REPO" ]]&&  echo no MANGO_CONFIGURE_REPO=$MANGO_CONFIGURE_REPO&& exit 1
[[ ! "$MANGO_CONFIGURE_BRANCH" ]]&&  echo no MANGO_CONFIGURE_BRANCH=$MANGO_CONFIGURE_BRANCH&& exit 1
[[ ! "$ACCOUNTS" ]]&&  echo no ACCOUNTS=$ACCOUNTS&& exit 1
[[ ! "$AUTHORITY_FILE" ]] &&  echo no AUTHORITY_FILE=$AUTHORITY_FILE&& exit 1
[[ ! "$ID_FILE" ]] &&  echo no ID_FILE=$ID_FILE&& exit 1
[[ ! "$CHANNEL" ]]&& CHANNEL=stable && echo No CHANNEL , use $CHANNEL
[[ ! "$RUST_VER" ]]&& RUST_VER=default && echo No RUST_VER use $RUST_VER 

# Printout Env
[[ -f "env.output" ]]&& rm env.output
echo BUILD_DEPENDENCY_BENCHER_DIR: $BUILD_DEPENDENCY_BENCHER_DIR >> env.output
echo BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR: $BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR >> env.output
echo BUILD_DEPENDENCY_CONFIGUERE_DIR: $BUILD_DEPENDENCY_CONFIGUERE_DIR >> env.output
echo SOLANA_BUILD_BRANCH: $SOLANA_BUILD_BRANCH >> env.output
echo SOLANA_GIT_COMMIT: $SOLANA_GIT_COMMIT >> env.output
echo SOLANA_REPO: $SOLANA_REPO >> env.output
echo MANGO_BENCHER_REPO: $MANGO_BENCHER_REPO >> env.output
echo MANGO_BENCHER_BRANCH: $MANGO_BENCHER_BRANCH >> env.output
echo MANGO_BENCHER_REPO: $MANGO_BENCHER_REPO >> env.output
echo MANGO_BENCHER_BRANCH: $MANGO_BENCHER_BRANCH >> env.output
echo ACCOUNTS: $ACCOUNTS >> env.output
echo AUTHORITY_FILE: $AUTHORITY_FILE >> env.output
echo ID_FILE: $ID_FILE >> env.output
echo CHANNEL: $CHANNEL >> env.output
echo RUST_VER: $RUST_VER >> env.output

## preventing lock-file build fail, 
## also need to disable software upgrade in image
sudo fuser -vki -TERM /var/lib/dpkg/lock /var/lib/dpkg/lock-frontend || true
sudo dpkg --configure -a
sudo apt update
## pre-install and rust version
sudo apt-get install -y libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang cmake make libprotobuf-dev protobuf-compiler
rustup default stable
rustup update

cd $HOME
[[ -d "$BUILD_DEPENDENCY_BENCHER_DIR" ]]&& rm -rf mango_bencher
# clone mango_bencher and mkdir dep dir
git clone $MANGO_BENCHER_REPO
if [[ -d "$BUILD_DEPENDENCY_BENCHER_DIR" ]];then
    mkdir $BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR
else
    exit 1
fi
cd $BUILD_DEPENDENCY_BENCHER_DIR
git submodule update --init --recursive
# build solana b4 build mango
cd $BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR
git clone $SOLANA_REPO
cd $BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR/solana
if [[ "$SOLANA_GIT_COMMIT" ]];then
    git checkout $SOLANA_GIT_COMMIT
elif [[ "$SOLANA_BUILD_BRANCH" ]];then
    git checkout $SOLANA_BUILD_BRANCH
else 
    exit 1
fi
git branch || true
# move to mango_bencher and build mango_bencher
cd $BUILD_DEPENDENCY_BENCHER_DIR
cargo build --release

## Download key files from gsutil
download_file() {
	for retry in 0 1
	do
		if [[ $retry -gt 1 ]];then
			break
		fi
		gsutil cp  gs://mango_bencher-dos/$1 ./
		if [[ ! -f "$1" ]];then
			echo "NO $1 found, retry"
		else
			break
		fi
	done
}
upload_file() {
	gsutil cp  $1 gs://mango_bencher-dos/$2
}

cd $BUILD_DEPENDENCY_CONFIGUERE_DIR
download_file $AUTHORITY_FILE
[[ ! -f "$AUTHORITY_FILE" ]]&&echo no $AUTHORITY_FILE file && exit 1
download_file $ID_FILE
[[ ! -f "$ID_FILE" ]]&&echo no $ID_FILE file && exit 1

cd $BUILD_DEPENDENCY_BENCHER_DIR
echo $ACCOUNTS
download_accounts=( $ACCOUNTS )
for acct in ${download_accounts[@]}
do
  echo --- start to download $acct
  download_file $acct
done
upload_file $BUILD_DEPENDENCY_BENCHER_DIR/target/release/solana-bench-mango
exit 0