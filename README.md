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

### service 專案內加入 hippo 資料夾

複製 `hippo` 資料夾到 `your-service-root/`

```shell=
mv hippo your-service-root/
```

### 填寫 Kafka 相關資訊

於 `hippo/etc/env.sh`

| name        |     description     |
| :----------- | :-----------|
| KAFKA_PRODUCER | producer 路徑 |
| KAFKA_HOST | kafka 的 host |
| HEALTH_TOPIC | 傳送監控資訊的 topic |

```shell
KAFKA_PRODUCER=/Users/square_huang/Documents/Software/kafka_2.10-0.9.0.0/bin/kafka-console-producer.sh
KAFKA_HOST=localhost:9092
HEALTH_TOPIC=service-health
```

### 設定執行 service 的 command

於 `hippo/bin/run-service.sh` 編輯 `RUN_DIR` 與`cmd`

```shell
RUN_DIR=${APP_HOME}/sbin
...
...
function start() {
  PROJECT_NAME=$1
  if [[ -z $PROJECT_NAME ]] ; then
    echo "$(basename $0): missing SERVICE"
    usage
    exit 1
  fi

  cmd="sh ${RUN_DIR}/test_socket.sh"
  sh ${HIPPO_SBIN_DIR}/daemon.sh $PROJECT_NAME start 1 $cmd
}
```

## HOW TO USE

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

啟動監控間隔 60 秒的 service `hippo.service.test1`

```shell=
monitor-start -i 60 hippo.service.test1
```

重新啟動一個監控間隔 30 秒的 service `hippo.service.test1`

```shell
monitor-start -r -i 30 hippo.service.test1
```

### monitor-stop

停止 monitor 服務

#### Usage

```shell
monitor-stop SERVICE
```

#### Example

暫停 service `hippo.service.test1`

```shell
monitor-stop hippo.service.test1
```


### monitor-status

檢查 monitor 、hippo service 服務狀態

#### Usage

```shell
monitor-status SERVICE
```

#### Example

檢查 service `hippo.service.test1` 狀態

```shell
monitor-status hippo.service.test1
```
