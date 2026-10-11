# Hinweise für Claude (alle Chats/Etappen)

- Sprache mit dem User: Deutsch. Code-Kommentare: Deutsch.
- Sprache: Luau mit `--!strict`. Rojo-Projekt, Konfiguration in `default.project.json`.
- Der User pullt nur – Claude schreibt den Code und pusht direkt auf `main`.
- Spielwerte (Preise, Wellen, Schaden …) gehören in `src/shared/Config.luau`.
- Server ist die Autorität (Geld, Käufe, Zombie-Schaden); Client nur für UI/Effekte, Kommunikation über RemoteEvents.
- Projektübersicht/Status liegt im claude.ai-Projekt unter `claude/00-Projekt-Uebersicht.md` – am Ende einer Etappe aktualisieren.
- Modelle/Parts, die in Studio gebaut werden, sind nicht im Repo – dann beim User nachfragen.
