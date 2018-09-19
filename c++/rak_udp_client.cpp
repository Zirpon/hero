#include "MessageIdentifiers.h"
#include "RakPeerInterface.h"
#include "RakNetTypes.h"
 
#include "RakSleep.h"
#include "Kbhit.h"
#include "Gets.h"
 
#include "../ChatServer/GetPacketIdentifier.h" // 路径根据应用实际部署调整
 
// 服务器端口
#define SERVER_PORT 60005
 
int main(void)
{
    // new 一个UDP通讯客户端实例
    RakNet::RakPeerInterface *client = RakNet::RakPeerInterface::GetInstance();
    client->AllowConnectionResponseIPMigration(false);
 
    // 客户端连接端口，不能写死了，要不就启动不了多个客户端，让用户自己输入本次想要使用的端口
    char clientPort[30];
    puts("Enter the client port to listen on");
	Gets(clientPort,sizeof(clientPort));
 
	 // 设置客户端连接端口
    RakNet::SocketDescriptor socketDescriptor(atoi(clientPort), 0);
	socketDescriptor.socketFamily = AF_INET;
 
	client->Startup(8,&socketDescriptor, 1);
	client->SetOccasionalPing(true);
 
	// 连接服务器
	RakNet::ConnectionAttemptResult car = client->Connect("127.0.0.1", SERVER_PORT, "user_defined_string", (int) strlen("user_defined_string"));
    RakAssert(car == RakNet::CONNECTION_ATTEMPT_STARTED);
 
    RakNet::Packet* p;  // 保存接收的数据在
    unsigned char packetIdentifier; // 包类型
	char message[2048];
 
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
            client->Send(message, (int) strlen(message)+1, HIGH_PRIORITY, RELIABLE_ORDERED, 0, RakNet::UNASSIGNED_SYSTEM_ADDRESS, true);
        }
 
        // 下面是监听端口，接受来之客户端的连接和状态值以及信息的通讯
        for (p=client->Receive(); p; client->DeallocatePacket(p), p=client->Receive())
        {
            packetIdentifier = GetPacketIdentifier(p); // 哈哈，解码吧～～
 
            // 跟服务端一样，判断信息类型
            switch (packetIdentifier)
            {
            case ID_DISCONNECTION_NOTIFICATION:
                printf("ID_DISCONNECTION_NOTIFICATION\n");
                break;
            case ID_ALREADY_CONNECTED:
                // Connection lost normally
                printf("ID_ALREADY_CONNECTED\n");
                break;
            case ID_INCOMPATIBLE_PROTOCOL_VERSION:
                printf("ID_INCOMPATIBLE_PROTOCOL_VERSION\n");
                break;
            case ID_REMOTE_DISCONNECTION_NOTIFICATION: // Server telling the clients of another client disconnecting gracefully.  You can manually broadcast this in a peer to peer enviroment if you want.
                printf("ID_REMOTE_DISCONNECTION_NOTIFICATION\n");
                break;
            case ID_REMOTE_CONNECTION_LOST: // Server telling the clients of another client disconnecting forcefully.  You can manually broadcast this in a peer to peer enviroment if you want.
                printf("ID_REMOTE_CONNECTION_LOST\n");
                break;
            case ID_REMOTE_NEW_INCOMING_CONNECTION: // Server telling the clients of another client connecting.  You can manually broadcast this in a peer to peer enviroment if you want.
                printf("ID_REMOTE_NEW_INCOMING_CONNECTION\n");
                break;
            case ID_CONNECTION_BANNED: // Banned from this server
                printf("We are banned from this server.\n");
                break;
            case ID_CONNECTION_ATTEMPT_FAILED:
                printf("Connection attempt failed\n");
                break;
            case ID_NO_FREE_INCOMING_CONNECTIONS:
                // Sorry, the server is full.  I don't do anything here but
                // A real app should tell the user
                printf("ID_NO_FREE_INCOMING_CONNECTIONS\n");
                break;
 
            case ID_INVALID_PASSWORD:
                printf("ID_INVALID_PASSWORD\n");
                break;
 
            case ID_CONNECTION_LOST:
                // Couldn't deliver a reliable packet - i.e. the other system was abnormally
                // terminated
                printf("ID_CONNECTION_LOST\n");
                break;
 
            case ID_CONNECTION_REQUEST_ACCEPTED:
                // This tells the client they have connected
                printf("ID_CONNECTION_REQUEST_ACCEPTED to %s with GUID %s\n", p->systemAddress.ToString(true), p->guid.ToString());
                printf("My external address is %s\n", client->GetExternalID(p->systemAddress).ToString(true));
                break;
            default:
                // It's a client, so just show the message
                printf("%s\n", p->data);
                break;
            }
        }
    }
 
    // 不要忘记关闭实例哦，否则端口不及时释放会影响我们的监护进程重启主进程
	client->Shutdown(300);
	RakNet::RakPeerInterface::DestroyInstance(client);
 
	return 0;
}
