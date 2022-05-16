# GatherMate2 Import/Export (WoW AddOn)
![Build](https://github.com/hizuro/gathermate2_importexport/actions/workflows/bigwigsmods-packager.yml/badge.svg)
![Tag](https://img.shields.io/github/v/tag/hizuro/gathermate2_importexport?style=flat-square)
![Downloads](https://img.shields.io/github/downloads/hizuro/gathermate2_importexport/total?style=flat-square)
![Downloads](https://img.shields.io/github/downloads/hizuro/gathermate2_importexport/latest/total?style=flat-square)
&nbsp; &nbsp; &nbsp; &nbsp;
[![Patreon](https://img.shields.io/badge/&zwj;-Patreon-gray?logo=patreon&color=red&style=flat-square)](https://www.patreon.com/bePatron?u=12558524)
[![Paypal](https://img.shields.io/badge/&zwj;-Paypal-gray?logo=paypal&color=blue&style=flat-square)](https://paypal.me/hizuro)
![Sponsors](https://img.shields.io/github/sponsors/hizuro?logo=github&style=flat-square)

## Description
This addon adding "Import/Export" section to GatherMate2.

## Features

### Export
Choose by expansion or zone and node type what you export/share with other user.\
*Little annotation: It was planned to add an "Export all" option but it was to heavy for wow. Client freeze was too long. ;-)*

### Import
Easelly import GatherMate2 Data from other user export strings.\
Click on button "Open the input dialog" and fill the export string into the input field amd click on "Okay".

## For other devs
This addon using AceSerializer from Ace3, LibDeflate:CompressDeflate and LibBase64 to generate the export string.\
The table design is:
```lua
{
    ["<nodeType>"] = {
        ["<uiMapID>"] = {
            ["<coords>"] = "<GM2 internal node index>",
            ...
        },
        ...
    },
    ...
}
-- nodeType is part of _G["GatherMate2"..nodeType.."DB"] (global SavedVariable from GatherMate2)
-- coords and "GM2 internal node index" is from GatherMate2.
```

## My other projects
* [On Curseforge](https://www.curseforge.com/members/hizuro_de/projects)
* [On Github](https://github.com/hizuro?tab=repositories)

## Disclaimer
> World of Warcraft© and Blizzard Entertainment© are all trademarks or registered trademarks of Blizzard Entertainment in the United States and/or other countries. These terms and all related materials, logos, and images are copyright © Blizzard Entertainment. The author of this addon is in no way associated with or endorsed by Blizzard Entertainment ©
