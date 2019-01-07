# shell Note

red
> echo -e "\033[31m[ content ]\033[0m"

red + bold
> echo -e "\033[1;31m[ content ]\033[0m"

green + bold
> echo -e "\033[1;32m[ content ]\033[0m"

yellow
> echo -e "\033[33m${message}\033[0m"

## mongostat 性能数据

```txt
insert query update delete getmore command dirty used flushes vsize   res qrw arw net_in net_out conn                time
    *0    *0     *0     *0       0     3|0  0.0% 2.3%       0  899M 92.0M 0|0 1|0   269b   59.0k    2 Oct 12 10:56:02.318
```

```shell
> cat cj/mongostat.txt | grep "%" | awk -F'[ ;]+' '{print $7}'
> cat cj/mongostat.txt | grep "%" | awk -F'[ ;]+' '{split($3,data,"*");if(data[2]>0)print data[2];}'
> mongostat | grep "%" | awk -F'[ ;]+' '{if($3>0)print $0;}'
> mongostat | grep "%" | awk -F'[ ;]+' '{if($2>0)print $0;}'
> k=10.9;mmd=4.9;oo=$(awk 'BEGIN{print ("'$mmd'"+"'$k'")/2;}') ; echo $oo

```

## traceroute

- windows tracert
- linux traceroute

## 关机

- windows:
    > shutdown -s -t 0
    > shutdown -r -t 0
- linux:
    > shutdown -P now