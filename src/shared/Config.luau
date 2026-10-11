--!strict
-- Zentrale Spieleinstellungen. Werte hier anpassen statt im Code verteilen.

local Config = {
	GameName = "Zombie Defense Tycoon",
	Version = "0.2.0",

	StartMoney = 100,

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
		ClockTime = 0, -- 0 = Mitternacht
		Brightness = 2,
		Ambient = Color3.fromRGB(45, 50, 75),
		OutdoorAmbient = Color3.fromRGB(95, 105, 145),
		ExposureCompensation = 0.25,
		MoonSize = 18,
		StarCount = 4000,
	},
}

return Config
