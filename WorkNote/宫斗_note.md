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

## 登录流程

客户 ->CLIENT_ACCOUNT_LoginRequest ->账号服接收并向远程账号服验证RA_LoginRst ->世界服接收并转发协议 -> 远程账号服返回RA_LoginAck ->世界服转发协议 -> 账号服向世界服发送账号信息及角色列表ACCOUNT_WORLD_ClientLoginRequest ->世界服返回ACCOUNT_WORLD_ClientLoginResponse ->账号服返回客户端CLIENT_ACCOUNT_LoginResponse

## 程序设计结构 以 RemoteAccount 为例

```C++

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* 协议处理函数注册 */

#define ServerEventFunction(c,funct,message)  \
bool __ef_##funct(int socketId, stPacketHead* phead, Base::BitStream* pPack ); \
EventFunctionBuilder<c> _ef_##funct##builder( message, __ef_##funct ); \
bool __ef_##funct(int socketId, stPacketHead* phead, Base::BitStream* pPack )

template< typename ServerClass >
struct EventFunctionBuilder
{
    template< typename _Ty >
    EventFunctionBuilder( const char* msg, _Ty function ) {
        ServerClass::getInstance()->mMsgCode.Register(msg, function);
    }
};

// 目前这个消息用于ACCOUNT向REMOTE请求服务器玩家数据
ServerEventFunction( CRemoteAccount, HandleAccountWorldInfoRequest, ACCOUNT_REMOTE_PlayerCountRequest ) {}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* 消息队列 */
class WorkQueen {

    bool Initialize(WORK_QUEUE_FN fn,int ThreadNum,const char*Name, int iTimeOut) {
        // fn => _eventProcess
        m_Callback = fn;
    }

    bool PostEvent(int Id,void *data,int size,bool CopyData=false,WORKQUEUE_MESSGAE QueueMsg=WQ_PACKET) {
        BOOL ret = PostQueuedCompletionStatus(m_QueueHandle,0,(int)QueueMsg,(LPOVERLAPPED)pStruct);
    }

    static unsigned int WINAPI WorkRoutine(LPVOID Param) {
        while(1) {
            if(!::GetQueuedCompletionStatus(pQueue->m_QueueHandle, &dwByteCount, (ULONG_PTR *)&dwCode,(LPOVERLAPPED*)&pData, pQueue->m_WaitTime)){}

            pQueue->m_Callback(pData);
            if(pQueue->m_WaitTime != INFINITE)
                pQueue->GetTimerMgr().trigger();
        }
    }

    static int _eventProcess( LPVOID param ) {
        WorkQueueItemStruct *pItem = (WorkQueueItemStruct*)param;

        switch(pItem->opCode) {
            case WQ_CONNECT:
            case WQ_DISCONNECT:
            case WQ_PACKET:
                stPacketHead* pHead = (stPacketHead*)pItem->Buffer;
                msg = pHead->Message;
                if(getInstance()->mMsgCode.IsValid(pHead->Message))
                {
                    char *pData = (char *)(pHead) + IPacket::GetHeadSize();
                    Base::BitStream RecvPacket(pData,pItem->size-IPacket::GetHeadSize());
                    Base::BitStream* pPacket = &RecvPacket;
                    return getInstance()->mMsgCode.Trigger(pItem->Id,pHead,RecvPacket);
                }
            case WQ_CONFIGMONITOR:
            case WQ_TIMER:
            case WQ_LOGIC:
            default:
                break;
        }
    }
}

void HandleClientLogin() {
    T::getInstance()->getWorkQueue()->PostEvent(m_pSocket->GetClientId(),IP,sStrlen(IP,COMMON_STRING_LENGTH)+1,true,WQ_CONNECT);
}

void HandleClientLogout() {
    T::getInstance()->getWorkQueue()->PostEvent(m_pSocket->GetClientId(),NULL,0,false,WQ_DISCONNECT);
}

bool HandleGamePacket(stPacketHead *pHead,int iSize) {
    T::getInstance()->getWorkQueue()->PostEvent(m_pSocket->GetClientId(),pHead,iSize,true);
    return true;
}

```
