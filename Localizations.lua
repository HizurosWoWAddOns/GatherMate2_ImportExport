
local L, addon, ns = {}, ...;

ns.L = setmetatable(L,{__index=function(t,k)
	local v = tostring(k);
	rawset(t,k,v);
	return v;
end});

-- Do you want to help localize this addon?
-- https://www.curseforge.com/wow/addons/@cf-project-name@/localization

--@do-not-package@
L["AddOnLoaded"] = "AddOn loaded..."
L["ExportByExpansion"] = "Export by expansion"
L["ExportByZone"] = "Export by zone"
L["InsertString"] = "Insert the export string here with Ctrl+V"
L["ExportString"] = "Export string"
L["ExportStringCreate"] = "Create export string"
L["ExportStringCopy"] = "Copy export string with Ctrl+C";
L["InputDialog"] = "Open the input dialog"
L["InputDialogDesc"] = "Click on the button and copy the export string into the input field."
L["InsertSuccesfull"] = "Successfully added %d nodes to GatherMate2."
--@end-do-not-package@

--@localization(locale="enUS", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@

if LOCALE_deDE then
--@do-not-package@
	L["AddOnLoaded"] = "AddOn geladen..."
	L["ExportByExpansion"] = "Export nach Erweiterung"
	L["ExportByZone"] = "Export nach Gebiet"
	L["InsertString"] = "Füge die Export-Zeichenkette hier ein mit Strg+V"
	L["ExportString"] = "Export-Zeichenkette"
	L["ExportStringCreate"] = "Erzeuge Export-Zeichenkette"
	L["ExportStringCopy"] = "Kopiere die Export-Zeichenkette mit Strg+C.";
	L["InputDialog"] = "Öffne den Eingabe-Dialog"
	L["InputDialogDesc"] = "Klick auf den Button und kopiere die Export-Zeichenkette in das Eingabefeld."
	L["InsertSuccesfull"] = "Erfolgreich %d Knoten GatherMate2 hinzugefügt."
--@end-do-not-package@
--@localization(locale="deDE", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end

if LOCALE_esES then
--@localization(locale="esES", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end

if LOCALE_esMX then
--@localization(locale="esMX", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end

if LOCALE_frFR then
--@localization(locale="frFR", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end

if LOCALE_itIT then
--@localization(locale="itIT", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end

if LOCALE_koKR then
--@localization(locale="koKR", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end

if LOCALE_ptBR or LOCALE_ptPT then
--@localization(locale="ptBR", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end

if LOCALE_ruRU then
--@localization(locale="ruRU", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end

if LOCALE_zhCN then
--@localization(locale="zhCN", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end

if LOCALE_zhTW then
--@localization(locale="zhTW", format="lua_additive_table", handle-subnamespaces="none", handle-unlocalized="ignore")@
end
