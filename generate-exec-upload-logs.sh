echo ----- stage: create exec-upload-logs.sh ------
echo '#!/usr/bin/env bash' > exec-start-upload-logs.sh
echo 'cp ~/mango_bencher-dos-test/start-upload-logs.sh .' >> exec-start-upload-logs.sh
echo 'chmod +x ~/start-upload-logs.sh' >> exec-start-upload-logs.sh
echo "export MANGO_BENCHER_DIR=$MANGO_BENCHER_DIR" >> exec-start-upload-logs.sh
echo "export MANGO_CONFIGUERE_DIR=$MANGO_CONFIGUERE_DIR" >> exec-start-upload-logs.sh
echo 'exec  ~/start-upload-logs.sh > start-upload-logs.log' >>exec-start-upload-logs.sh
chmod +x exec-start-upload-logs.sh
cat ./exec-start-upload-logs.sh