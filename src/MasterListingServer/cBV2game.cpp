#include "cBV2game.h"

#include <stdio.h>

// RFC1918 / loopback / link-local / CGNAT ranges — addresses a game client on
// the internet could never reach directly.
static bool ipIsPrivate(const char *ip)
{
	unsigned a = 0, b = 0;
	if (!ip || sscanf(ip, "%u.%u", &a, &b) != 2) return true; // unparsable: treat as private
	if (a == 10 || a == 127) return true;
	if (a == 172 && b >= 16 && b <= 31) return true;
	if (a == 192 && b == 168) return true;
	if (a == 169 && b == 254) return true;
	if (a == 100 && b >= 64 && b <= 127) return true;
	return false;
}

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

	// The observed TCP peer address is authoritative whenever it's public:
	// in the normal no-Docker case NAT rewrites the connection's source to
	// the server's real public IP, which is exactly what players need. Only
	// when the peer address is private (master and game server behind the
	// same NAT/Docker bridge, so the master sees a 172.x/192.168.x gateway)
	// do we trust the server's self-reported IP (which honors SV_IP). The
	// UDP ping/pong handshake still verifies reachability independently, so
	// a bogus self-reported IP just shows up unreachable.
	if(GameInfos.Priority == 0)
	{
		if(GameInfos.ip[0] == '\0' || !ipIsPrivate(ip))
		{
			sprintf(GameInfos.ip,ip);
		}
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
