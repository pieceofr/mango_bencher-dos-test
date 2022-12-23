echo ----- stage: create exec-start-dos-test.sh ------
# add information to exec-start-dos-test.sh
cat exec-start-template.sh > exec-start-dos-test.sh
echo "export BUILD_DEPENDENCY_BENCHER_DIR=$BUILD_DEPENDENCY_BENCHER_DIR" >> exec-start-dos-test.sh
echo "export BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR=$BUILD_DEPENDENCY_BENCHER_DIR/deps" >> exec-start-dos-test.sh
echo "export BUILD_DEPENDENCY_CONFIGUERE_DIR=$BUILD_DEPENDENCY_CONFIGUERE_DIR" >> exec-start-dos-test.sh
echo "export ENDPOINT=$ENDPOINT" >> exec-start-dos-test.sh
echo "export DURATION=$DURATION" >> exec-start-dos-test.sh
echo "export QOUTES_PER_SECOND=$QOUTES_PER_SECOND" >> exec-start-dos-test.sh
echo "export ACCOUNT_FILE=$ACCOUNT_FILE" >> exec-start-dos-test.sh
echo "export ID_FILE=$ID_FILE" >> exec-start-dos-test.sh
echo "export AUTHORITY_FILE=$AUTHORITY_FILE" >> exec-start-dos-test.sh
echo "export CLUSTER=$CLUSTER" >> exec-start-dos-test.sh
echo "export KEEPER_GROUP=$KEEPER_GROUP" >> exec-start-dos-test.sh
echo "export KEEPER_ENDPOINT=$KEEPER_ENDPOINT" >> exec-start-dos-test.sh
echo "export KEEPER_CONSUME_EVENTS_INTERVAL=$KEEPER_CONSUME_EVENTS_INTERVAL" >> exec-start-dos-test.sh
echo "export KEEPER_CONSUME_EVENTS_LIMIT=$KEEPER_CONSUME_EVENTS_LIMIT" >> exec-start-dos-test.sh
echo "export KEEPER_UPDATE_CACHE_INTERVAL=$KEEPER_UPDATE_CACHE_INTERVAL" >> exec-start-dos-test.sh
echo "export KEEPER_UPDATE_ROOT_BANK_CACHE_INTERVAL=$KEEPER_UPDATE_ROOT_BANK_CACHE_INTERVAL" >> exec-start-dos-test.sh
echo 'exec nohup ./start-dos-test.sh > start-dos-test.log 2>start-dos-test.nohup &' >> exec-start-dos-test.sh
chmod +x exec-start-dos-test.sh