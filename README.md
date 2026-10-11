# Zombie Defense Tycoon

Roblox-Spiel, gebaut mit VS Code, Rojo und GitHub.

## Ablauf
1. In VS Code: **Pull** (neueste Änderungen holen)
2. Rojo starten: `Ctrl+Shift+P` → „Rojo: Open menu" → `default.project.json` starten
3. Roblox Studio: Plugins → Rojo → **Connect**
4. **Play** drücken und testen

## Ordnerstruktur
| Ordner | Landet in Roblox in |
|---|---|
| `src/server/` | ServerScriptService/Server |
| `src/client/` | StarterPlayer/StarterPlayerScripts/Client |
| `src/shared/` | ReplicatedStorage/Shared |

Dateiendungen: `.server.luau` = Script, `.client.luau` = LocalScript, `.luau` = ModuleScript.

## Welt
Die Welt (Terrain, Wald, Nacht-Beleuchtung, Camp) wird beim **Serverstart** von `src/server/World/` erzeugt – sie ist also erst nach **Play** zu sehen. Einstellungen (Hügelhöhe, Baumanzahl, Helligkeit …) stehen in `src/shared/Config.luau` unter `World` und `Lighting`.

## HUD
Wird vom Client (`src/client/Hud.client.luau`, Bausteine in `src/client/UI/`) aufgebaut:
- **Health** unten in der Mitte, **Money** oben rechts (Attribut `Money` am Player, nur der Server ändert es – `src/server/Economy.luau`)
- **Hotbar** über der Lebensanzeige: Tasten 1–6 oder Klick rüstet aus
- **Inventory** (Taste G): Waffe anklicken = in freien Slot, ziehen = auf bestimmten Slot, Slot aus der Hotbar ziehen = entfernen
- **Shop** (P) und **Build** (B): Fenster, Inhalte folgen in späteren Etappen (`Panels.getBody("Shop")`)

Testhilfen in `Config.Debug`: 3 Platzhalter-Waffen und regelmäßiges Testgeld – vor Veröffentlichung abschalten.
