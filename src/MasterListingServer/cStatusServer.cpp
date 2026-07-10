#include "cStatusServer.h"
#include "cMasterServer.h"

#include <cstdio>
#include <cerrno>
#include <cstring>

#ifdef WIN32
	#define WIN32_MEAN_AND_LEAN
	#include "winsock2.h"
#else
	#include "LinuxHeader.h"
#endif

namespace
{
	const int MAX_CONNECTIONS = 32;		// cap concurrent clients; extras are accepted then dropped
	const size_t MAX_REQUEST_BYTES = 8192;		// enough for any real HTTP GET's headers
	const float IDLE_TIMEOUT_SECONDS = 10.0f;	// a real browser/bot finishes its request line almost instantly

	void closeSocketFD(int socketFD)
	{
#ifdef WIN32
		closesocket(socketFD);
#else
		close(socketFD);
#endif
	}

	bool setNonBlocking(int socketFD)
	{
#ifdef WIN32
		u_long mode = 1;
		return ioctlsocket(socketFD, FIONBIO, &mode) == 0;
#else
		int flags = fcntl(socketFD, F_GETFL, 0);
		if (flags == -1) return false;
		return fcntl(socketFD, F_SETFL, flags | O_NONBLOCK) != -1;
#endif
	}

	bool wouldBlock()
	{
#ifdef WIN32
		return WSAGetLastError() == WSAEWOULDBLOCK;
#else
		return errno == EWOULDBLOCK || errno == EAGAIN;
#endif
	}
}

cStatusServer::cStatusServer()
{
	m_listenSocket = -1;
}

cStatusServer::~cStatusServer()
{
	for (size_t i = 0; i < m_connections.size(); i++)
		closeSocketFD(m_connections[i].socketFD);

	if (m_listenSocket != -1)
		closeSocketFD(m_listenSocket);
}

bool cStatusServer::Start(unsigned short listenPort)
{
	if (listenPort == 0)
	{
		printf("Status HTTP server disabled (STATUS_PORT=0)\n");
		return true;
	}

	m_listenSocket = (int)socket(AF_INET, SOCK_STREAM, 0);
	if (m_listenSocket == -1)
	{
		printf("Status HTTP server: socket() failed\n");
		return false;
	}

	int yes = 1;
	setsockopt(m_listenSocket, SOL_SOCKET, SO_REUSEADDR, (const char*)&yes, sizeof(yes));

	sockaddr_in addr;
	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = INADDR_ANY;
	addr.sin_port = htons(listenPort);

	if (bind(m_listenSocket, (sockaddr*)&addr, sizeof(addr)) == -1)
	{
		printf("Status HTTP server: bind() on port %u failed\n", (unsigned)listenPort);
		closeSocketFD(m_listenSocket);
		m_listenSocket = -1;
		return false;
	}

	if (listen(m_listenSocket, 16) == -1)
	{
		printf("Status HTTP server: listen() on port %u failed\n", (unsigned)listenPort);
		closeSocketFD(m_listenSocket);
		m_listenSocket = -1;
		return false;
	}

	setNonBlocking(m_listenSocket);

	printf("Status HTTP server listening on port %u (GET /status.json)\n", (unsigned)listenPort);
	return true;
}

void cStatusServer::Update(float elapsed, cMasterServer *masterServer)
{
	if (m_listenSocket == -1) return;

	acceptNew();
	serviceConnections(elapsed, masterServer);
}

void cStatusServer::acceptNew()
{
	while (true)
	{
		int fd = (int)accept(m_listenSocket, NULL, NULL);
		if (fd == -1) break;	// EWOULDBLOCK: nothing pending

		if ((int)m_connections.size() >= MAX_CONNECTIONS)
		{
			closeSocketFD(fd);	// at capacity; drop it, don't let it starve real clients
			continue;
		}

		setNonBlocking(fd);

		Connection c;
		c.socketFD = fd;
		c.age = 0.0f;
		m_connections.push_back(c);
	}
}

void cStatusServer::serviceConnections(float elapsed, cMasterServer *masterServer)
{
	for (size_t i = 0; i < m_connections.size();)
	{
		Connection &c = m_connections[i];
		c.age += elapsed;

		char buf[1024];
		bool closed = false;
		bool gotHeaders = false;

		while (true)
		{
			int n = (int)recv(c.socketFD, buf, sizeof(buf), 0);
			if (n > 0)
			{
				c.request.append(buf, (size_t)n);
				if (c.request.size() > MAX_REQUEST_BYTES)
				{
					closed = true;
					break;
				}
				if (c.request.find("\r\n\r\n") != std::string::npos)
				{
					gotHeaders = true;
					break;
				}
			}
			else if (n == 0)
			{
				closed = true;	// peer closed before finishing a request
				break;
			}
			else
			{
				if (!wouldBlock()) closed = true;
				break;
			}
		}

		if (gotHeaders)
		{
			respond(c.socketFD, masterServer);
			closed = true;
		}
		else if (!closed && c.age > IDLE_TIMEOUT_SECONDS)
		{
			// Mirrors the dedicated server's PLAYER_STATUS_LOADING fix: a
			// connection that never finishes sending its request (port
			// scan, dead client) must not sit open forever.
			closed = true;
		}

		if (closed)
		{
			closeSocketFD(c.socketFD);
			m_connections.erase(m_connections.begin() + i);
		}
		else
		{
			i++;
		}
	}
}

void cStatusServer::respond(int socketFD, cMasterServer *masterServer)
{
	std::string body = masterServer->BuildStatusJson();

	char header[256];
	snprintf(header, sizeof(header),
		"HTTP/1.1 200 OK\r\n"
		"Content-Type: application/json\r\n"
		"Content-Length: %u\r\n"
		"Connection: close\r\n"
		"\r\n",
		(unsigned)body.size());

	// Best-effort single send(): responses are a few hundred bytes to a few
	// KB (one connected-server entry apiece), which fits well inside the
	// default socket send buffer, so partial writes in practice don't
	// happen. This is a low-stakes monitoring endpoint -- if a send ever
	// did fall short, the caller just gets a truncated body and retries on
	// its next poll.
	send(socketFD, header, (int)strlen(header), 0);
	send(socketFD, body.data(), (int)body.size(), 0);
}
