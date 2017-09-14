# Hippo Plugin

Hippo Plugin 是一個結合 Hippo Manager ，讓 microservice 達到監控與自動重啟的機制

#### 項目結構

| 文件夾        |     說明      |
| :----------- | :----------- |
| hoppo        | hippo plugin |
| test         | 示範程式碼，Demo 一個 microservice 與 hippo pluing 的使用方式 |

## 前置作業

### 若為 MacOS 需安裝與 linux 一致的 getopt

```shell=
brew install gnu-getopt
echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"' >> ~/.bash_profile
```

## Installation

### 安裝 hippo plugin 到專案

於 `HippoPlugin/hippo/build-tool` 資料夾執行 `build.sh`

```shell=
./build.sh --install $your-project-root
./build.sh -i $your-project-root
```

查看 project path 目錄下會多一個 `hippo` 的資料夾


### 填寫 Kafka 相關資訊

於 `Project/hippo/etc/env.sh`

| name           | description        |
| :--------------| :------------------|
| KAFKA_PRODUCER | producer 路徑      |
| KAFKA_HOST     | kafka 的 host      |
| HEALTH_TOPIC   | 傳送監控資訊的 topic |

```shell
SERVICE_LIST=""

KAFKA_PRODUCER=/Users/square_huang/Documents/Software/kafka_2.10-0.9.0.0/bin/kafka-console-producer.sh
KAFKA_HOST=localhost:9092
HEALTH_TOPIC=service-health
```

### 新增一個 service

**於 Project 內的 hippo/build-tool**

於 `$PROJECT/hippo/build-tool`執行 `build-service.sh`

```shell=
./build-service.sh --create-service $SERVICE
```

```shell=
./build-service.sh --create-service $SERVICE --cmd "sh \${PROJECT_HOME}/sbin/mock_training.sh"
```


### 設定執行 service 的 command

於 `$PROJECT/hippo/etc/$SERVICE/$SERVICE-env.sh` 編輯 `EXECUTE_CMD`

```shell
# You can use PROJECT_HOME variable to build command
EXECUTE_CMD="sh ${PROJECT_HOME}/sbin/mock_training.sh"
```


## HOW TO USE

### build.sh
安裝/移除專案的 hippo plugin

#### Usage

```shell
./build-tool/build.sh [OPTIONS] PROJECT_PATH
```

#### Options

| short | command                   | description                    | Default | Required |
| :---- | :------------------------ | :-----------------------------| :----- | :-----    |
| -h    | --help                    | Show help                       |        |        |
| -i    | --install                 | 安裝 hippo plugin 到專案         |        |FALSE   |
| -u    | --uninstall               | 移除專案的 hippo plugin          |        |FALSE   |
|       | --check-install           | 確認 Project 內是否有安裝 hippo plugin |   |FALSE   |



> `--cmd` 需與 `--create-service` 一起使用

#### Example

安裝 hippo plugin 到 `recommender_system` 專案

```shell=
./HippoPlugin/hippo/build-tool/build-service.sh --install ~/recommender_system

or

./HippoPlugin/hippo/build-tool/build-service.sh -i ~/recommender_system

```

移除 `recommender_system` 專案的 hippo plugin

```shell=
./HippoPlugin/hippo/build-tool/build-service.sh --uninstall ~/recommender_system

or

./HippoPlugin/hippo/build-tool/build-service.sh -u ~/recommender_system

```

### build-service.sh

新增/刪除/查詢 Project 內的 Service
build-tool/build-service.sh

#### Usage

```shell
./build-tool/build-service.sh [OPTIONS] SERVICE
```

#### Options

| short | command                   | description                    | Default | Required |
| :---- | :------------------------ | :-----------------------------| :----- | :-----    |
| -h    | --help                    | Show help                       |        |        |
| -c    | --create-service=SERVICE  | 新增一個 Service                 |        |FALSE   |
| -d    | --delete-service=SERVICE  | 刪除一個 Service                 |        |FALSE   |
| -l    | --list-services           | 列出 Project 內的 Service        |        |FALSE   |
|       |--check-service=SERVICE    | 確認 Project 內是否有該 Service   |        |FALSE   |
|       |--cmd=\"CMD\"              | 啟動 Service 時帶入的指令(執行 py、jar、shell)，可以使用  "\\${PROJECT_HOME}" 變數 |  | FALSE |

> `--cmd` 需與 `--create-service` 一起使用

#### Example

新增一個 SERVICE `recommender-evaluation` 的 Service

```shell=
./build-tool/build-service.sh --create-service recommender-evaluation
```

新增一個 SERVICE `recommender-training` 的 Service，並設定啟動時帶入的 command

```shell=
./build-tool/build-service.sh --create-service recommender-training --cmd "\${PROJECT_HOME}/sbin/mock_training.sh"
```

查詢 Project 內的 Service

```shell=
./build-tool/build-service.sh --list-services
```

Output

```shell=
PROJECT_NAME                             SERVICE_NAME
recommender_system                       recommender-evaluation
recommender_system                       recommender-training

```


刪除一個 SERVICE `recommender-evaluation` 的 Service

```shell=
./build-tool/build-service.sh --delete-service recommender-evaluation
```

### monitor-start

啟動 monitor 服務

#### Usage

```shell
./bin/monitor-start [OPTIONS] SERVICE
```


#### Options

| short | command                    | description               | Default | Required |
| :---- | :------------------------  | :------------------------ | :------ | :------- |
| -h    | --help                     | Show help                 |         |          |
| -i    | --interval                 | 監控的間隔(秒)              |         |TRUE      |
| -r    | --restart                  | 重啟服務模式                |FALSE    |FALSE     |


#### Example

啟動監控間隔 60 秒的 service `recommender-training`

```shell=
./bin/monitor-start -i 60 recommender-training
```

重新啟動一個監控間隔 30 秒的 service `recommender-training`

```shell
./bin/monitor-start -r -i 30 recommender-training
```

### monitor-stop

停止 monitor 服務

#### Usage

```shell
./bin/monitor-stop SERVICE
```

#### Example

暫停 service `recommender-training`

```shell
./bin/monitor-stop recommender-training
```


### monitor-status

檢查 monitor 、hippo service 服務狀態

#### Usage

```shell
./bin/monitor-status SERVICE
```

#### Example

檢查 service `recommender-training` 狀態

```shell
./bin/monitor-status recommender-training
```
