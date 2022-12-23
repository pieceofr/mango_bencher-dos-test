# add git repo to exe-start-template
echo "git clone $GIT_REPO.git" >> exec-start-template.sh
echo "cd mango_bencher-dos-test" >> exec-start-template.sh
echo "git checkout $BUILDKITE_BRANCH" >> exec-start-template.sh
echo "cd ~" >> exec-start-template.sh
echo 'cp ~/mango_bencher-dos-test/start-build-dependency.sh .' >> exec-start-template.sh
echo 'cp ~/mango_bencher-dos-test/start-dos-test.sh .' >> exec-start-template.sh
echo "export SOLANA_METRICS_CONFIG=\"$SOLANA_METRICS_CONFIG\"" >> exec-start-template.sh

# add information to exec-start-build-dependency.sh
echo ----- stage: create exec-start-build-dependency.sh ------
[[ ! "$CHANNEL" ]]&& CHANNEL=edge
cat exec-start-template.sh > exec-start-build-dependency.sh
echo "export CHANNEL=$CHANNEL" >> exec-start-build-dependency.sh
echo "export SOLANA_BUILD_BRANCH=$SOLANA_BUILD_BRANCH" >> exec-start-build-dependency.sh
echo "export SOLANA_GIT_COMMIT=$SOLANA_GIT_COMMIT" >> exec-start-build-dependency.sh
echo "export SOLANA_REPO=$SOLANA_REPO" >> exec-start-build-dependency.sh
echo "export MANGO_BENCHER_REPO=$MANGO_BENCHER_REPO" >> exec-start-build-dependency.sh
echo "export MANGO_BENCHER_BRANCH=$MANGO_BENCHER_BRANCH" >> exec-start-build-dependency.sh
echo "export MANGO_CONFIGURE_REPO=$MANGO_CONFIGURE_REPO" >> exec-start-build-dependency.sh
echo "export MANGO_CONFIGURE_BRANCH=$MANGO_CONFIGURE_BRANCH" >> exec-start-build-dependency.sh
echo "export BUILD_DEPENDENCY_BENCHER_DIR=$BUILD_DEPENDENCY_BENCHER_DIR" >> exec-start-build-dependency.sh
echo "export BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR=$BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR" >> exec-start-build-dependency.sh
echo "export BUILD_DEPENDENCY_CONFIGUERE_DIR=$BUILD_DEPENDENCY_CONFIGUERE_DIR" >> exec-start-build-dependency.sh
echo "export AUTHORITY_FILE=$AUTHORITY_FILE" >> exec-start-build-dependency.sh
echo "export ID_FILE=$ID_FILE" >> exec-start-build-dependency.sh
echo "export ACCOUNTS=\"$ACCOUNTS\"" >> exec-start-build-dependency.sh # Notice without double quoate mark, it won't be parse into array
echo 'exec  ./start-build-dependency.sh > start-build-dependency.log' >> exec-start-build-dependency.sh
chmod +x exec-start-build-dependency.sh
cat ./start-build-dependency.sh
