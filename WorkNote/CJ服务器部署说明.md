# CJ服务器部署说明

1. 安装CentOS 7.0
2. 编译gcc 4.9

    ```shell
    sh ./contrib/download_prerequisites
    mkdir objdir
    cd objdir
    ../configure --disable-multilib --enable-languages=c,c++
    make && make install
    ```

3. svn co `http://192.168.0.151:18082/svn/svn_CJ/program/server/`
4. 安装该svn目录下tool路径下的redis 详情看redis readme
5. 到trunk 目录下执行 install.sh 脚本 首次部署执行: sh install.sh a
6. install 脚本会部署服务器 到 server/trunk/release/目录下
7. 配置 server/trunk/release/server-config/ 里的配置文件 主要配置 global_config 各个服务器节点的`addr`, redis 地址
8. 启动 server/trunk/db/ 目录下的 start_db.sh, 但是这里有一点要注意 该脚本启动的是当前路径下的redis-server 所以要把第四步安装的redis路径的该程序拷贝到这个目录下
9. 执行 sh shm_clear.sh
10. 执行各个服务器的启动脚本

    ```shell
    sh global_run.sh start
    sh battle_run.sh start
    sh run.sh start
    ```