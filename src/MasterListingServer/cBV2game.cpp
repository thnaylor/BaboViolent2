#include "cBV2game.h"


cBV2game::cBV2game()
{
	Next		=	0;
	Previous	=	0;

	LastCheck	=	0;
	//ID			=	0;
	//ServerID	=	0;
}

cBV2game::cBV2game(char *ip,stBV2row & gameinfos, unsigned long baboID)
{
	Next		=	0;
	Previous	=	0;

	LastCheck	=	0;
	//ServerID	=	0;

	BaboID		=	baboID;

	memcpy(&GameInfos,&gameinfos,sizeof(stBV2row));

	// Trust the server's self-reported IP (honors SV_IP behind Docker NAT) when
	// it sent one; only fall back to the observed TCP peer address for older
	// clients that leave it blank. The UDP ping/pong handshake verifies
	// reachability independently, so a bogus self-reported IP just shows up
	// unreachable rather than being trusted blindly.
	if(GameInfos.Priority == 0 && GameInfos.ip[0] == '\0')
	{
		sprintf(GameInfos.ip,ip);
	}
}

int cBV2game::Update(float elapsed)
{
	LastCheck += elapsed;

	if(LastCheck >= (GameInfos.Priority ? GAME_TIMEOUT * 5 : GAME_TIMEOUT))
	{
		//si on arrive a une minute, la game est morte
		return 1;
	}

	return 0;
}
