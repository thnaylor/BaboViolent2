#ifndef _STATUS_SERVER_H
#define _STATUS_SERVER_H

#include <vector>
#include <string>

class cMasterServer;

// Minimal single-route HTTP server: any request gets the current game list
// as JSON (see discord-bot/STATUS_ENDPOINT.md for the exact contract).
//
// Polled from the main loop right alongside the BaboNet server (see
// cNetManager::Update) -- this process has no threads, so cMasterServer's
// game list can be read here with no locking.
class cStatusServer
{
public:
	cStatusServer();
	~cStatusServer();

	// Starts listening on listenPort. listenPort == 0 disables the status
	// server entirely (Update() becomes a no-op). Returns false on failure.
	bool Start(unsigned short listenPort);

	void Update(float elapsed, cMasterServer *masterServer);

private:
	struct Connection
	{
		int socketFD;
		float age;			// seconds since accept(); used for the idle/slow-client timeout
		std::string request;		// bytes received so far, until we see the end of headers
	};

	int m_listenSocket;
	std::vector<Connection> m_connections;

	void acceptNew();
	void serviceConnections(float elapsed, cMasterServer *masterServer);
	void respond(int socketFD, cMasterServer *masterServer);
};

#endif
