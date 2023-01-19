#!/usr/bin/env bash
set -ex
source $HOME/dos-metrics-env.sh
#############################
[[ ! "$CLUSTER" ]] && echo no CLUSTER && exit 1
[[ ! "$SOLANA_METRICS_CONFIG" ]] && echo no SOLANA_METRICS_CONFIG ENV && exit 1
[[ ! "$BUILD_DEPENDENCY_CONFIGUERE_DIR" ]] && echo no BUILD_DEPENDENCY_CONFIGUERE_DIR ENV && exit 1

[[ ! "$DURATION" ]] && echo no DURATION && exit 1
[[ ! "$QOUTES_PER_SECOND" ]] && echo no QOUTES_PER_SECOND && exit 1
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


download_file() {
	for retry in 0 1
	do
		if [[ $retry -gt 1 ]];then
			break
		fi
		gsutil cp  gs://mango_bencher-dos/$1 ./
		if [[ ! -f "$1" ]];then
			echo "NO $1 found, retry"
            sleep 5
		else
			break
		fi
	done
}

## Prepare Metrics Env
[[ ! -d "$HOME/solana" ]]&& echo no solana && exit 1
cd $HOME/solana/scripts
ret_config_metric=$(exec ./configure-metrics.sh || true )

## Prepare Log Directory
if [[ ! -d "$HOME/$HOSTNAME" ]];then
	mkdir $HOME/$HOSTNAME
fi

 ## Run Keeper.ts
if [[ "$RUN_KEEPER" == "true" ]] ;then
	echo --- stage: Run Keeper -----
    cd $BUILD_DEPENDENCY_CONFIGUERE_DIR
    k_log="$HOME/$HOSTNAME/keeper.log"
    # Important artifact: keeper.log
    echo --- start to run keeper
    ret_keeper=$(yarn ts-node keeper.ts > $k_log 2> 1 &)
fi

sleep 10

echo --- stage: Run Solana-bench-mango -----
#### mango_bencher ENV printout for checking ####
[[ ! "$DURATION" ]] &&  DURATION=120 && echo DURATION=$DURATION >> dos-env.out
[[ ! "$QOUTES_PER_SECOND" ]] &&  QOUTES_PER_SECOND=1 && echo QOUTES_PER_SECOND=$QOUTES_PER_SECOND >> dos-env.out
[[ ! "$CLUSTER" ]] &&  CLUSTER="mainnet-beta" && echo CLUSTER=$CLUSTER >> dos-env.out
[[ ! "$ENDPOINT" ]] &&  ENDPOINT="https://api.mainnet-beta.solana.com" && echo ENDPOINT=$ENDPOINT >> dos-env.out
[[ ! "$AUTHORITY_FILE" ]] &&  AUTHORITY_FILE="authority.json" && echo AUTHORITY_FILE=$AUTHORITY_FILE >> dos-env.out
[[ ! "$ACCOUNT_FILE" ]] &&  ACCOUNT_FILE="account.json" && echo ACCOUNT_FILE=$ACCOUNT_FILE >> dos-env.out
[[ ! "$ID_FILE" ]] &&  ID_FILE="id.json" && echo ID_FILE=$ID_FILE >> dos-env.out

# benchmark exec in $HOME Directory
cd $HOME
b_cluster_ep=$ENDPOINT
b_auth_f="$HOME/$AUTHORITY_FILE"
b_acct_f="$HOME/$ACCOUNT_FILE"
b_id_f="$HOME/$ID_FILE"
b_mango_cluster=$CLUSTER
b_duration=$DURATION
b_q=$QOUTES_PER_SECOND
b_tx_save_f="$HOME/$HOSTNAME/TLOG.csv"
b_block_save_f="$HOME/$HOSTNAME/BLOCK.csv"
b_error_f="$HOME/$HOSTNAME/error.txt"
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