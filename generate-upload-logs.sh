echo ----- stage: create exec-upload-logs.sh ------
echo '#!/usr/bin/env bash' > exec-start-upload-logs.sh
echo 'cp ~/mango_bencher-dos-test/start-upload-logs.sh .' >> exec-start-upload-logs.sh
echo "export BUILD_DEPENDENCY_BENCHER_DIR=$BUILD_DEPENDENCY_BENCHER_DIR" >> exec-start-upload-logs.sh
echo "export BUILD_DEPENDENCY_CONFIGUERE_DIR=$BUILD_DEPENDENCY_CONFIGUERE_DIR" >> exec-start-upload-logs.sh
chmod +x exec-start-upload-logs.sh
cat ./exec-start-upload-logs.sh