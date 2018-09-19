#include "MessageIdentifiers.h"
#include "RakPeerInterface.h"
#include "RakNetTypes.h"
 
#include "RakSleep.h"
#include "Kbhit.h"
#include "Gets.h"
 
#include "GetPacketIdentifier.h"
 
// 监听端口
#define SERVER_PORT 60005
 
int main(void)
{
    RakNet::RakPeerInterface *server=RakNet::RakPeerInterface::GetInstance();
	server->SetIncomingPassword("user_defined_string", (int)strlen("user_defined_string"));
	server->SetTimeoutTime(30000,RakNet::UNASSIGNED_SYSTEM_ADDRESS);
 
	RakNet::Packet* p;  // 保存接收的数据在
    unsigned char packetIdentifier; // 包类型
 
    RakNet::SystemAddress clientID=RakNet::UNASSIGNED_SYSTEM_ADDRESS;
	char message[2048];
 
	// IPV4/IPV6
	RakNet::SocketDescriptor socketDescriptors[2];
	socketDescriptors[0].port=SERVER_PORT;
	socketDescriptors[0].socketFamily=AF_INET; // Test out IPV4
	socketDescriptors[1].port=SERVER_PORT;
	socketDescriptors[1].socketFamily=AF_INET6; // Test out IPV6
 
	bool b = server->Startup(4, socketDescriptors, 2 )==RakNet::RAKNET_STARTED;
	server->SetMaximumIncomingConnections(4);
 
	if (!b) {
        // 不支持IPV6，尝试使用IPV4
        printf("Failed to start dual IPV4 and IPV6 ports. Trying IPV4 only.\n");
 
        b = server->Startup(4, socketDescriptors, 1 )==RakNet::RAKNET_STARTED;
        if (!b) {
            // 彻底失败啦，连IPV4都启用不了
            puts("Server failed to start.  Terminating.");
			exit(1);
        }
	}
 
	server->SetOccasionalPing(true);
	server->SetUnreliableTimeout(1000);
 
	// 保证线程终止
	while (1)
	{
        RakSleep(30); // 每次循环睡眠时间，这个时间的长短基于应用的实时性要求
 
        // 这里是实时监控Server端是否有输入信息，有的话就发送
        // 可以达到Server与Client的通讯对话
        if (kbhit())
        {
            Gets(message,sizeof(message));
            puts(message); // 输出自己敲打的信息
            server->Send(message, (int) strlen(message)+1, HIGH_PRIORITY, RELIABLE_ORDERED, 0, RakNet::UNASSIGNED_SYSTEM_ADDRESS, true);
        }
 
        // 下面是监听端口，接受来之客户端的连接和状态值以及信息的通讯
        for (p=server->Receive(); p; server->DeallocatePacket(p), p=server->Receive())
        {
            packetIdentifier = GetPacketIdentifier(p); // 哈哈，解码吧～～
 
            // 看看是什么信息吧，有的是文字信息，有的是连接请求，有的则是断开连接等等
            switch (packetIdentifier)
			{
			case ID_DISCONNECTION_NOTIFICATION:
				// Connection lost normally
				printf("ID_DISCONNECTION_NOTIFICATION from %s\n", p->systemAddress.ToString(true));
				break;
 
 
			case ID_NEW_INCOMING_CONNECTION:
				// 新连接
				printf("ID_NEW_INCOMING_CONNECTION from %s with GUID %s\n", p->systemAddress.ToString(true), p->guid.ToString());
				clientID=p->systemAddress; // Record the player ID of the client
				break;
 
			case ID_INCOMPATIBLE_PROTOCOL_VERSION:
				printf("ID_INCOMPATIBLE_PROTOCOL_VERSION\n");
				break;
 
 
			case ID_CONNECTION_LOST:
				// 客户端断开连接或者网络暂时中断
				printf("ID_CONNECTION_LOST from %s\n", p->systemAddress.ToString(true));
				break;
 
			default:
				// 这里才是我们平时工作的地方，处理信息，判断逻辑，完成业务
 
				// 打印客户端发来的信息
				printf("%s\n", p->data);
 
				// 把信息同步给其它客户终端，这样就相当是一个聊天室了。
				sprintf(message, "%s", p->data);
				server->Send(message, (const int) strlen(message)+1, HIGH_PRIORITY, RELIABLE_ORDERED, 0, p->systemAddress, true);
 
				break;
			}
 
        }
	}
 
	// 不要忘记关闭实例哦，否则端口不及时释放会影响我们的监护进程重启主进程
	server->Shutdown(300);
	RakNet::RakPeerInterface::DestroyInstance(server);
 
	return 0;
}
