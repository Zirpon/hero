# iptables note

- 在tcp协议中，禁止所有的ip访问本机的`9902`端口。
    > iptables -I INPUT -p tcp --dport 9902 -j DROP
- 允许 `223.104.63.111` 访问本机的 `9902` 端口
    > iptables -I INPUT -s 223.104.63.111 -ptcp --dport 9902 -j ACCEPT
- 允许 `113.111.245.62` 访问本机的 `9902` 端口
    > iptables -I INPUT -s 113.111.245.62 -ptcp --dport 9902 -j ACCEPT
- 清除预设表filter中的所有规则链的规则  
    > iptables -F

---
