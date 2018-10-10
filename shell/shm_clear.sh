ipcs -m;ipcs -m | grep '0x' | awk -F' ' '{print($2);cmd="ipcrm -m "$2;system(cmd)}';ipcs -m
