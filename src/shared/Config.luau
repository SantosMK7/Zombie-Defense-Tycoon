--!strict
-- Zentrale Spieleinstellungen. Werte hier anpassen statt im Code verteilen.

local Config = {
	GameName = "Zombie Defense Tycoon",
	Version = "0.3.0",

	StartMoney = 100,

	-- HUD (Anzeige am Bildschirm)
	Hud = {
		HotbarSlots = 6, -- Anzahl Waffen-Slots in der Hotbar (max. 9, Tasten 1–9)
		Keys = {
			Inventory = Enum.KeyCode.G,
			Shop = Enum.KeyCode.P,
			Build = Enum.KeyCode.B,
		},
	},

	-- Nur zum Testen – vor der Veröffentlichung abschalten
	Debug = {
		GiveTestWeapons = true, -- 3 Platzhalter-Waffen (Pistol, Shotgun, Machete) ohne Funktion
		TestIncome = 10, -- Geld, das jeder Spieler regelmäßig bekommt (0 = aus)
		TestIncomeInterval = 3, -- alle X Sekunden
	},

	-- Welt (wird beim Serverstart per Skript erzeugt)
	World = {
		Seed = 1337, -- anderer Wert = andere Hügel/Baumverteilung

		-- Landschaft
		MapSize = 1024, -- Kantenlänge der Karte in Studs (Mitte = 0,0,0)
		FlatRadius = 70, -- flacher Bereich in der Mitte (hier kommt später die Basis hin)
		TransitionWidth = 70, -- weicher Übergang von flach zu hügelig
		HillHeight = 14, -- maximale Hügelhöhe
		HillScale = 150, -- Wellenlänge der Hügel (größer = sanfter)
		EdgeRise = 26, -- Landschaft steigt zum Rand hin an (Wald wirkt dadurch höher)
		EdgeRiseStart = 300,
		GrassColor = Color3.fromRGB(58, 92, 44),
		GrassLength = 0.45, -- Grashalme: 0.1 = kurz … 1 = hoch (vorher Standard ~0.7)

		-- Wald
		ForestInnerRadius = 230, -- Wald beginnt hier ...
		ForestOuterRadius = 500, -- ... und geht bis hier
		ForestTreeCount = 700,
		ScatterTreeCount = 35, -- einzelne Bäume zwischen Lichtung und Wald
		ScatterInnerRadius = 130,
		RockCount = 45,
		FireflyCount = 14,

		-- Camp in der Mitte
		LanternCount = 6,
		LanternRadius = 30,
	},

	-- Nacht-Beleuchtung (hell genug, um etwas zu sehen)
	Lighting = {
		-- Mondhöhe: 0 = Mitternacht (Mond ganz oben). Je näher an 5, desto tiefer steht der Mond.
		ClockTime = 3.6,
		GeographicLatitude = 55, -- höher = Mond wandert flacher über den Himmel
		Brightness = 2,
		Ambient = Color3.fromRGB(55, 45, 65),
		OutdoorAmbient = Color3.fromRGB(105, 95, 130),
		ExposureCompensation = 0,
		MoonSize = 26,
		StarCount = 4000,

		-- Rotstich für Zombie-Apokalypse-Stimmung
		AtmosphereColor = Color3.fromRGB(125, 60, 70), -- Dunst/Horizont
		AtmosphereDecay = Color3.fromRGB(70, 22, 32),
		TintColor = Color3.fromRGB(255, 228, 228),
	},
}

return Config
