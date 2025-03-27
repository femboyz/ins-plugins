#include <sourcemod>
#include <sdktools>
native bool KvLoadFromFile(Handle kv, const char[] file);
#define CONFIG_FILE "configs/chat_tags.cfg"

Handle kv;

public Plugin myinfo = {
    name = "ChatTags",
    author = "rose",
    version = "1.2",
    description = "Chat tags"
};

public void OnPluginStart()
{
    AddCommandListener(Hook_PlayerChat, "say");
    RegAdminCmd("sm_reloadtags", Command_ReloadTags, ADMFLAG_GENERIC);
    LoadChatTags();
}

void LoadChatTags()
{
    if (kv != null)
        CloseHandle(kv);

    kv = CreateKeyValues("ChatTags");

    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), CONFIG_FILE);

    if (!FileToKeyValues(kv, path))
    {
        LogError("[ChatTags] Failed to load config: %s", path);
    }
}

public Action Command_ReloadTags(int client, int args)
{
    LoadChatTags();
    ReplyToCommand(client, "[ChatTags] Config reloaded.");
    return Plugin_Handled;
}

public Action Hook_PlayerChat(int client, const char[] command, int argc)
{
    if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client))
        return Plugin_Continue;

    char message[256];
    GetCmdArgString(message, sizeof(message));
    if (message[0] == '\"')
    {
        int len = strlen(message);
        if (len > 2) message[len - 1] = '\0';
        strcopy(message, sizeof(message), message[1]);
    }

    char name[64], steamid[32], tag[64] = "", colorName[32] = "", colorCode[10] = "";
    GetClientName(client, name, sizeof(name));
    GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));

    bool hasCustomTag = false;
    if (KvJumpToKey(kv, steamid, false))
    {
        KvGetString(kv, "tag", tag, sizeof(tag));
        KvGetString(kv, "color", colorName, sizeof(colorName));
        KvGoBack(kv);
        hasCustomTag = true;
    }

    if (hasCustomTag && !StrEqual(colorName, ""))
    {
        GetColorCode(colorName, colorCode, sizeof(colorCode));
    }

    // If not listed, skip formatting and let game handle default message
    if (!hasCustomTag)
        return Plugin_Continue;

    char formatted[256];
    if (!StrEqual(tag, "") && !StrEqual(colorCode, ""))
        Format(formatted, sizeof(formatted), "%s%s %s: %s", colorCode, tag, name, message);
    else if (!StrEqual(tag, ""))
        Format(formatted, sizeof(formatted), "%s %s: %s", tag, name, message);
    else
        return Plugin_Continue;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            PrintToChat(i, "%s", formatted);
        }
    }

    return Plugin_Handled;
}

void GetColorCode(const char[] colorName, char[] output, int outputLen)
{
    if (StrEqual(colorName, "red", false))        strcopy(output, outputLen, "\x07FF0000");
    else if (StrEqual(colorName, "green", false)) strcopy(output, outputLen, "\x0700FF00");
    else if (StrEqual(colorName, "blue", false))  strcopy(output, outputLen, "\x070000FF");
    else if (StrEqual(colorName, "yellow", false))strcopy(output, outputLen, "\x07FFFF00");
    else if (StrEqual(colorName, "pink", false))  strcopy(output, outputLen, "\x07FF69B4");
    else if (StrEqual(colorName, "cyan", false))  strcopy(output, outputLen, "\x0700FFFF");
    else if (StrEqual(colorName, "white", false)) strcopy(output, outputLen, "\x07FFFFFF");
    else if (StrEqual(colorName, "gray", false))  strcopy(output, outputLen, "\x07808080");
    else strcopy(output, outputLen, "");
}
