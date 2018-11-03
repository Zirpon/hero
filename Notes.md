# 开发笔记

## 启动/关闭mongodb

### example：

```shell
./bin/mongod --dbpath=/data/mongodb/ --logpath=/data/mongodb.log --fork --journal --logappend --bind_ip_all
mongod --shutdown  --dbpath=/data/mongodb/
```

Development branch status : [![Build Status][travisDevBadge]][travisLink]   [![Build status][AppveyorDevBadge]][AppveyorLink]   [![Build status][CircleDevBadge]][CircleLink]

[travisDevBadge]: https://travis-ci.org/facebook/zstd.svg?branch=dev "Continuous Integration test suite"
[travisLink]: https://travis-ci.org/facebook/zstd
[AppveyorDevBadge]: https://ci.appveyor.com/api/projects/status/xt38wbdxjk5mrbem/branch/dev?svg=true "Windows test suite"
[AppveyorLink]: https://ci.appveyor.com/project/YannCollet/zstd-p0yf0
[CircleDevBadge]: https://circleci.com/gh/facebook/zstd/tree/dev.svg?style=shield "Short test suite"
[CircleLink]: https://circleci.com/gh/facebook/zstd

For reference, several fast compression algorithms were tested and compared
on a server running Linux Debian (`Linux version 4.14.0-3-amd64`),

To solve this situation, Zstd offers a __training mode__, which can be used to tune the algorithm for a selected type of data.

- `make install` : create and install zstd cli, library and man pages
- `make check` : create and run `zstd`, tests its behavior on local platform

## 启动/关闭rocket

### logPath

>* ~/logs/rocketmqlogs/namesrv.log
>* ~/logs/rocketmqlogs/broker.log

### example

```shell
nohup sh bin/mqnamesrv &
nohup sh bin/mqbroker -n localhost:9876 autoCreateTopicEnable=true &
sh bin/mqshutdown broker
sh bin/mqshutdown namesrv
```

## haproxy: cannot bind socket

```shell
setsebool -P haproxy_connect_any=1
service firewalld stop
```

## vm mac address

```shell
centos-1 00:0c:29:db:31:34
centos-2 00:0c:29:b7:99:3d
mac-centos-1 00:0c:29:ba:4e:b8
```

## 防火墙禁用开机启动

```shell
systemctl disable firewalld.service
```

## install gcc 4.9

```shell
sh ./contrib/download_prerequisites
mkdir objdir
cd objdir
../configure --disable-multilib --enable-languages=c,c++
make && make install
```

```shell
export LD_LIBRARY_PATH=/data/cj
```

## cj svn account password

> zhangzhipeng  
> Zhipeng123123

## gunsoul svn account password

> zhipeng_zhang
> zhipeng_zhang321

## Internet ip

>- 192.168.3.18
>- 192.168.2.156
>- root 123456
> 测试机器人主机1(119.23.107.253)-深圳
> 测试机器人主机2(47.94.83.100)-北京
> 服务器主机1(39.108.68.232)-深圳
> 服务器主机2(112.74.46.63)-深圳
> pwd:Wydcj123

## 更新内网

>- 更新协议
>- 更新脚本
>- 找机会重启

---

## app store 美国区

> 账号：bevbk8e@icloud.com
> 密码：Ss112211

## 流程图

```flow
st=>start: Start
op=>operation: Your Operation
cond=>condition: Yes or No?
e=>end

st->op->cond
cond(yes)->e
cond(no)->op
```

<progress value="25" max="100" background=orange >25%</progress>

## 序列图

```seq
Alice->Bob: Hello Bob, how are you?
Note right of Bob: Bob thinks
Bob-->Alice: I am good thanks!
```

## 表格

| 项目        | 价格   |  数量  |
| --------   | -----:  | :----:  |
| 计算机     | \$1600 |   5     |
| 手机        |   \$12   |   12   |
| 管线        |    \$1    |  234  |

---
