# Hippo Plugin

Hippo Plugin 是一個結合 Hippo Manager ，讓 microservice 達到監控與自動重啟的機制

#### 項目結構

| 文件夾        |     說明     |
| :----------- | :-----------|
| hoppo | hippo plugin |
| test | 示範程式碼，Demo 一個 microservice 與 hippo pluing 的使用方式|

## 前置作業

### 若為 MacOS 需安裝與 linux 一致的 getopt

```shell=
brew install gnu-getopt
echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"' >> ~/.bash_profile
```

## Installation

### 專案安裝 hippo plugin

於 `HippoPlugin/hippo/build-tool` 資料夾執行 `build.sh`

```shell=
./build.sh --install $your-project-root
```

查看 project path 目錄下會多一個 `hippo` 的資料夾


### 填寫 Kafka 相關資訊

於 `hippo/etc/env.sh`

| name        |     description     |
| :----------- | :-----------|
| KAFKA_PRODUCER | producer 路徑 |
| KAFKA_HOST | kafka 的 host |
| HEALTH_TOPIC | 傳送監控資訊的 topic |

```shell
SERVICE_LIST=""

KAFKA_PRODUCER=/Users/square_huang/Documents/Software/kafka_2.10-0.9.0.0/bin/kafka-console-producer.sh
KAFKA_HOST=localhost:9092
HEALTH_TOPIC=service-health
```

### 新增一個 service

**於 HippoPlugin hippo/build-tool**

於 `HippoPlugin/hippo/build-tool`執行 `build.sh`

```shell=
./build.sh --create-service evaluation $your-project-root
```

**於 Project 內的 hippo/build-tool**

於 `$Project/hippo/build-tool`執行 `build-service.sh`

```shell=
./build-service.sh --create-service $SUB_PROJECT_NAME
```

### 設定執行 service 的 command

於 `hippo/etc/training/hippos.service.test1-training-env.sh` 編輯 `EXECUTE_CMD`

```shell
# You can use APP_HOME variable to build command
EXECUTE_CMD="sh ${APP_HOME}/sbin/mock_training.sh"
```


## HOW TO USE

### build-service

新增/刪除/查詢 Project 內的 Service
build-tool/build-service.sh

#### Usage

```shell
build-service.sh [OPTIONS] SUB_PROJECT_NAME
```

#### Options

| short | command                   | description                                                                                                                                                                                                        | Default | Required |
| :---- | :------------------------ | :--------------------------------------------------------------------------------------------------------------- | :----- | :-----                                                                                                |
| -h    | --help                    | Show help, exit                                                                                                                                                                                                    |        |        |
| -c    | --create-service=SUB_PROJECT_NAME       | 新增一個 service        |        |FALSE   |
| -d    | --delete-service=SUB_PROJECT_NAME       | 刪除一個 Service        |        |FALSE   |
| -l    | --list-services                         | 列出 Project 內的 Service        |        |FALSE   |
| --check-service=SUB_PROJECT_NAME                | 確認 Project 內是否有該 Service        |        |FALSE   |


#### Example

新增一個 SUB_PROJECT_NAME `evaluation` 的 Service

```shell=
build-service.sh --create-service evaluation
```

刪除一個 SUB_PROJECT_NAME `evaluation` 的 Service

```shell=
build-service.sh --delete-service evaluation
```

查詢 Project 內的 Service

```shell=
build-service.sh --list-services evaluation
```

Output

```shell=
PROJECT_NAME                             SUB_PROJECT_NAME                         SERVICE_NAME
hippos.service.test1                     prediction                               hippos.service.test1-prediction
hippos.service.test1                     training                                 hippos.service.test1-training
```

### monitor-start

啟動 monitor 服務

#### Usage

```shell
monitor-start [OPTIONS] SERVICE
```



#### Options

| short | command                   | description                                                                                                                                                                                                        | Default | Required |
| :---- | :------------------------ | :--------------------------------------------------------------------------------------------------------------- | :----- | :-----                                                                                                |
| -h    | --help                    | Show help, exit                                                                                                                                                                                                    |        |        |
| -i    | --interval                 | 監控的間隔(秒)                                                                                                                                                                                        |        |TRUE   |
|-r     | --restart                  | 重啟服務模式        |FALSE   |FALSE   |


#### Example

啟動監控間隔 60 秒的 service `hippos.service.test1-training`

```shell=
monitor-start -i 60 hippos.service.test1-training
```

重新啟動一個監控間隔 30 秒的 service `hippos.service.test1-training`

```shell
monitor-start -r -i 30 hippos.service.test1-training
```

### monitor-stop

停止 monitor 服務

#### Usage

```shell
monitor-stop SERVICE
```

#### Example

暫停 service `hippos.service.test1-training`

```shell
monitor-stop hippos.service.test1-training
```


### monitor-status

檢查 monitor 、hippo service 服務狀態

#### Usage

```shell
monitor-status SERVICE
```

#### Example

檢查 service `hippos.service.test1-training` 狀態

```shell
monitor-status hippos.service.test1-training
```
