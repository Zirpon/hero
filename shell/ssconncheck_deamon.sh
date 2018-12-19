#/bin/sh

while true; do
    sh /root/shadowsocks_mgr/shadowsocksConn_check.sh 9905
    #echo $! > /root/shadowsocks_mgr/pid/9905.pid
    sh /root/shadowsocks_mgr/shadowsocksConn_check.sh 9902
    #echo $! > /root/shadowsocks_mgr/pid/9902.pid
    sh /root/shadowsocks_mgr/shadowsocksConn_check.sh 9904
    sh /root/shadowsocks_mgr/shadowsocksConn_check.sh 9903
    #echo $! > /root/shadowsocks_mgr/pid/9904.pid
    sleep 10 
done
