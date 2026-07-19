@tool
extends GridContainer

# Signal, das gesendet wird, wenn der User eine Farbe wählt
signal color_selected(theme_idx: int, shade_idx: int, color: Color)

# Wir nutzen dieselbe Struktur wie zuvor
enum PaletteTheme {
	GRAU_WEISS = 0,
	ROT_ORANGE = 1,
	WALD_KAELTER = 2,
	PFLANZEN_WARM = 3,
	BLAU_WASSER = 4,
	GELB_HAUT = 5,
	HOLZ_ERDE = 6,
	LILA_MAGIE = 7
}

# (Hier die gekürzte PALETTE aus der vorherigen Antwort einfügen)
const FIXED_PALETTE: Dictionary = {
	PaletteTheme.GRAU_WEISS: [
		Color8(255,255,255), Color8(245,245,245), Color8(228,228,228), Color8(206,206,206), Color8(177,177,177),
		Color8(142,142,142), Color8(102,102,102), Color8(62,62,62),  Color8(31,31,31),  Color8(0,0,0)
	],
	PaletteTheme.ROT_ORANGE: [
		Color8(255,0,0), Color8(255,198,76),  Color8(253,160,0),   Color8(240,121,0),   Color8(198,86,0),
		Color8(251,180,161), Color8(220,90,58),   Color8(171,58,29),   Color8(126,26,9),   Color8(70,10,3) # Ergänzt (Dunkelrot)
	],
	PaletteTheme.WALD_KAELTER: [
		Color8(0,255,0),     Color8(40,220,60),   Color8(30,180,50),   Color8(20,140,40),  Color8(10,100,25), # Ergänzt (Dunkelgrün)
		Color8(120,254,122), Color8(53,231,29),  Color8(26,151,9),   Color8(11,76,2), Color8(20,45,5)
	],
	PaletteTheme.PFLANZEN_WARM: [
		Color8(211,233,166), Color8(156,188,98),  Color8(102,145,50),  Color8(54,91,19),   Color8(35,65,10), # Ergänzt
		Color8(196,217,255), Color8(151,176,186), Color8(101,120,127), Color8(55,66,71),   Color8(30,38,41)  # Ergänzt
	],
	PaletteTheme.BLAU_WASSER: [
		Color8(0,0,255),     Color8(193,234,255), Color8(142,198,226), Color8(75,147,184), Color8(24,86,118),
		Color8(120,180,254), Color8(44,138,251),  Color8(10,97,203),   Color8(3,50,106),   Color8(1,25,55)   # Ergänzt
	],
	PaletteTheme.GELB_HAUT: [
		Color8(255,255,0),   Color8(249,243,166), Color8(248,227,31),  Color8(223,183,10), Color8(175,144,0),
		Color8(248,213,201), Color8(255,217,193), Color8(241,188,169), Color8(217,161,123), Color8(190,145,108)
	],
	PaletteTheme.HOLZ_ERDE: [
		Color8(217,185,157), Color8(189,151,117), Color8(146,104,66), Color8(123,91,65), Color8(101,69,29),
		Color8(98,62,43),    Color8(67,40,26),    Color8(37,22,10),   Color8(25,14,5),    Color8(12,6,2) # Ergänzt (Tiefbraun)
	],
	PaletteTheme.LILA_MAGIE: [
		Color8(255,0,255),   Color8(246,218,248), Color8(239,168,245), Color8(229,84,243), Color8(173,7,189),
		Color8(211,175,247), Color8(164,101,226), Color8(125,58,191),  Color8(72,11,131),  Color8(40,3,75)    # Ergänzt
	]
}

func _ready() -> void:
	# Spaltenanzahl erzwingen
	columns = 8
	_build_palette_ui()

func _build_palette_ui() -> void:
	for child in get_children():
		child.queue_free()
		
	# Wir erzwingen das 8-Spalten-Layout
	columns = 8
	
	# Zeile für Zeile (0 bis 9)
	for shade in range(10):
		# Spalte für Spalte (0 bis 7)
		for theme in range(8):
			var current_color: Color = FIXED_PALETTE[theme][shade]
			
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(36, 36)
			
			var style = StyleBoxFlat.new()
			style.bg_color = current_color
			style.set_corner_radius_all(4)
			
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_stylebox_override("hover", style.duplicate())
			btn.add_theme_stylebox_override("pressed", style)
			
			# Tooltip hinzufügen, damit man sieht, was man auswählt!
			btn.tooltip_text = "Thema: " + str(theme) + " | Stufe: " + str(shade)
			
			btn.set_meta("theme_idx", theme)
			btn.set_meta("shade_idx", shade)
			btn.set_meta("color", current_color)
			
			btn.pressed.connect(_on_color_button_pressed.bind(btn))
			add_child(btn)

func _on_color_button_pressed(button: Button) -> void:
	# Daten aus den Metadaten des geklickten Buttons auslesen
	var t_idx = button.get_meta("theme_idx")
	var s_idx = button.get_meta("shade_idx")
	var col = button.get_meta("color")
	
	# Signal an das übergeordnete Lego-Bausystem senden
	color_selected.emit(t_idx, s_idx, col)
