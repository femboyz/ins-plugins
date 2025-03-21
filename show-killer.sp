#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "rose"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "player kill thing",
	author = PLUGIN_AUTHOR,
	description = "show death records",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeath);
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    if (!IsClientInGame(victim) || !IsClientInGame(attacker) || victim == attacker)
        return Plugin_Continue;

    char attackerName[64];
    GetClientName(attacker, attackerName, sizeof(attackerName));
    int attackerHealth = GetClientHealth(attacker);

    ShowKillerInfoMenu(victim, attackerName, attackerHealth);

    return Plugin_Continue;
}

void ShowKillerInfoMenu(int client, const char[] killerName, int health)
{
    Menu menu = new Menu(MenuHandler_DoNothing);
    char buffer[128];
    Format(buffer, sizeof(buffer), "You were killed by %s", killerName);
    menu.SetTitle(buffer);

    Format(buffer, sizeof(buffer), "They had %d HP left.", health);
    menu.AddItem("noop", buffer);

    menu.Display(client, 5); // Show menu for 5 seconds
}

public int MenuHandler_DoNothing(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_End)
        delete menu;

    return 0;
}
