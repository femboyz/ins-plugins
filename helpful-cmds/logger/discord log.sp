#include <sourcemod>
#include <steamworks>

public Plugin myinfo = {
    name = "Logger_Discord",
    author = "rose",
    description = "Logs player name, IP, and SteamID to Discord using SteamWorks",
    version = "1.0"
};

#define WEBHOOK_URL "WEBHOOK-HERE"

public void OnClientPutInServer(int client)
{
    if (!IsClientConnected(client) || !IsClientInGame(client))
        return;

    // Delay so SteamID/IP are available
    CreateTimer(2.0, Timer_LogJoin, GetClientUserId(client));
}

public Action Timer_LogJoin(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client))
        return Plugin_Stop;

    char name[64];
    GetClientName(client, name, sizeof(name));

    char ip[32];
    GetClientIP(client, ip, sizeof(ip));

    char steamid[32];
    SteamWorks_GetClientSteamID(client, steamid, sizeof(steamid));


    SendJoinLogToDiscord(name, ip, steamid);
    return Plugin_Stop;
}

void SendJoinLogToDiscord(const char[] name, const char[] ip, const char[] steamid)
{
    char payload[1024];
    Format(payload, sizeof(payload), "{ \"embeds\": [ { \"title\": \"🔗 Player Connected\", \"color\": 3447003, \"fields\": [ { \"name\": \"Name\", \"value\": \"%s\" }, { \"name\": \"IP Address\", \"value\": \"%s\" }, { \"name\": \"SteamID\", \"value\": \"%s\" } ] } ] }", name, ip, steamid);

    Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, WEBHOOK_URL);
    SteamWorks_SetHTTPRequestRawPostBody(hRequest, "application/json", payload, strlen(payload));
    SteamWorks_SendHTTPRequest(hRequest);
}
