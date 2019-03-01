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

![登录流程][login_flowchat]

## 服务器架构图

![服务器架构图][server_framework]

## Windows API

```c++

USES_CONVERSION;
UseGB2312;
pStr = A2W(pInchar);

_Check_return_ _Ret_maybenull_
_When_(return != NULL, _Ret_range_(_String, _String+_String_length_(_String)-1))
inline wchar_t* __CRTDECL wcsstr(_In_z_ wchar_t* _String, _In_z_ wchar_t const*_SubStr)
{
    return const_cast<wchar_t*>(wcsstr(static_cast<wchar_t const*>(_String), _SubStr));
}
```

## 程序设计结构 (以 RemoteAccount 为例)

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

## 宫斗合服 by_actor

1. 清理每个服 过期数据

    > **注意事项**

2. Tbl_Account 每个账号 在 每个 Actor 都有一条记录
    - 登录/登出 时间不同 这个要看看 结合什么功能发奖 再决定怎么取这个数
    - 登录IP 有可能不同 这个应该随便合没影响
    - 总在线时间不同 当天在线时间 要看看 这个时间结合什么功能发奖 再决定怎么取这个数
    - 没有 随便合
3. Tbl_Player 直接合 但是要注意 合完以后一个账号对应多个角色 程序实现需要支持一下选角

    > **直接合**

4. Tbl_org 直接合
5. Tbl_OrgMember 直接合
6. Tbl_Prince 皇子 直接合
7. Tbl_Officer 直接合
8. Tbl_PlayerBaseInfo 直接合
9. Tbl_OrgSkill 直接合
10. Tbl_Princess 妃子 直接合
11. Tbl_City 直接合
12. Tbl_Card 直接合
13. Tbl_Skill 科技 直接合
14. Tbl_TimeSet 直接合
15. Tbl_OrgLog 直接合
16. Tbl_Item 直接合
17. Tbl_Task 直接合
18. Tbl_OrgApply 直接合
19. Tbl_OrgGift 直接合
20. Tbl_Player_Deleted 直接合
21. Tbl_Boss 直接合
22. Tbl_BossRank 直接合
23. Tbl_BossBattle 直接合 ID 是Tbl_Org 联盟ID

    > **自增插入**

24. Tbl_MaillList 需要从把B服的表插入到A服的表中 依赖IDENTITY 自增
25. Tbl_Dinner 需要从把B服的表插入到A服的表中 依赖IDENTITY 自增
26. Tbl_Dinner_Delete 需要从把B服的表插入到A服的表中 依赖IDENTITY 自增

    > **清空**

27. Tbl_Pve 清空
28. Tbl_PlayerPurchase 清空
29. Tbl_TopRank 清空
30. Tbl_Activity 清空

    > **这个表没用到**

31. Tbl_Battle 这个表没用到
32. DB_CONFIG 这个表没用到
33. Tbl_Buff 这个表没用到
34. Tbl_World 这个表没用到
35. Tbl_MailList_Deleted 这个表没用到
36. Tbl_LogPlayer 这个表没用到
37. Tbl_Equip 这个表没用到

```SQL
INSERT into by_actor_2.dbo.Tbl_Org select * from by_actor_1.dbo.Tbl_Org
INSERT into by_actor_2.dbo.Tbl_OrgMember select * from by_actor_1.dbo.Tbl_OrgMember
INSERT into by_actor_2.dbo.Tbl_Prince select * from by_actor_1.dbo.Tbl_Prince
INSERT into by_actor_2.dbo.Tbl_Officer select * from by_actor_1.dbo.Tbl_Officer

INSERT into by_actor_2.dbo.Tbl_Player select * from by_actor_1.dbo.Tbl_Player
INSERT into by_actor_2.dbo.Tbl_PlayerBaseInfo select * from by_actor_1.dbo.Tbl_PlayerBaseInfo
INSERT into by_actor_2.dbo.Tbl_OrgSkill select * from by_actor_1.dbo.Tbl_OrgSkill
INSERT into by_actor_2.dbo.Tbl_Princess select * from by_actor_1.dbo.Tbl_Princess
INSERT into by_actor_2.dbo.Tbl_City select * from by_actor_1.dbo.Tbl_City
INSERT into by_actor_2.dbo.Tbl_Card select * from by_actor_1.dbo.Tbl_Card
INSERT into by_actor_2.dbo.Tbl_Skill select * from by_actor_1.dbo.Tbl_Skill
INSERT into by_actor_2.dbo.Tbl_TimeSet select * from by_actor_1.dbo.Tbl_TimeSet
INSERT into by_actor_2.dbo.Tbl_OrgLog select * from by_actor_1.dbo.Tbl_OrgLog
INSERT into by_actor_2.dbo.Tbl_Item select * from by_actor_1.dbo.Tbl_Item
INSERT into by_actor_2.dbo.Tbl_Task select * from by_actor_1.dbo.Tbl_Task
INSERT into by_actor_2.dbo.Tbl_OrgApply select * from by_actor_1.dbo.Tbl_OrgApply
INSERT into by_actor_2.dbo.Tbl_OrgGift select * from by_actor_1.dbo.Tbl_OrgGift
INSERT into by_actor_2.dbo.Tbl_Player_Deleted select * from by_actor_1.dbo.Tbl_Player_Deleted
INSERT into by_actor_2.dbo.Tbl_Boss select * from by_actor_1.dbo.Tbl_Boss
INSERT into by_actor_2.dbo.Tbl_BossRank select * from by_actor_1.dbo.Tbl_BossRank
INSERT into by_actor_2.dbo.Tbl_BossBattle select * from by_actor_1.dbo.Tbl_BossBattle



```

---

[login_flowchat]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/宫斗登录流程图.png "宫斗登录流程图"
[server_framework]: https://raw.githubusercontent.com/Zirpon/hero/master/resource/宫斗服务器架构图.png "宫斗服务器架构图"