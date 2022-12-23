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

echo ----- stage: create exec-start-dos-test.sh ------
# add information to exec-start-dos-test.sh
cat exec-start-template.sh > exec-start-dos-test.sh
echo "export BUILD_DEPENDENCY_BENCHER_DIR=$BUILD_DEPENDENCY_BENCHER_DIR" >> exec-start-dos-test.sh
echo "export BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR=$BUILD_DEPENDENCY_BENCHER_DIR/deps" >> exec-start-dos-test.sh
echo "export BUILD_DEPENDENCY_CONFIGUERE_DIR=$BUILD_DEPENDENCY_CONFIGUERE_DIR"
echo "export ENDPOINT=$ENDPOINT" >> exec-start-dos-test.sh
echo "export DURATION=$DURATION" >> exec-start-dos-test.sh
echo "export QOUTES_PER_SECOND=$QOUTES_PER_SECOND" >> exec-start-dos-test.sh
echo "export ACCOUNT_FILE=$ACCOUNT_FILE" >> exec-start-dos-test.sh
echo "export ID_FILE=$ID_FILE" >> exec-start-dos-test.sh
echo "export AUTHORITY_FILE=$AUTHORITY_FILE" >> exec-start-dos-test.sh
echo "export CLUSTER=$CLUSETER" >> exec-start-dos-test.sh
echo "export KEEPER_GROUP=$KEEPER_GROUP" >> exec-start-dos-test.sh
echo "export KEEPER_ENDPOINT=$KEEPER_ENDPOINT" >> exec-start-dos-test.sh
echo "export KEEPER_CONSUME_EVENTS_INTERVAL=$KEEPER_CONSUME_EVENTS_INTERVAL" >> exec-start-dos-test.sh
echo "export KEEPER_CONSUME_EVENTS_LIMIT=$KEEPER_CONSUME_EVENTS_LIMIT" >> exec-start-dos-test.sh
echo "export KEEPER_UPDATE_CACHE_INTERVAL=$KEEPER_UPDATE_CACHE_INTERVAL" >> exec-start-dos-test.sh
echo "export KEEPER_UPDATE_ROOT_BANK_CACHE_INTERVAL=$KEEPER_UPDATE_ROOT_BANK_CACHE_INTERVAL" >> exec-start-dos-test.sh
echo 'exec nohup ./start-dos-test.sh > start-dos-test.log 2>start-dos-test.nohup &' >> exec-start-dos-test.sh
chmod +x exec-start-dos-test.sh