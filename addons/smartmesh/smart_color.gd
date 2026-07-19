@tool
class_name SmartColor
extends Resource

# ================================
#   Farben
# ------------

# Farben Gruppen
enum ColorGroup {
	GRAU_WEISS = 0,
	ROT_ORANGE = 1,
	WALD_KAELTER = 2,
	PFLANZEN_WARM = 3,
	BLAU_WASSER = 4,
	GELB_HAUT = 5,
	HOLZ_ERDE = 6,
	LILA_MAGIE = 7
}

const BASE_COLOR: Dictionary = {
	ColorGroup.GRAU_WEISS: [
		Color8(255,255,255), Color8(245,245,245), Color8(228,228,228), Color8(206,206,206), Color8(177,177,177),
		Color8(142,142,142), Color8(102,102,102), Color8(62,62,62),  Color8(31,31,31),  Color8(0,0,0)
	],
	ColorGroup.ROT_ORANGE: [
		Color8(255,0,0), Color8(255,198,76),  Color8(253,160,0),   Color8(240,121,0),   Color8(198,86,0),
		Color8(251,180,161), Color8(220,90,58),   Color8(171,58,29),   Color8(126,26,9),   Color8(70,10,3) # Ergänzt (Dunkelrot)
	],
	ColorGroup.WALD_KAELTER: [
		Color8(0,255,0),     Color8(40,220,60),   Color8(30,180,50),   Color8(20,140,40),  Color8(10,100,25), # Ergänzt (Dunkelgrün)
		Color8(120,254,122), Color8(53,231,29),  Color8(26,151,9),   Color8(11,76,2), Color8(20,45,5)
	],
	ColorGroup.PFLANZEN_WARM: [
		Color8(211,233,166), Color8(156,188,98),  Color8(102,145,50),  Color8(54,91,19),   Color8(35,65,10), # Ergänzt
		Color8(196,217,255), Color8(151,176,186), Color8(101,120,127), Color8(55,66,71),   Color8(30,38,41)  # Ergänzt
	],
	ColorGroup.BLAU_WASSER: [
		Color8(0,0,255),     Color8(193,234,255), Color8(142,198,226), Color8(75,147,184), Color8(24,86,118),
		Color8(120,180,254), Color8(44,138,251),  Color8(10,97,203),   Color8(3,50,106),   Color8(1,25,55)   # Ergänzt
	],
	ColorGroup.GELB_HAUT: [
		Color8(255,255,0),   Color8(249,243,166), Color8(248,227,31),  Color8(223,183,10), Color8(175,144,0),
		Color8(248,213,201), Color8(255,217,193), Color8(241,188,169), Color8(217,161,123), Color8(190,145,108)
	],
	ColorGroup.HOLZ_ERDE: [
		Color8(217,185,157), Color8(189,151,117), Color8(146,104,66), Color8(123,91,65), Color8(101,69,29),
		Color8(98,62,43),    Color8(67,40,26),    Color8(37,22,10),   Color8(25,14,5),    Color8(12,6,2) # Ergänzt (Tiefbraun)
	],
	ColorGroup.LILA_MAGIE: [
		Color8(255,0,255),   Color8(246,218,248), Color8(239,168,245), Color8(229,84,243), Color8(173,7,189),
		Color8(211,175,247), Color8(164,101,226), Color8(125,58,191),  Color8(72,11,131),  Color8(40,3,75)    # Ergänzt
	]
}

## Gibt die Farbe für die angegeben Farbnummer zurück
static func get_color_by_id(farbnummer: int) -> Color:
	# Sicherstellen, dass die ID im Bereich 0-79 liegt
	farbnummer = clamp(farbnummer, 0, 79)
	
	# ID in Matrix-Koordinaten zerlegen
	var theme_idx = farbnummer % 8
	var shade_idx = int(farbnummer / 8)
	
	# Farbe aus deiner FIXED_PALETTE holen
	return BASE_COLOR[theme_idx][shade_idx]


## Liefert den Index einer Farbe nach Gruppe und Farbwert zurück
static func get_color_index(color_group:int, color_number:int) -> int:
	return (color_number * 8) + color_group
	
	
## Farben Arrays [0-71]
#static var BASE_COLORS:PackedColorArray = [
	#Color8(255,255,255) #9
	#, Color8(245,245,245) #1,1
	#, Color8(228,228,228) #2,1
	#, Color8(206,206,206) #3,1
	#, Color8(177,177,177) #4,1
	#, Color8(142,142,142) #5,1
	#, Color8(102,102,102) #6,1
	#, Color8(62,62,62) #7,1
	#, Color8(31,31,31) #8,1
	#, Color8(0,0,0) #9,1
	#, Color8(255,0,0) #9,2	
	#, Color8(251,180,161) #1,2
	#, Color8(220,90,58) #2,2
	#, Color8(171,58,29) #3,2
	#, Color8(126,26,9) #4,2
	#, Color8(255,198,76) #1,3
	#, Color8(253,160,0) #2,3
	#, Color8(240,121,0) #3,3
	#, Color8(198,86,0) #4,3
	#, Color8(0,255,0) #9,3
	#, Color8(211,233,166) #5,2
	#, Color8(156,188,98) #6,2
	#, Color8(102,145,50) #7,2
	#, Color8(54,91,19) #8,2
	#, Color8(120,254,122) #5,3
	#, Color8(53,231,29) #6,3
	#, Color8(26,151,9) #7,3
	#, Color8(11,76,2) #8,3
	#, Color8(0,0,255) #9,4
	#, Color8(193,234,255) #1,6
	#, Color8(142,198,226) #2,6
	#, Color8(75,147,184) #3,6
	#, Color8(24,86,118) #4,6
	#, Color8(120,180,254) #1,7
	#, Color8(44,138,251) #2,7
	#, Color8(10,97,203) #3,7
	#, Color8(3,50,106) #4,7
	#, Color8(255,255,0) #9,5
	#, Color8(249,243,166) #5,6
	#, Color8(248,227,31) #6,6
	#, Color8(223,183,10) #7,6
	#, Color8(175,144,0) #8,6
	#, Color8(255,0,255) #9,6
	#, Color8(246,218,248) #1,4
	#, Color8(239,168,245) #2,4
	#, Color8(229,84,243) #3,4
	#, Color8(173,7,189) #4,4
	#, Color8(211,175,247) #1,5
	#, Color8(164,101,226) #2,5
	#, Color8(125,58,191) #3,5
	#, Color8(72,11,131) #4,5
	#, Color8(0,255,255) #9,7
	#, Color8(196,217,255) #1,8
	#, Color8(151,176,186) #2,8
	#, Color8(101,120,127) #3,8
	#, Color8(55,66,71) #4,8
	#, Color8(248,213,201) #5,7
	#, Color8(241,188,169) #6,7
	#, Color8(217,161,123) #7,7
	#, Color8(190,145,108) #8,7
	#, Color8(255,217,193) #5,8
	#, Color8(247,191,177) #6,8
	#, Color8(214,162,163) #7,8
	#, Color8(140,102,125) #8,8
	#, Color8(217,185,157) #5,4
	#, Color8(189,151,117) #6,4
	#, Color8(146,104,66) #7,4
	#, Color8(101,69,29) #8,4
	#, Color8(123,91,65) #5,5
	#, Color8(98,62,43) #6,5
	#, Color8(67,40,26) #7,5
	#, Color8(37,22,10) #8,5
#]
	
