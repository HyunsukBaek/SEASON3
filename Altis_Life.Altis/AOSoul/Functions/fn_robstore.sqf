#include "..\..\script_macros.hpp"
private["_robber","_shop","_kassa","_ui","_progress","_pgText","_cP","_rip","_pos"];
//_kassa = 1000; //The amount the shop has to rob, you could make this a parameter of the call (https://community.bistudio.com/wiki/addAction). Give it a try and post below ;)
params [
    ["_shop",objNull,[objNull]],
    ["_robber",objNull,[objNull]],
    ["_action","", [""]]
];

[] spawn life_fnc_hudUpdate;

if(side _robber != civilian) exitWith {hint "You can not rob this Gas Station!"};
if(_robber distance _shop > 5) exitWith {hint "You need to be within 5m of the cashier to rob him!"};

if !(_kassa) then {_kassa = 1000;};
if (_rip) exitWith {hint "이미 주유소 털리고 있어요!"};
if (vehicle player != _robber) exitWith {hint "차에서 내리세요!"};

if !(alive _robber) exitWith {};
if (currentWeapon _robber == "") exitWith {hint "하하 내가 호군지아냐? 무기도 없으면서 어쩌시려고?"};
if (_kassa == 0) exitWith {hint "이미 털려서 돈이 없어요.."};

_rip = true;
_kassa = 120000 + round(random 60000);
_shop removeAction _action;
_shop switchMove "AmovPercMstpSsurWnonDnon";

_chance = random(100);
if(_chance >= 1) then {[1,format["경보! - 주유소: %1 에 강도 발생!", _shop]] remoteExec ["life_fnc_broadcast",west];};
if(_chance >= 1) then {[1,format["경보! - 주유소: %1 에 강도 발생!", _shop]] remoteExec ["life_fnc_broadcast",civilian];};

_cops = (west countSide playableUnits);
if(_cops < 0) exitWith {[_vault,-1] remoteExec ["disableSerialization;",2]; hint "There isnt enough Police to rob Gas Station!";};
disableSerialization;
5 cutRsc ["life_progress","PLAIN"];
_ui = uiNameSpace getVariable "life_progress";
_progress = _ui displayCtrl 38201;
_pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format["Robbery in Progress, stay close (10m) (1%1)...","%"];
_progress progressSetPosition 0.01;
_cP = 0.0001;

if(_rip) then
{
    while {true}do
    {
        sleep 3;
        _cP = _cP + 0.015;
        _progress progressSetPosition _cP;
        _pgText ctrlSetText format["주유소 강도 진행중.., 10m 이내 유지하세요. (%1%2)...",round(_cP * 100),"%"];
        _Pos = position player; // by ehno: get player pos
        _marker = createMarker ["Marker200", _Pos];//by ehno: Place a Maker on the map
        "Marker200" setMarkerColor "ColorRed";
        "Marker200" setMarkerText "!ATTENTION! robbery gas station!";
        "Marker200" setMarkerType "mil_warning";
        if(_cP >= 1) exitWith {};
        if(_robber distance _shop > 10.5) exitWith {};
        if!(alive _robber) exitWith {};
    };
    if!(alive _robber) exitWith {_rip = false;};
    if(_robber distance _shop > 10.5) exitWith {deleteMarker "Marker200"; _shop switchMove ""; hint "10m이내에서 강도가 머물러야합니다. 주유소 금고가 닫혔습니다."; 5 cutText ["","PLAIN"]; _rip = false;};
    5 cutText ["","PLAIN"];

    titleText[format["You have stolen $%1, now get away before the cops arrive!",[_kassa] call life_fnc_numberText],"PLAIN"];
    deleteMarker "Marker200"; // by ehno delete maker
    life_cash = life_cash + _kassa;

    _rip = false;
    life_use_atm = false;
    sleep (30 + random(180));
    life_use_atm = true;
    if!(alive _robber) exitWith {};
    [getPlayerUID _robber,_robber getVariable ["realname",name _robber],"26"] remoteExecCall ["life_fnc_wantedAdd",RSERV];
    [5] call SOCK_fnc_updatePartial; // DB 업데이트
};
[] spawn life_fnc_hudUpdate;
sleep 300;
_action = _shop addAction["Rob the Gas Station",life_fnc_robstore];
_shop switchMove "AmovPercMstpSnonWnonDnon";