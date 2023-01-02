#!/usr/bin/env bash
set -ex
#############################
[[ ! "$CLUSTER" ]] && echo no CLUSTER && exit 1
[[ ! "$SOLANA_METRICS_CONFIG" ]] && echo no SOLANA_METRICS_CONFIG ENV
[[ ! "$ENDPOINT" ]]&& echo "No ENDPOINT" > dos-env.out && exit 1
[[ ! "$RUN_KEEPER" ]] && RUN_KEEPER="true" >> dos-env.out
[[ ! "$AUTHORITY_FILE" ]] && echo no AUTHORITY_FILE && exit 1
[[ ! "$ID_FILE" ]] && echo no ID_FILE && exit 1
[[ ! "$ACCOUNT_FILE" ]]&&echo no ACCOUNT_FILE && exit 1
[[ ! "$KEEPER_GROUP" ]] && echo no KEEPER_GROUP && exit 1
[[ ! "$KEEPER_ENDPOINT" ]] && echo no KEEPER_ENDPOINT && exit 1
[[ ! "$KEEPER_CONSUME_EVENTS_INTERVAL" ]] && echo no KEEPER_CONSUME_EVENTS_INTERVAL && exit 1
[[ ! "$KEEPER_CONSUME_EVENTS_LIMIT" ]] && echo no KEEPER_CONSUME_EVENTS_LIMIT && exit 1
[[ ! "$KEEPER_UPDATE_CACHE_INTERVAL" ]] && echo no KEEPER_UPDATE_CACHE_INTERVAL && exit 1
[[ ! "$KEEPER_UPDATE_ROOT_BANK_CACHE_INTERVAL" ]] && echo no KEEPER_UPDATE_ROOT_BANK_CACHE_INTERVAL && exit 1
[[ ! "$BUILD_DEPENDENCY_BENCHER_DIR" ]]&& echo no BUILD_DEPENDENCY_BENCHER_DIR && exit 1
[[ ! "$BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR" ]]&& echo no BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR && exit 1
[[ ! "$BUILD_DEPENDENCY_CONFIGUERE_DIR" ]]&& echo no BUILD_DEPENDENCY_CONFIGUERE_DIR && exit 1
#### metrics env ####
echo SOLANA_METRICS_CONFIG=\"$SOLANA_METRICS_CONFIG\" >> dos-env.out
#### keeper ENV ####
export CLUSTER=$CLUSTER 
export GROUP=$KEEPER_GROUP
export ENDPOINT_URL=$KEEPER_ENDPOINT
export CONSUME_EVENTS_INTERVAL=$KEEPER_CONSUME_EVENTS_INTERVAL
export CONSUME_EVENTS_LIMIT=$KEEPER_CONSUME_EVENTS_LIMIT
export UPDATE_CACHE_INTERVAL=$KEEPER_UPDATE_CACHE_INTERVAL # def 3000
export UPDATE_ROOT_BANK_CACHE_INTERVAL=$KEEPER_UPDATE_ROOT_BANK_CACHE_INTERVAL # def 5000

#### mango_bencher ENV ####
[[ ! "$DURATION" ]] &&  DURATION=120 && echo DURATION=$DURATION >> dos-env.out
[[ ! "$QOUTES_PER_SECOND" ]] &&  QOUTES_PER_SECOND=1 && echo QOUTES_PER_SECOND=$QOUTES_PER_SECOND >> dos-env.out

## Prepare Metrics
[[ ! -d "$BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR/solana" ]]&& echo no solana && exit 1
cd $BUILD_DEPENDENCY_SOLALNA_DOWNLOAD_DIR/solana/scripts
ret_config_metric=$(exec ./configure-metrics.sh || true )

## Run Keeper.ts
if [[ "$RUN_KEEPER" == "true" ]] ;then
    cd $BUILD_DEPENDENCY_CONFIGUERE_DIR
    k_log="$HOSTNAME-keeper.log"
    # Important artifact: keeper.log
    echo --- start to run keeper
    ret_keeper=$(yarn ts-node keeper.ts > $k_log 2> 1 &)
fi

# benchmark exec
#cd $BUILD_DEPENDENCY_BENCHER_DIR/target/release/
source utils.sh
cd $HOME
download_file solana-bench-mango
chmod +x solana-bench-mango
b_cluster_ep=$ENDPOINT
b_auth_f="$BUILD_DEPENDENCY_CONFIGUERE_DIR/$AUTHORITY_FILE"
b_acct_f="$BUILD_DEPENDENCY_BENCHER_DIR/$ACCOUNT_FILE"
b_id_f="$BUILD_DEPENDENCY_CONFIGUERE_DIR/$ID_FILE"
b_mango_cluster=$CLUSTER
b_duration=$DURATION
b_q=$QOUTES_PER_SECOND
b_tx_save_f="$HOSTNAME-TLOG.csv"
b_block_save_f="$HOSTNAME-BLOCK.csv"
b_error_f="$HOSTNAME-error.txt"
echo $(pwd)
echo --- start of benchmark $(date)
ret_bench=$(./solana-bench-mango -u $b_cluster_ep --identity $b_auth_f --accounts $b_acct_f --mango $b_id_f --mango-cluster $b_mango_cluster --duration $b_duration -q $b_q --transaction_save_file $b_tx_save_f --block_data_save_file $b_block_save_f 2> $b_error_f &)
echo --- end of benchmark $(date)
echo --- write down log in log-files.out ---
echo $b_tx_save_f > $HOME/log-files.out
echo $b_block_save_f >> $HOME/log-files.out
echo $b_error_f >> $HOME/log-files.out
echo $k_log >> $HOME/log-files.out

## solana-bench-mango -- -u ${NET_OR_IP} --identity ../configure_mango/authority.json 
## --accounts ../configure_mango/accounts-20.json  --mango ../configure_mango/ids.json 
## --mango-cluster ${IP_OF_MANGO_CLIENT} --duration 60 -q 128 --transaction_save_file tlog.csv 
## --block_data_save_file blog.csv  2> err.txt &