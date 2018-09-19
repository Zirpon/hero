#ifndef GETPACKETIDENTIFIER_H_INCLUDED
#define GETPACKETIDENTIFIER_H_INCLUDED
 
unsigned char GetPacketIdentifier(RakNet::Packet *p)
{
	if (p==0)
		return 255;
 
	if ((unsigned char)p->data[0] == ID_TIMESTAMP)
	{
		RakAssert(p->length > sizeof(RakNet::MessageID) + sizeof(RakNet::Time));
		return (unsigned char) p->data[sizeof(RakNet::MessageID) + sizeof(RakNet::Time)];
	}
	else
		return (unsigned char) p->data[0];
}
 
#endif // GETPACKETIDENTIFIER_H_INCLUDED
