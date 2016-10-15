/*@u4bi v.03
  @mysql_register_login_gamemode
  @https://github.com/u4bi
*/
#include <a_samp>
#include <a_mysql>

/*MANAGER 100 */
#define INIT		100
#define SQL			101

/*init 200 */
#define GAMEMODE    200
#define SERVER      201
#define MYSQL      	202
#define THREAD     	203

/*query 300 */
#define CHECK       300
#define REGIST      301
#define SAVE        302

/*Dialog 400 */
#define DL_LOGIN       400
#define DL_REGIST      401

main(){}

/* variable */

enum USER_MODEL{
 	ID,
	NAME[MAX_PLAYER_NAME],
	PASS[24],
	ADMIN,
	MONEY,
	KILLS,
	DEATHS,
	SKIN,
	Float:POS_X,
	Float:POS_Y,
	Float:POS_Z,
	Float:ANGLE,
 	Float:HP,
 	Float:AM
}
new USER[MAX_PLAYERS][USER_MODEL];

static mysql;
/*------------------------------------------------*/

public OnGameModeExit(){return 1;}
public OnGameModeInit(){
	manager(INIT, GAMEMODE);
	manager(INIT, SERVER);
	manager(INIT, MYSQL);
	manager(INIT, THREAD);
	return 1;
}

public OnPlayerRequestClass(playerid, classid){
	join(playerid, manager(SQL, CHECK, playerid));
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
//    if(!response && dialogid == DL_LOGIN || DL_REGIST) return Kick(playerid);
    
	switch(dialogid){
		case DL_LOGIN  : checked(playerid, inputtext);
		case DL_REGIST : manager(SQL, REGIST, playerid, inputtext);
	}
	return 1;
}
stock checked(playerid, password[]){
	if(strcmp(password, USER[playerid][PASS])) return join(playerid, 1), SendClientMessage(playerid,-1,"login fail");
	SendClientMessage(playerid,-1,"login success");
	return 1;
}

stock join(playerid, type){
	switch(playerid, type){
	    case 0 : ShowPlayerDialog(playerid, DL_REGIST, DIALOG_STYLE_PASSWORD, "manager", "Regist plz", "join", "quit");
	    case 1 : ShowPlayerDialog(playerid, DL_LOGIN, DIALOG_STYLE_PASSWORD, "manager", "Login plz", "join", "quit");
	}
	return 1;
}

stock manager(model, type, playerid = -1, text[] = ""){
	new result;
	switch(model){
	    case INIT :{
			switch(type){
				case GAMEMODE : mode();
				case SERVER   : server();
				case MYSQL    : dbcon();
				case THREAD   : thread();
			}
	    }
	    case SQL : {
			switch(type){
				case CHECK	: result = check(playerid);
				case REGIST	: regist(playerid,text);
				case SAVE	: save(playerid);
			}
	    }
	}

	return result;
}

/*SQL*/
forward check(playerid);
public check(playerid){
	new query[128], result;
	GetPlayerName(playerid, USER[playerid][NAME], MAX_PLAYER_NAME);
	mysql_format(mysql, query, sizeof(query), "SELECT PASS FROM `userlog_info` WHERE `NAME` = '%s' LIMIT 1", USER[playerid][NAME]);
	mysql_query(mysql, query);
	
	cache_get_field_content(0, "PASS", USER[playerid][PASS], mysql, 24);

	result = cache_num_rows();
	return result;
}

forward regist(playerid, pass[]);
public regist(playerid, pass[]){

	format(USER[playerid][PASS],24, "%s",pass);
	
	new query[256];
	GetPlayerName(playerid, USER[playerid][NAME], MAX_PLAYER_NAME);
	mysql_format(mysql, query, sizeof(query), "INSERT INTO `userlog_info` (`NAME`,`PASS`,`ADMIN`,`MONEY`,`KILLS`,`DEATHS`,`SKIN`,`POS_X`,`POS_Y`,`POS_Z`,`ANGLE`,`HP`,`AM`) VALUES ('%s','%s',%d,%d,%d,%d,%d,%f,%f,%f,%f,%f,%f)",
	USER[playerid][NAME],
	USER[playerid][PASS],
	USER[playerid][ADMIN] = 0,
	USER[playerid][MONEY] = 0,
	USER[playerid][KILLS] = 0,
	USER[playerid][DEATHS] = 0,
	USER[playerid][SKIN] = 0,
	USER[playerid][POS_X] = 0.0,
	USER[playerid][POS_Y] = 0.0,
	USER[playerid][POS_Z] = 0.0,
	USER[playerid][ANGLE] = 0.0,
	USER[playerid][HP] = 100.0,
	USER[playerid][AM] = 100.0
	);

	printf("%f",USER[playerid][HP]);
	
	mysql_query(mysql, query);
	SendClientMessage(playerid,-1,"regist success");
}

forward save(playerid);
public save(playerid){

}

/*INIT*/
stock thread(){}
stock server(){}
stock mode(){AddPlayerClass(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);}
stock dbcon(){
	new db_key[4][128] = {"hostname", "username", "database", "password"};
	new db_value[4][128];

	new File:cfg=fopen("database.cfg", io_read);
	new temp[64], tick =0;

	while(fread(cfg, temp)){
        if(strcmp(temp, db_key[tick], true, 1)==0){
			while(strfind(temp, "=") != -1){
			    new pos = strfind(temp, "=");
				strdel(temp, 0, pos+1);
				new len = strlen(temp);
				if(tick != 3)strdel(temp, len-2, len);
				db_value[tick] = temp;
				break;
			}
		}
        tick++;
    }
	mysql = mysql_connect(db_value[0], db_value[1], db_value[2], db_value[3]);
	mysql_set_charset("euckr");
	if(mysql_errno(mysql)){
		print("db error");
	}else{
		print("db connection success.");
	}
}
