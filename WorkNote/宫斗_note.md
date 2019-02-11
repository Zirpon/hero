# 宫斗 Note

## Database

### SQL Server 2008 R2

#### 安装环境

- 系统: Windows Server 2008 R2 With Service Package 1 (`cn_windows_server_2008_r2_standard_enterprise_datacenter_and_web_with_sp1_x64_dvd_617598.iso`)
- SQL Server 2008 R2 安装包: `cn_sql_server_2008_r2_standard_x86_x64_ia64_dvd_522239.iso`

### 初始化

- 建库: by_account, by_actor, by_log
- 导入初始化sql: by_account.sql, by_actor.sql, by_log.sql

### Redis

直接运行 `./redis-server.exe ./redis.conf`

## 程序配置表 CfdBuilder.exe

用于修改 `SXZ_SERVER.CFG` 配置表的工具, `SXZ_SERVER.CFG` 内容如下:

    ```config
    [DataBase]
    ActorDB_LANIP   = 192.168.0.37;
    ActorDB_Name    = BY_ACTOR;
    ActorDB_UserId  = sa;
    ActorDB_Password = Sa123;

    RemoteAccountDB_LANIP           = 192.168.0.37;
    RemoteAccountDB_Name            = BY_ACCOUNT;
    RemoteAccountDB_UserId          = sa;
    RemoteAccountDB_Password        = Sa123;

    RedisIp                         = 127.0.0.1;
    RedisPort                       = 20006;
    RedisPassword                   = ;

    LogDB_LANIP = 192.168.0.37;
    LogDB_Name  = BY_LOG;
    LogDB_UserId    = sa;
    LogDB_Password  = Sa123;

    [Server]
    Account_WANAddress  = any:20000;
    Account_WANClients  = 200;
    World_LANAddress    = 127.0.0.1:20002;
    Log_LANAddress      = 127.0.0.1:20003;
    RemoteAccount_LANAddress    = 127.0.0.1:20004;
    IFM_SERVICE_NAME            = IFM_ACTIVE_SERVICE_SXZ_G;
    Chat_LANAddress             = 127.0.0.1:20005;
    AreaID  = 1;
    //MaxPlayerCount    = 1;
    MaxLinePlayerCount  = 500;
    NoPass9             = 1;
    RemoteID            = 1;

    [Log]
    DefaultLog  = on:on;

    [arena]
    startTime                       = 2011-10-12
    openDay                         = 14
    closeDay                        = 7

    [127.0.0.1]
    LineID                          = 1;
    GateID                          = 1;
    NetGate_WANAddress              = any:20001;
    NetGate_WANAddress2             = any:20001;
    NetGate_WANClients              = 100000;
    NetGate_LANPort                 = 41001;
    DataAgent_LANPort               = 60000;
    ```

## 程序启动

AccountServer
LogServer
RemoteAccount
WorldServer
ChatServer
NetGate
