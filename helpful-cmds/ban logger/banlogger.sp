#include <sourcemod>
#include <steamworks>

public Plugin myinfo = {
    name = "BanLogger",
    author = "rose",
    description = "Logs player bans to Discord",
    version = "1.1"
};

#define WEBHOOK_URL "WEBHOOK-HERE"

public void OnPluginStart()
{
    RegAdminCmd("sm_ban", AdminBan_Hook, ADMFLAG_BAN, "Intercepts sm_ban to log to Discord");
}

public Action AdminBan_Hook(int client, int args)
{
    if (args < 3)
    {
        ReplyToCommand(client, "[BanLog] Usage: sm_ban <#userid|name> <time> <reason>");
        return Plugin_Handled;
    }

    // Get target name
    char targetName[64];
    GetCmdArg(1, targetName, sizeof(targetName));

    int target = FindTarget(client, targetName, true, false);
    if (target <= 0) return Plugin_Handled;

    // Get duration
    char timeStr[16];
    GetCmdArg(2, timeStr, sizeof(timeStr));
    int duration = StringToInt(timeStr);

    // Get reason
    char reason[128];
    GetCmdArgString(reason, sizeof(reason));

    // Store values in a DataPack
    DataPack dp;
    CreateDataTimer(0.5, Timer_LogBan, dp);
    dp.WriteCell(GetClientUserId(target));
    dp.WriteCell(GetClientUserId(client));
    dp.WriteCell(duration);
    dp.WriteString(reason);

    return Plugin_Continue;
}

public Action Timer_LogBan(Handle timer, DataPack dp)
{
    dp.Reset();

    int targetId = dp.ReadCell();
    int adminId = dp.ReadCell();
    int duration = dp.ReadCell();

    char reason[128];
    dp.ReadString(reason, sizeof(reason));

    int client = GetClientOfUserId(targetId);
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Stop;

    char name[64], steamid[32], ip[32], admin[64];
    GetClientName(client, name, sizeof(name));
    GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));
    GetClientIP(client, ip, sizeof(ip));

    int adminClient = GetClientOfUserId(adminId);
    if (adminClient > 0)
        GetClientName(adminClient, admin, sizeof(admin));
    else
        strcopy(admin, sizeof(admin), "Console");

    char payload[1024];
    Format(payload, sizeof(payload), "{ \"embeds\": [ { \"title\": \"🔨 Player Banned\", \"color\": 16711680, \"fields\": [ { \"name\": \"Name\", \"value\": \"%s\" }, { \"name\": \"SteamID\", \"value\": \"%s\" }, { \"name\": \"IP\", \"value\": \"%s\" }, { \"name\": \"Banned By\", \"value\": \"%s\" }, { \"name\": \"Duration\", \"value\": \"%d minute(s)\" }, { \"name\": \"Reason\", \"value\": \"%s\" } ] } ] }", name, steamid, ip, admin, duration, reason);

    Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, WEBHOOK_URL);
    SteamWorks_SetHTTPRequestRawPostBody(hRequest, "application/json", payload, strlen(payload));
    SteamWorks_SendHTTPRequest(hRequest);

    return Plugin_Stop;
}
