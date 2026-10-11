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
