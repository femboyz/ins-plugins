#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
StringMap g_CooldownMap;
#define DEFAULT_COOLDOWN 5.0

public Plugin myinfo = 
{
    name = "anarchybot",
    author = "rose",
    description = "does some shit",
    version = "1.1",
    url = ""
};

public void OnPluginStart()
{
	g_CooldownMap = new StringMap();
    RegConsoleCmd("sm_bothelp", BotHelp, "show bot cmds");
    RegConsoleCmd("sm_sex", sex, "sex");
    RegConsoleCmd("sm_penis", penis, "big pens");
    RegConsoleCmd("sm_whogay", whogay, "show who gay");
    RegConsoleCmd("sm_fly", fakefly, "you fly duh");
    RegConsoleCmd("sm_gaysex", gaysex, "gay sex");
}

bool CheckCooldown(int client, const char[] commandName, float cooldownTime = DEFAULT_COOLDOWN) {
    char key[128];
    Format(key, sizeof(key), "%d_%s", client, commandName);
    
    float lastUseTime;
    float currentTime = GetGameTime();
    
    if (g_CooldownMap.GetValue(key, lastUseTime)) {
        float timeSinceLastUse = currentTime - lastUseTime;
        
        if (timeSinceLastUse < cooldownTime) {
            float timeRemaining = cooldownTime - timeSinceLastUse;
            ReplyToCommand(client, "\x02Please wait %.1f more seconds before using this command again!", timeRemaining);
            return false;
        }
    }
    
    g_CooldownMap.SetValue(key, currentTime);
    return true;
}

public Action BotHelp(int client, int args) 
{
	if (args > 0)
    {
        ReplyToCommand(client, "Usage: !bothelp");
        return Plugin_Handled;
    }
    
	PrintToChatAll("Hi! I'm AnarchyBOT, here's a list of my cmds");
	PrintToChatAll("!bothelp, !report, !sex, !penis, !whogay, !fly, !gaysex");
	return Plugin_Handled;
}

public Action sex(int client, int args) 
{
	if (args > 0)
    {
        ReplyToCommand(client, "Usage: !sex");
        return Plugin_Handled;
    }
    
	PrintToChatAll("AnarchyBOT: Sexual content has been banned from Insurgency!");
	ForcePlayerSuicide(client);
	return Plugin_Handled;
}

public Action gaysex(int client, int args) 
{
	if (args > 0)
    {
        ReplyToCommand(client, "Usage: !gaysex");
        return Plugin_Handled;
    }
    
	PrintToChatAll("AnarchyBOT: Sexual content has been banned from Insurgency!");
	ForcePlayerSuicide(client);
	return Plugin_Handled;
}

public Action penis(int client, int args) 
{
	int randomPP = GetRandomInt(1, 18);
	PrintToChatAll("AnarchyBOT: Your penis is %d inches long!", randomPP);
	return Plugin_Handled;
}

public Action whogay(int client, int args) 
{
	int validPlayers[64];
    int playerCount = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i))
        {
            validPlayers[playerCount] = i;
            playerCount++;
        }
    }
    if (playerCount == 0)
    {
        ReplyToCommand(client, "\x02No players available to choose from!");
        return Plugin_Handled;
    }
    
    int randomIndex = GetRandomInt(0, playerCount - 1);
    char playerName[64];
    GetClientName(validPlayers[randomIndex], playerName, sizeof(playerName));
    
    PrintToChatAll("AnarchyBOT: \x04I think \x03%s \x04is gay!", playerName);
    return Plugin_Handled;
}

public Action fakefly(int client, int args) 
{
	if (args < 0)
    {
        ReplyToCommand(client, "Usage: !fly");
        return Plugin_Handled;
    }
    
	if (!IsClientInGame(client))
    {
        ReplyToCommand(client, "\x02You must be in-game to use this command!");
        return Plugin_Handled;
    }
    
    if (!CheckCooldown(client, "fly", 5.0)) {
        return Plugin_Handled;
    }
    
    SlapPlayer(client, 0);
    PrintToChatAll("\x04%s tried to fly but got whipped instead!", client);
    return Plugin_Handled;
}



