# 开发笔记

## 启动/关闭mongodb

### example：

```shell
./bin/mongod --dbpath=/data/mongodb/ --logpath=/data/mongodb.log --fork --journal --logappend --bind_ip_all
mongod --shutdown  --dbpath=/data/mongodb/
```

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

## Internet ip

>* 192.168.3.18
>* 192.168.2.156
>* root 123456

## 更新内网

>* 更新协议
>* 更新脚本
>* 找机会重启

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
