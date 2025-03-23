#include <sourcemod>

public Plugin myinfo = {
    name = "RunCmd",
    author = "rose",
    description = "Run any command on a player",
    version = "1.0"
};

public void OnPluginStart()
{
    RegAdminCmd("sm_runcmd", Command_RunCmd, ADMFLAG_GENERIC, "sm_runcmd <player> <command>");
}

public Action Command_RunCmd(int client, int args)
{
    if (args < 2)
    {
        ReplyToCommand(client, "[RunCmd] Usage: sm_runcmd <player> <command>");
        return Plugin_Handled;
    }

    char targetName[64];
    GetCmdArg(1, targetName, sizeof(targetName));

    int target = FindTarget(client, targetName, true, false);
    if (target <= 0) return Plugin_Handled;

    char command[256];
    GetCmdArgString(command, sizeof(command));

    // Strip the player name from the full string
    int nameLen = strlen(targetName);
    if (strlen(command) <= nameLen + 1)
    {
        ReplyToCommand(client, "[RunCmd] Missing command.");
        return Plugin_Handled;
    }

    char cmdOnly[256];
    strcopy(cmdOnly, sizeof(cmdOnly), command[nameLen + 1]);

    FakeClientCommand(target, "%s", cmdOnly);
    ReplyToCommand(client, "[RunCmd] Ran command on %N: %s", target, cmdOnly);
    return Plugin_Handled;
}
