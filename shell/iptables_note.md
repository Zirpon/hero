# iptables note

- 在tcp协议中，禁止所有的ip访问本机的`9902`端口。
    > iptables -I INPUT -p tcp --dport 9902 -j DROP
- 允许 `223.104.63.111` 访问本机的 `9902` 端口
    > iptables -I INPUT -s 223.104.63.111 -p tcp --dport 9902 -j ACCEPT
- 修改 规则 时间有效期
    > iptables -R INPUT 2 -s 223.104.63.111 -m time --datestart 2018-12-19T09:00:08 --datestop 2018-12-19T09:30:00 -p tcp --dport 9902 -j ACCEPT

    iptables 时间基于UTC时间 所以 先用 命令 `date --utc` 跟 `date` 查看 本地时间与UTC时间的时差

- 允许 `113.111.245.62` 访问本机的 `9902` 端口
    > iptables -I INPUT -s 113.111.245.62 -p tcp --dport 9902 -j ACCEPT

- MAC地址的设备和这个iptables不在一个子网里，就没用
    > iptables -I INPUT -m mac --mac-source a0:4e:a7:43:80:c4 -p tcp --dport 9902 -j ACCEPT

- 清除预设表filter中的所有规则链的规则  
    > iptables -F

- 允许 `113.111.0.0/16` 访问本机的 `9902` 端口

```shell
iptables -I INPUT -s 113.111.0.0/16 -p tcp --dport 9902 -j ACCEPT
iptables -I INPUT -s 116.22.128.0/20 -p tcp --dport 9902 -j ACCEPT
iptables -I INPUT -s 223.64.0.0/10 -p tcp --dport 9902 -j ACCEPT
iptables -I INPUT -s 223.96.0.0/12 -p tcp --dport 9902 -j ACCEPT
iptables -I INPUT -s 223.104.60.0/22 -p tcp --dport 9902 -j ACCEPT
```

|   device  |   ip  |
|   ---     |   --- |
|   宿舍    |   116.22.132.155  |
|   公司    |   113.111.185.3,113.111.245.62    |
|   手机    |   223.104.63.111  |

- iptables -F 清除预设表filter中的所有规则链的规则
- iptables -X 清除预设表filter中使用者自定链中的规则
- iptables -L -n 查看本机关于IPTABLES的设置情况 **远程连接规则将不能使用**

---
