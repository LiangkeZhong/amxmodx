/* AMX Mod X script.
*
* (c) 2002-2004, OLO
*  modified by the AMX Mod X Development Team
*
* This file is provided as is (no warranties).
*/

#include <amxmod>
#include <amxmisc>

// Uncomment if you want to display
// names with hud messages
//#define SHOW_NAMES

new g_logFile[16]
new g_msgChannel

#define MAX_CLR 7
new g_Colors[MAX_CLR][] = {"white","red","green","blue","yellow","magenta","cyan"}
new g_Values[MAX_CLR][] = {{255,255,255},{255,0,0},{0,255,0},{0,0,255},{255,255,0},{255,0,255},{0,255,255}}
new Float:g_Pos[4][] = {{0.0,0.0},{0.05,0.55},{-1.0,0.2},{-1.0,0.7}} 

public plugin_init(){
  register_plugin("Admin Chat","0.1","default")
  register_clcmd("say","cmdSayChat",ADMIN_CHAT,"@[@|@|@][w|r|g|b|y|m|c]<text> - displays hud message")
  register_clcmd("say_team","cmdSayAdmin",0,"@<text> - displays message to admins")
  register_concmd("amx_say","cmdSay",ADMIN_CHAT,"<message> - sends message to all players")
  register_concmd("amx_chat","cmdChat",ADMIN_CHAT,"<message> - sends message to admins")
  register_concmd("amx_psay","cmdPsay",ADMIN_CHAT,"<name or #userid> <message> - sends private message")
  register_concmd("amx_tsay","cmdTsay",ADMIN_CHAT,"<color> <message> - sends left side hud message to all players")
  register_concmd("amx_csay","cmdTsay",ADMIN_CHAT,"<color> <message> - sends center hud message to all players")
  get_logfile(g_logFile,15)
}

public cmdSayChat(id) { 
  if (!(get_user_flags(id)&ADMIN_CHAT)) return PLUGIN_CONTINUE 
  new said[6], i=0  
  read_argv(1,said,5)
  while (said[i]=='@')
    i++ 
  if ( !i || i > 3 ) return PLUGIN_CONTINUE 
  new message[192], a = 0
  read_args(message,191)
  remove_quotes(message)
  switch(said[i]){ 
    case 'r': a = 1 
    case 'g': a = 2 
    case 'b': a = 3 
    case 'y': a = 4 
    case 'm': a = 5 
    case 'c': a = 6 
  }
  new name[32], authid[32], userid
  get_user_authid(id,authid,31)
  get_user_name(id,name,31)
  userid = get_user_userid(id)
  log_to_file(g_logFile,"Chat: ^"%s<%d><%s><>^" tsay ^"%s^"",name,userid,authid,message[i+1])
  log_message("^"%s<%d><%s><>^" triggered ^"amx_tsay^" (text ^"%s^") (color ^"%s^")",
    name,userid,authid,message[ i+1 ],g_Colors[a])
  if (++g_msgChannel>6||g_msgChannel<3)
    g_msgChannel = 3
  new Float:verpos = g_Pos[i][1] + float(g_msgChannel) / 35.0
  set_hudmessage(g_Values[a][0], g_Values[a][1], g_Values[a][2], 
    g_Pos[i][0], verpos , 0, 6.0, 6.0, 0.5, 0.15, g_msgChannel )  

#if defined SHOW_NAMES    
  show_hudmessage(0,"%s :   %s",name,message[i+1])  
  client_print(0,print_notify,"%s :   %s",name,message[i+1])
#else
  show_hudmessage(0,message[i+1])  
  client_print(0,print_notify,message[i+1])
#endif

  return PLUGIN_HANDLED 
}

public cmdSayAdmin(id) { 
  new said[2]
  read_argv(1,said,1)
  if (said[0]!='@') return PLUGIN_CONTINUE
  new message[192], name[32],authid[32], userid
  new players[32], inum
  read_args(message,191)
  remove_quotes(message)
  get_user_authid(id,authid,31)
  get_user_name(id,name,31)
  userid = get_user_userid(id)  
  log_to_file(g_logFile,"Chat: ^"%s<%d><%s><>^" chat ^"%s^"",name,userid,authid,message[1])
  log_message("^"%s<%d><%s><>^" triggered ^"amx_chat^" (text ^"%s^")",name,userid,authid,message[1])
  format(message,191,"(ADMINS) %s :  %s",name,message[1])
  get_players(players,inum)     
  for(new i=0; i<inum; ++i){
    if (players[i] != id && get_user_flags(players[i]) & ADMIN_CHAT)
      client_print(players[i],print_chat,message)
  }
  client_print(id,print_chat,message)   
  return PLUGIN_HANDLED 
} 

public cmdChat(id,level,cid){
  if (!cmd_access(id,level,cid,2))
    return PLUGIN_HANDLED
  new message[192], name[32], players[32], inum, authid[32], userid
  read_args(message,191)
  remove_quotes(message)
  get_user_authid(id,authid,31)
  get_user_name(id,name,31)
  userid = get_user_userid(id)
  get_players(players,inum)
  log_to_file(g_logFile,"Chat: ^"%s<%d><%s><>^" chat ^"%s^"",name,userid,authid,message)
  log_message("^"%s<%d><%s><>^" triggered ^"amx_chat^" (text ^"%s^")",name,userid,authid,message)
  format(message,191,"(ADMINS) %s :   %s",name,message)
  console_print(id,message)
  for(new i = 0; i < inum; ++i){
    if ( get_user_flags(players[i]) & ADMIN_CHAT )
      client_print(players[i],print_chat,message)
  }
  return PLUGIN_HANDLED
}

public cmdSay(id,level,cid){
  if (!cmd_access(id,level,cid,2))
    return PLUGIN_HANDLED
  new message[192], name[32],authid[32], userid
  read_args(message,191)
  remove_quotes(message)
  get_user_authid(id,authid,31)
  get_user_name(id,name,31)
  userid = get_user_userid(id)
  client_print(0,print_chat,"(ALL) %s :   %s",name,message)
  console_print(id,"(ALL) %s :   %s",name,message)
  log_to_file(g_logFile,"Chat: ^"%s<%d><%s><>^" say ^"%s^"",  name,userid,authid,message)
  log_message("^"%s<%d><%s><>^" triggered ^"amx_say^" (text ^"%s^")",name,userid,authid,message)
  return PLUGIN_HANDLED
}

public cmdPsay(id,level,cid){
  if (!cmd_access(id,level,cid,3))
    return PLUGIN_HANDLED
  new name[32]
  read_argv(1,name,31)
  new priv = cmd_target(id,name,0)
  if (!priv) return PLUGIN_HANDLED
  new length = strlen(name)+1
  new message[192], name2[32],authid[32],authid2[32], userid, userid2
  get_user_authid(id,authid,31)
  get_user_name(id,name2,31)
  userid = get_user_userid(id)  
  read_args(message,191)
  if (message[0]=='"' && message[length]=='"'){ // HLSW fix
    message[0]=' '
    message[length]=' '
    length+=2
  }
  remove_quotes(message[length])
  get_user_name(priv,name,31)
  if (id&&id!=priv) client_print(id,print_chat,"(%s) %s :   %s",name,name2,message[length])
  client_print(priv,print_chat,"(%s) %s :   %s",name,name2,message[length])
  console_print(id,"(%s) %s :   %s",name,name2,message[length])
  get_user_authid(priv,authid2,31)
  userid2 = get_user_userid(priv)
  log_to_file(g_logFile,"Chat: ^"%s<%d><%s><>^" psay ^"%s<%d><%s><>^" ^"%s^"",
      name2,userid,authid,name,userid2,authid2,message[length])
  log_message("^"%s<%d><%s><>^" triggered ^"amx_psay^" against ^"%s<%d><%s><>^" (text ^"%s^")",
    name2,userid,authid,name,userid2,authid2,message[length])
  return PLUGIN_HANDLED
}

public cmdTsay(id,level,cid){
  if (!cmd_access(id,level,cid,3))
    return PLUGIN_HANDLED
  new cmd[16],color[12], message[192], name[32], authid[32], userid = 0
  read_argv(0,cmd,15)
  new bool:tsay = (tolower(cmd[4]) == 't')
  read_args(message,191)
  remove_quotes(message)
  parse(message,color,11)
  new found = 0,a = 0
  for(new i=0;i<MAX_CLR;++i)
    if (equal(color,g_Colors[i])) {
      a = i
      found = 1
      break
    }
  new length = found ? (strlen(color) + 1) : 0
  if (++g_msgChannel>6||g_msgChannel<3)
    g_msgChannel = 3
  new Float:verpos = ( tsay ? 0.55 : 0.1 ) + float(g_msgChannel) / 35.0
  get_user_authid(id,authid,31)
  get_user_name(id,name,31)
  userid = get_user_userid(id)
  set_hudmessage(g_Values[a][0], g_Values[a][1], g_Values[a][2], tsay ? 0.05 :  -1.0, verpos, 0, 6.0, 6.0, 0.5, 0.15, g_msgChannel)

#if defined SHOW_NAMES   
  show_hudmessage(0,"%s :   %s",name,message[length])
  client_print(0,print_notify,"%s :   %s",name,message[length])
  console_print(id,"%s :   %s",name,message[length])
#else
  show_hudmessage(0,message[length])
  client_print(0,print_notify,message[length])
  console_print(id,message[length])
#endif

  log_to_file(g_logFile,"Chat: ^"%s<%d><%s><>^" %s ^"%s^"",name,userid,authid,cmd[4],message[length])
  log_message("^"%s<%d><%s><>^" triggered ^"%s^" (text ^"%s^") (color ^"%s^")",
    name,userid,authid,cmd,message[length],g_Colors[a])
  return PLUGIN_HANDLED
}