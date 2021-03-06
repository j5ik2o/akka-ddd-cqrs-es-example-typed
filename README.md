# DDD CQRS Event Sourcing by using akka-typed

## Tools

- awscli
- asdf
- jq
- java
- sbt
- terraform

## Set up

### asdf

```sh
$ brew install asdf
```

### jq

```shell
$ asdf plugin-add jq https://github.com/AZMCode/asdf-jq.git
$ asdf install jq 1.6
$ asdf local jq 1.6
$ jq --version
jq-1.6
```

### awscli

```shell
$ asdf plugin add awscli
$ asdf install awscli 2.7.6
$ asdf local  awscli 2.7.6
$ aws --version
aws-cli/2.7.6 Python/3.9.11 Darwin/21.5.0 exe/x86_64 prompt/off
```

### Terraform

https://github.com/hashicorp/terraform

```sh
adceet-root $ asdf plugin-add terraform https://github.com/asdf-community/asdf-hashicorp.git
adceet-root $ ASDF_HASHICORP_OVERWRITE_ARCH=amd64 asdf install terraform 1.2.1
adceet-root $ asdf local terraform 1.2.1
adceet-root $ terraform version
Terraform v1.2.1
on darwin_arm64

Your version of Terraform is out of date! The latest version
is 1.2.2. You can update by downloading from https://www.terraform.io/downloads.html
```

### Terraformer

https://github.com/GoogleCloudPlatform/terraformer

```shell
adceet-root $ asdf plugin add terraformer https://github.com/grimoh/asdf-terraformer.git
adceet-root $ asdf install terraformer 0.8.20
adceet-root $ asdf local terrformer 0.8.20
adceet-root $ mkdir ./temp
adceet-root/temp $ export GODEBUG=asyncpreemptoff=1
adceet-root/temp $ DATADOG_API_KEY="xxx" DATADOG_APP_KEY="xxx" terraformer import datadog --resources=dashboard --filter=datadog_dashboard=XXXXX
```

### Java Development Kit

```sh
$ asdf plugin add java
$ asdf list all java
$ asdf instal java temurin-11.0.14+101
$ asdf local java temurin-11.0.14+101
$ java -version
openjdk version "11.0.15" 2022-04-19
OpenJDK Runtime Environment Temurin-11.0.15+10 (build 11.0.15+10)
OpenJDK 64-Bit Server VM Temurin-11.0.15+10 (build 11.0.15+10, mixed mode)
```

### sbt

```sh
$ asdf plugin add sbt
$ asdf install sbt 1.6.2
$ asdf local sbt 1.6.2
```

### EKSを使う場合

#### kubectl

トラブルを避けるためサーバ側と同じバージョンのkubectlをインストールしてください

```shell
$ KUBECTL_VERSION=1.21.13
$ asdf plugin-add kubectl https://github.com/asdf-community/asdf-kubectl.git
$ asdf install kubectl $KUBECTL_VERSION
akka-ddd-cqrs-es-example-typed $ asdf local kubectl $KUBECTL_VERSION # 必ずプロジェクトルートで設定する
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.13", GitCommit:"80ec6572b15ee0ed2e6efa97a4dcd30f57e68224", GitTreeState:"clean", BuildDate:"2022-05-24T12:40:44Z", GoVersion:"go1.16.15", Compiler:"gc", Platform:"darwin/arm64"}
Server Version: version.Info{Major:"1", Minor:"21+", GitVersion:"v1.21.12-eks-a64ea69", GitCommit:"d4336843ba36120e9ed1491fddff5f2fec33eb77", GitTreeState:"clean", BuildDate:"2022-05-12T18:29:27Z", GoVersion:"go1.16.15", Compiler:"gc", Platform:"linux/amd64"}
```

#### helm

```shell
$ asdf plugin-add helm https://github.com/Antiarchitect/asdf-helm.git
$ asdf install helm 3.9.0
$ asdf local helm 3.9.0
# helmfileで必要なプラグイン
$ helm plugin install https://github.com/databus23/helm-diff
$ helm plugin install https://github.com/jkroepke/helm-secrets --version v3.12.0
# https://github.com/jkroepke/helm-secrets
```

helm-secretsのためにkmsキーを作る

```shell
$ aws --profile adceet kms create-key
```

#### helmfile

```shell
$ asdf plugin-add helmfile https://github.com/feniix/asdf-helmfile.git
$ asdf install helmfile 0.144.0
$ asdf local helmfile 0.144.0
```


## 初期設定

```shell
$ cp env.sh.default env.sh
```

PREFIX, APPLICATION_NAMEを適宜修正する。
個人環境を作りたい場合は、PREFIXを変更するとよい。

### Debug by using IntelliJ IDEA

Edit Configurations

com.github.j5ik2o.api.write.Main

1. PORT=8081;AKKA_MANAGEMENT_HTTP_PORT=8558;JMX_PORT=8100
2. PORT=8082;AKKA_MANAGEMENT_HTTP_PORT=8559;JMX_PORT=8101
3. PORT=8083;AKKA_MANAGEMENT_HTTP_PORT=8560;JMX_PORT=8102

3つの分の設定を作り、IntelliJ IDEAで実行してください。デバッグしたい場合はいずれか1個のプロジェクトをデバッグで起動してください。

## kubernetes-dashboard

```shell
$ DASHBOARD_NS=kubernetes-dashboard
$ export POD_NAME=$(kubectl get pods -n $DASHBOARD_NS -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
$ kubectl -n $DASHBOARD_NS port-forward $POD_NAME 8443:8443
```

### Configuring Chrome

1. Open `chrome://flags/#allow-insecure-localhost`
2. `Allow invalid certificates for resources loaded from localhost.` is `Enable`
3. Relaunch
4. Open `https://localhost:8443`

### Get token

```shell
$ DASHBOARD_NS=kubernetes-dashboard
$ kubectl -n $DASHBOARD_NS describe secret $(kubectl -n $DASHBOARD_NS get secret | grep kubernetes-dashboard-token | awk '{print $1}') | awk '$1=="token:"{print $2}'
```
