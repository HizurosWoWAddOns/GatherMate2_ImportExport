
local addon, ns = ...;
local L = ns.L;

local gm2L = LibStub("AceLocale-3.0"):GetLocale("GatherMate2",false)
local AceSerializer = LibStub("AceSerializer-3.0");
local LibBase64 = LibStub("LibBase64-1.0");
local LibDeflate = LibStub("LibDeflate");
local maps = {};
local nodeTypesByExpansion = {}
local typeSelected = {};
local exportString = {key=false,value=""}

local types = {
	-- {_G["GatherMate2"..<nodeType>.."DB"], <GM2 LocalizationKey>, <GM2 LocalizationKeyAlt> }
	{"Herb",       "Herb Gathering", "Herbalism"},
	{"Mine",       "Mining"},
	{"Fish",       "Fishing"},
	{"Gas",        "Extract Gas",    "Gas Clouds"},
	{"Treasure",   "Treasure"},
	{"Archaeology","Archaeology"},
--	{"Logging",    "Logging",        "Logging"},
};

local expansionGroups = {
	packed = {
		-- [<expansionIndex+1>] = "<list of uiMapIDs[,]>"
		"1,7,10,12,13,14,15,17,18,21,22,23,25,26,27,32,36,37,42,47,48,49,50,51,52,56,57,62,63,64,65,66,69,70,71,76,77,78,80,81,83,84,85,87,88,89,90,110,199,210,217,224,425,460,461,462,463,465,469,985,986,1208,1209,1244,1245,1246,1247,1248,1249,1250,1251,1252,1253,1254,1255,1256,1257,1258,1259,1260,1261,1262,1263,1264,1265,1266,1267,1268,1269,1270,1271,1272,1273,1274,1275,1276,1277,1305,1306,1307,1308,1309,1310,1311,1312,1313,1314,1315,1316,1317,1318,1319,1320,1321,1322,1323,1324,1325,1326,1327,1328,1329,1330,1331,1339,1527,1577",
		"95,94,97,100,101,102,103,104,105,106,107,108,109,111,122,467,468,987,1467",
		"113,114,115,116,117,118,119,120,121,123,127,170,988,1384,1396,1397,1398,1399,1400,1401,1402,1403,1404,1405,1406",
		"174,194,198,201,202,203,204,205,207,241,244,245,249,276,948,1010",
		"371,376,379,388,390,418,422,424,433,504,507,554,989,1530",
		"525,534,535,539,542,543,550,572,588,990",
		"619,630,634,641,646,650,680,739,790,830,882,885,905,993,994,1187,1188,1189,1190,1191,1192",
		"862,863,864,875,876,895,896,942,991,992,1011,1014,1039,1041,1161,1165,1169,1193,1194,1195,1196,1197,1198,1355,1462,1504",
		"1525,1533,1536,1543,1550,1565,1569,1645,1647,1740,1741,1742",
	}
}

do
	local addon_short = "GM2IE"; --L[addon.."_Shortcut"];
	local colors = {"0099ff","00ff00","ff6060","44ffff","ffff00","ff8800","ff44ff","ffffff"};
	ns.debugMode = "@project-version@" == "@".."project-version".."@";
	local function colorize(...)
		local t,c,a1 = {tostringall(...)},1,...;
		if type(a1)=="boolean" then tremove(t,1); end
		if a1~=false then
			tinsert(t,1,"|cff0099ff"..((a1==true and addon_short) or (a1=="||" and "||") or addon).."|r"..(a1~="||" and HEADER_COLON or ""));
			c=2;
		end
		for i=c, #t do
			if not t[i]:find("\124c") then
				t[i],c = "|cff"..colors[c]..t[i].."|r", c<#colors and c+1 or 1;
			end
		end
		return unpack(t);
	end
	function ns.print(...)
		print(colorize(...));
	end
	function ns.debug(...)
		ConsolePrint(date("|cff999999%X|r"),colorize(...));
	end
	function ns.debugPrint(...)
		if not ns.debugMode then return end
		print(colorize("<debug>",...))
	end
	if ns.debugMode then
		_G[addon.."_GetNamespace"] = function()
			return ns;
		end
	end
end

StaticPopupDialogs["GM2IE_SHOW_EXPORTSTRING"] = {
	text = L["ExportStringCopy"],
	button1 = OKAY,
	hasEditBox = 1,
	editBoxWidth = 360,
	hasAutoComplete = false,
	OnAccept = function(self) end,
	EditBoxOnEnterPressed = function(self) end,
	EditBoxOnEscapePressed = function(self, data)
		self :GetParent() :Hide();
	end,
	OnShow = function(self)
		self.editBox :SetFocus();
		ns.debugPrint("exportString",exportString.value :len());
		self.editBox :SetText(exportString.value);
		self.editBox :HighlightText();
	end,
	OnHide = function(self)
		self.editBox :SetText("");
		exportString.key = false;
		exportString.value = "";
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

local function parseInsertedExportString(dialog)
	local str,decodedStr,uncompressedStr,data,success = dialog.editBox :GetText();
	dialog.editBox :SetText("");

	if str :len()>0 then
		decodedStr = LibBase64.Decode(str)
		str = nil;
	end
	if decodedStr then
		uncompressedStr = LibDeflate:DecompressDeflate(decodedStr);
		decodedStr = nil;
	end
	if uncompressedStr then
		success, data = AceSerializer:Deserialize(uncompressedStr); -- using pcall
		uncompressedStr = nil;
	end
	if success and data then
		local num,db = 0;
		for nodeType, mapData in pairs(data)do
			db = _G["GatherMate2"..nodeType.."DB"];
			if db then
				for mapId, nodes in pairs(mapData)do
					if db[mapId]==nil then
						db[mapId] = {};
					end
					for coords,nodeIndex in pairs(nodes)do
						--if not db[mapId][coords] then
							db[mapId][coords] = nodeIndex;
							num = num + 1;
						--end
					end
				end
			end
		end
		ns.print(L["InsertSuccesfull"]:format(num));
	end
end

-- suppress editbox scripts to avoid massiv lags on input big export string
local suppressScripts = {
	-- from AutoCompleteEditBoxTemplate
	{"OnTabPressed","AutoCompleteEditBox_OnTabPressed"},
	{"OnChar","AutoCompleteEditBox_OnChar"},
	{"OnEditFocusLost","AutoCompleteEditBox_OnEditFocusLost"},
	{"OnArrowPressed","AutoCompleteEditBox_OnArrowPressed"},
	{"OnKeyDown","AutoCompleteEditBox_OnKeyDown"},
	{"OnKeyUp","AutoCompleteEditBox_OnKeyUp"},
	-- from StaticPopup1EditBox
	{"OnTextChanged","StaticPopup_EditBoxOnTextChanged"},
}

StaticPopupDialogs["GM2IE_SHOW_IMPORTSTRING"] = {
	text = L["InsertString"],
	button1 = OKAY,
	hasEditBox = 1,
	addHighlightedText = false,
	editBoxWidth = 360,
	hasAutoComplete = false,
	OnAccept = function(self)
		parseInsertedExportString(self);
	end,
	EditBoxOnEnterPressed = function(self)
		parseInsertedExportString(self :GetParent());
		self :GetParent() :Hide();
	end,
	EditBoxOnEscapePressed = function(self, data)
		self :GetParent() :Hide();
	end,
	OnShow = function(self)
		for _, scripts in ipairs(suppressScripts)do
			self.editBox :SetScript(scripts[1],nil);
		end
		self.editBox :SetText("");
	end,
	OnHide = function(self)
		self.editBox :SetText("");
		for _, scripts in ipairs(suppressScripts)do
			self.editBox :SetScript(scripts[1],_G[scripts[2]]);
		end
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

local function generateExportString(key,data)
	local dataStr,compressedStr,encodedStr = AceSerializer:Serialize(data);
	if dataStr then
		compressedStr = LibDeflate:CompressDeflate(dataStr);
		dataStr = nil;
	end
	if compressedStr then
		encodedStr = LibBase64.Encode(compressedStr);
		compressedStr = nil;
	end
	if encodedStr then
		exportString.key = key;
		exportString.value = encodedStr;
		StaticPopup_Show("GM2IE_SHOW_EXPORTSTRING");
	end
	wipe(data);
end

local function importString(info,value)
	if type(value)~="string" then
		return;
	end
	ns.debugPrint(value :len());
end

local function CopyMapNodes(tbl)
	local t,c = {},0;
	for coords, gm2NodeId in pairs(tbl)do
		if t[gm2NodeId]==nil then
			t[gm2NodeId] = {};
		end
		tinsert(t[gm2NodeId],coords);
		c=c+1;
	end
	return t, c;
end

local function GetMapName(mapId)
	local mapInfo = C_Map.GetMapInfo(mapId);
	if mapInfo and  mapInfo.name~=nil and mapInfo.name~="" then
		return mapInfo.name, mapInfo.mapType;
	end
	return false;
end

local options = {
	type = "group",
	name = L["Import/Export"],
	childGroups = "tab",
	args = {
		import = {
			type = "group", order = 1, inline = true,
			name = L["Import"],
			args = {
				inputDialog = {
					type = "execute", order = 1, width="double",
					name = L["InputDialog"],
					desc = L["InputDialogDesc"],
					func = function()
						StaticPopup_Show("GM2IE_SHOW_IMPORTSTRING");
					end
				},
			}
		},
		exportByExpansion = {
			type = "group", order = 2,
			name = L["ExportByExpansion"],
			childGroups = "tree",
			disabled = function(info)
				if info[#info]=="create" then
					return false; -- ignore create button
				end
				local exp = tonumber((info[#info-1]:gsub("^exp%-","")));
				if exp then
					if not (nodeTypesByExpansion[exp] and nodeTypesByExpansion[exp][info[#info]]) then
						return true;
					end
				end
				return false;
			end,
			func = function(info)
				local exp = tonumber((info[#info-1] :gsub("^exp%-","")));
				local data,hasData,db,key = {},false;
				if exp then
					for nodeType in pairs(nodeTypesByExpansion[exp]) do
						key = "GatherMate2"..nodeType.."DB";
						if typeSelected[nodeType] and _G[key] then
							if data[nodeType]==nil then
								data[nodeType] = {};
							end
							for mapId, nodes in pairs(_G[key]) do
								if expansionGroups[mapId]==exp then
									data[nodeType][mapId] = CopyTable(nodes);
									hasData = true;
								end
							end
						end
					end
				end
				if hasData then
					generateExportString(info[#info-1],data);
				end
			end,
			args = {
				-- filled by function
			}
		},
		exportByZone = {
			type = "group", order = 3,
			name = L["ExportByZone"],
			childGroups = "tree",
			disabled = function(info)
				if info[#info]=="create" then
					return false; -- ignore create button
				end
				local map = tonumber((info[#info-1]:gsub("^map%-","")));
				if map and info[#info]~="create" then
					local db = _G["GatherMate2"..info[#info].."DB"];
					if map and not (db and db[map]) then
						return true;
					end
				end
				return false;
			end,
			func = function(info)
				local map = tonumber((info[#info-1] :gsub("^map%-","")));
				local data,hasData,db,key = {},false;
				if map then
					for nodeType in pairs(typeSelected) do
						if nodeType then
							key = "GatherMate2"..nodeType.."DB";
							if _G[key] then
								for mapId, nodes in pairs(_G[key]) do
									if map == mapId then
										if data[nodeType]==nil then
											data[nodeType] = {};
										end
										data[nodeType][mapId] = CopyTable(nodes);
										hasData = true;
									end
								end
							end
						end
					end
				end
				if hasData then
					generateExportString(map,data);
				end
			end,
			args = {
				-- filled by function
			}
		},
	}
};

local optionExportTable = {
	type = "group", order = 0,
	name = "",--L["ExportAll"],
	args = {
		create = {
			type = "execute", order = 99, width = "full",
			name = L["ExportStringCreate"]
			-- "func" from group table
		},
	}
}

local optionNodeTypeToggle = {
	type = "toggle", order = 0,
	name = "",
	get = function(info)
		return typeSelected[info[#info]];
	end,
	set = function(info,value)
		typeSelected[info[#info]] = value;
	end,
	-- disabled function in group table
};

local optionExportHeaderTable = {
	type = "group", order = 0, disabled = true,
	name = "",
	args = {}
}

local frame = CreateFrame("Frame");

frame:SetScript("OnEvent",function(self,event,...)
	-- unpack expansionGroups
	local expansionIndex,maps;
	for i=1, #expansionGroups.packed do
		maps = {strsplit(",",expansionGroups.packed[i])};
		expansionIndex = i-1;
		for _,mapId in ipairs(maps)do
			mapId = tonumber(mapId);
			if mapId then
				expansionGroups[mapId] = expansionIndex;
			end
			for i=1, #types do
				if _G["GatherMate2"..types[i][1].."DB"] and _G["GatherMate2"..types[i][1].."DB"][mapId] then
					if nodeTypesByExpansion[expansionIndex]==nil then
						nodeTypesByExpansion[expansionIndex] = {};
					end
					nodeTypesByExpansion[expansionIndex][types[i][1]] = true;
				end
			end
		end
	end

	for i=1, #types do
		-- make a list of maps from all db tables;
		local db = _G["GatherMate2"..types[i][1].."DB"];
		for mapId, nodes in pairs(db) do
			maps[mapId] = GetMapName(mapId);
		end
		-- add node type toggle to exportAll
		optionExportTable.args[types[i][1]] = CopyTable(optionNodeTypeToggle);
		optionExportTable.args[types[i][1]].order = i;
		optionExportTable.args[types[i][1]].name = gm2L[types[i][3] or types[i][2]];
	end

	-- generate option table
	for i=0, 20 do
		if _G["EXPANSION_NAME"..i] then
			options.args.exportByExpansion.args["exp-"..i] = {};
			local tmpSection = Mixin(options.args.exportByExpansion.args["exp-"..i],optionExportTable);
			tmpSection.name = _G["EXPANSION_NAME"..i];
			tmpSection.order = 20-i;

			options.args.exportByZone.args["expHeader"..i] = CopyTable(optionExportHeaderTable);
			options.args.exportByZone.args["expHeader"..i].name = WrapTextInColorCode(_G["EXPANSION_NAME"..i],"ff00aaff");
			options.args.exportByZone.args["expHeader"..i].order = 1000 - (i*10);
		else
			break;
		end
	end

	for mapId in pairs(maps)do
		local mapName,mapType = GetMapName(mapId);
		if mapName and mapType<=3 then
			options.args.exportByZone.args["map-"..mapId] = {};
			local tmpSection = Mixin(options.args.exportByZone.args["map-"..mapId],optionExportTable);
			tmpSection.name = mapName;
			local exp = expansionGroups[mapId] or 99;
			tmpSection.order = 1000 - (exp*10) + 1;
		else
			maps[mapId] = nil;
		end
	end

	-- Register options table with GatherMate's Config
	local Config = GatherMate2:GetModule("Config");
	if Config then
		Config:RegisterModule(L["Import/Export"], options);
	end

	--ns.print(L["AddOnLoaded"]);
end);

frame:RegisterEvent("PLAYER_LOGIN");

--@do-not-package@
do
	-- 469 -- New Tinkertown - added with cata;
	local generatedZoneGroups = {}
	-- source: https://wow.gamepedia.com/UiMapID
	local expansionIds = { -- continents and zones
		[946] = false, -- cosmic
		[947] = false, -- Azeroth

		-- continents
		-- 0 - vanilla
		[12] = 0, -- Kalimdor
		[13] = 0, -- Eastern Kingdoms
		[1208] = 0, -- Eastern Kingdoms

		-- 1 outland
		[94] = 1, -- Eversong Woods
		[95] = 1, -- Ghostlands
		[97] = 1, -- Azuremyst Isle
		[101] = 1, -- Outland
		[103] = 1, -- The Exodar
		[106] = 1, -- Bloodmyst Isle
		[122] = 1, -- Isle of Quel'Danas
		[467] = 1, -- Sunstrider Isle

		-- 2 Northrend
		[113] = 2, -- Northrend

		-- 3 cata
		[198] = 3, -- Mount Hyjal
		[202] = 3, -- Gilneas City
		[203] = 3, -- Vashj'ir
		[204] = 3, -- Vashj'ir
		[241] = 3, -- Twilight Highlands
		[244] = 3, -- Tol Barad
		[245] = 3, -- Tol Barad Peninsula
		[249] = 3, -- Uldum
		[948] = 3, -- The Maelstrom (Cata)

		-- 4 mop
		[424] = 4, -- Pandaria

		-- 5 wod
		[572] = 5, -- Draenor

		-- 6 legion
		[619] = 6, -- Broken Isles (Legion)
		[905] = 6, -- Argus (Legion)

		-- 7 bfa
		[875] = 7, -- Zandalar (BfA)
		[876] = 7, -- Kul Tiras (BfA)
		[1355] = 7, -- Nazjatar (BfA)
		[1504] = 7, -- Nazjatar (BfA)

		-- 8 shadowlands
		[1550] = 8, -- The Shadowlands
		[1645] = 8, -- Torghast (Shadowlands)
	};
	local knownNames = {
		--
	}
	local function GetContinent(id)
		local mapInfo = C_Map.GetMapInfo(id);
		if not mapInfo or (mapInfo and mapInfo.mapType>3) then
			return; -- ignore mapTypes Dungeons, Micro and Orphan
		end
		if expansionIds[id] then
			return mapInfo;
		elseif mapInfo.mapType>2 and mapInfo.parentMapID then
			mapInfo = GetContinent(mapInfo.parentMapID);
		end
		return mapInfo;
	end
	local function genZoneGroups()
		ns.debugPrint("genZoneGroups","starting...")
		wipe(generatedZoneGroups);
		generatedZoneGroups.map2expansion = {}
		generatedZoneGroups.unknown = {}
		for i=0, 12 do
			generatedZoneGroups.map2expansion["exp"..i] = {};
		end
		local info
		for i=1, 3000 do
			info = GetContinent(i);
			if expansionIds[i]==false then
				-- ignore
			elseif type(expansionIds[i])=="number" then
				tinsert(generatedZoneGroups.map2expansion["exp"..expansionIds[i]],i);
			elseif info then
				if knownNames[info.name] then
					tinsert(generatedZoneGroups.map2expansion["exp"..knownNames[info.name]],i);
				elseif expansionIds[info.mapID] then
					tinsert(generatedZoneGroups.map2expansion["exp"..expansionIds[info.mapID]],i);
					knownNames[info.name] = expansionIds[info.mapID];
				else
					generatedZoneGroups.unknown[i] = {C_Map.GetMapInfo(i),info};
				end
			end
		end
		for i=0, 12 do
			if #generatedZoneGroups.map2expansion["exp"..i]>0 then
				generatedZoneGroups.map2expansion["exp"..i] = table.concat(generatedZoneGroups.map2expansion["exp"..i],",");
			else
				generatedZoneGroups.map2expansion["exp"..i] = nil;
			end
		end
		ns.debugPrint("genZoneGroups","finished.")
	end
end
--@end-do-not-package@
