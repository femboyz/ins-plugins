#include <sourcemod>
#include <steamworks>

public Plugin myinfo = {
    name = "DiscordReport",
    author = "rose",
    description = "Reports players via SteamWorks HTTP",
    version = "1.0"
};

#define WEBHOOK_URL "WEBHOOK-HERE"

public void OnPluginStart()
{
    RegConsoleCmd("sm_report", Command_Report, "Usage: sm_report <playername> <reason>");
}

public Action Command_Report(int client, int args)
{
    if (args < 2)
    {
        PrintToChat(client, "[Report] Usage: sm_report <playername> <reason>");
        return Plugin_Handled;
    }

    char target[64];
    GetCmdArg(1, target, sizeof(target));

    char input[256];
    GetCmdArgString(input, sizeof(input));

    int skipLen = strlen(target);
    if (strlen(input) <= skipLen + 1)
    {
        PrintToChat(client, "[Report] Please provide a reason.");
        return Plugin_Handled;
    }

    char reason[192];
    strcopy(reason, sizeof(reason), input[skipLen + 1]);

    char reporter[64];
    GetClientName(client, reporter, sizeof(reporter));

    SendToDiscord(reporter, target, reason);
    PrintToChat(client, "[Report] Your report has been submitted.");
    return Plugin_Handled;
}

void SendToDiscord(const char[] reporter, const char[] target, const char[] reason)
{
    char payload[1024];
    Format(payload, sizeof(payload), "{ \"embeds\": [ { \"title\": \"📝 Player Report\", \"color\": 15158332, \"fields\": [{ \"name\": \"Reporter\", \"value\": \"%s\" }, { \"name\": \"Reported Player\", \"value\": \"%s\" }, { \"name\": \"Reason\", \"value\": \"%s\" }] } ] }", reporter, target, reason);


    Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, WEBHOOK_URL);
    SteamWorks_SetHTTPRequestRawPostBody(hRequest, "application/json", payload, strlen(payload));
    SteamWorks_SendHTTPRequest(hRequest);

}
