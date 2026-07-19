@tool
extends PanelContainer

# --- KONFIGURATION ---
@export_group("SVG Einstellungen (Druck)")
@export var mit_beschriftung: bool = true
@export var kachel_groesse_svg: float = 60.0
@export var abstand_svg: float = 15.0
@export_tool_button("Export Color SVG") var color_action = generate_svg_palette

@export_group("PNG Einstellungen (Blender)")
@export var kachel_groesse_png: int = 10 
@export_tool_button("Export Color PNG") var color_action_png = generate_png_texture

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

const FIXED_PALETTE: Dictionary = {
	PaletteTheme.GRAU_WEISS: [Color8(255,255,255), Color8(245,245,245), Color8(228,228,228), Color8(206,206,206), Color8(177,177,177), Color8(142,142,142), Color8(102,102,102), Color8(62,62,62),  Color8(31,31,31),  Color8(0,0,0)],
	PaletteTheme.ROT_ORANGE: [Color8(255,0,0), Color8(255,198,76),  Color8(253,160,0),   Color8(240,121,0),   Color8(198,86,0), Color8(251,180,161), Color8(220,90,58),   Color8(171,58,29),   Color8(126,26,9),   Color8(70,10,3)],
	PaletteTheme.WALD_KAELTER: [Color8(0,255,0),     Color8(40,220,60),   Color8(30,180,50),   Color8(20,140,40),  Color8(10,100,25), Color8(120,254,122), Color8(53,231,29),  Color8(26,151,9),   Color8(11,76,2), Color8(20,45,5)],
	PaletteTheme.PFLANZEN_WARM: [Color8(211,233,166), Color8(156,188,98),  Color8(102,145,50),  Color8(54,91,19),   Color8(35,65,10), Color8(196,217,255), Color8(151,176,186), Color8(101,120,127), Color8(55,66,71),   Color8(30,38,41)],
	PaletteTheme.BLAU_WASSER: [Color8(0,0,255),     Color8(193,234,255), Color8(142,198,226), Color8(75,147,184), Color8(24,86,118), Color8(120,180,254), Color8(44,138,251),  Color8(10,97,203),   Color8(3,50,106),   Color8(1,25,55)],
	PaletteTheme.GELB_HAUT: [Color8(255,255,0),   Color8(249,243,166), Color8(248,227,31),  Color8(223,183,10), Color8(175,144,0), Color8(248,213,201), Color8(255,217,193), Color8(241,188,169), Color8(217,161,123), Color8(190,145,108)],
	PaletteTheme.HOLZ_ERDE: [Color8(217,185,157), Color8(189,151,117), Color8(146,104,66), Color8(123,91,65), Color8(101,69,29), Color8(98,62,43),    Color8(67,40,26),    Color8(37,22,10),   Color8(25,14,5),    Color8(12,6,2)],
	PaletteTheme.LILA_MAGIE: [Color8(255,0,255),   Color8(246,218,248), Color8(239,168,245), Color8(229,84,243), Color8(173,7,189), Color8(211,175,247), Color8(164,101,226), Color8(125,58,191),  Color8(72,11,131),  Color8(40,3,75)]
}

func generate_svg_palette() -> void:
	var box_size: float = kachel_groesse_svg
	var padding: float = abstand_svg if mit_beschriftung else 2.0
	
	var offset_x: float = 120.0 if mit_beschriftung else 20.0
	var offset_y: float = 140.0 if mit_beschriftung else 20.0 
	
	var total_width = int(offset_x + (8.0 * (box_size + padding)))
	var total_height = int(offset_y + (10.0 * (box_size + padding)) + (40.0 if mit_beschriftung else 0.0))
	
	# Wir sammeln alle Zeilen in einem Array, um Formatierungsfehler zu vermeiden
	var lines: PackedStringArray = []
	
	lines.append("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>")
	lines.append("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\">" % [total_width, total_height, total_width, total_height])
	lines.append("  <rect width=\"100%\" height=\"100%\" fill=\"#222222\" />")
	
	if mit_beschriftung:
		var theme_names = PaletteTheme.keys()
		for theme in range(8):
			var x = offset_x + theme * (box_size + padding) + (box_size / 2.0)
			var y = offset_y - 25.0
			lines.append("  <text x=\"%f\" y=\"%f\" transform=\"rotate(-90, %f, %f)\" fill=\"#ffffff\" font-family=\"sans-serif\" font-size=\"12\" font-weight=\"bold\" text-anchor=\"start\">%s</text>" % [x, y, x, y, theme_names[theme]])
			lines.append("  <text x=\"%f\" y=\"%f\" fill=\"#888888\" font-family=\"sans-serif\" font-size=\"10\" text-anchor=\"middle\">ID: %d</text>" % [x, offset_y - 8.0, theme])

	for shade in range(10):
		if mit_beschriftung:
			var text_y = offset_y + shade * (box_size + padding) + (box_size / 2.0) + 5.0
			lines.append("  <text x=\"20\" y=\"%f\" fill=\"#aaaaaa\" font-family=\"sans-serif\" font-size=\"14\" font-weight=\"bold\">Stufe %d</text>" % [text_y, shade])
		
		for theme in range(8):
			var current_color: Color = FIXED_PALETTE[theme][shade]
			
			# HIER WIRD DEINE HILFSFUNKTION NUN REPTABEL UND SICHER GENUTZT!
			var r = clampi(inline_scale_color(current_color.r), 0, 255)
			var g = clampi(inline_scale_color(current_color.g), 0, 255)
			var b = clampi(inline_scale_color(current_color.b), 0, 255)
			var hex_str = "#%02x%02x%02x" % [r, g, b]
			
			var x = offset_x + theme * (box_size + padding)
			var y = offset_y + shade * (box_size + padding)
			
			var rx_val = 6 if mit_beschriftung else 0
			lines.append("  <rect x=\"%f\" y=\"%f\" width=\"%f\" height=\"%f\" rx=\"%d\" fill=\"%s\" stroke=\"#444444\" stroke-width=\"1\" />" % [x, y, box_size, box_size, rx_val, hex_str])
			
			if mit_beschriftung:
				var text_color = "#000000" if current_color.get_luminance() > 0.5 else "#ffffff"
				lines.append("  <text x=\"%f\" y=\"%f\" fill=\"%s\" font-family=\"sans-serif\" font-size=\"9\" text-anchor=\"middle\" opacity=\"0.7\">%s</text>" % [x + (box_size/2.0), y + (box_size/2.0) + 4.0, text_color, hex_str.to_upper()])

	if mit_beschriftung:
		lines.append("  <text x=\"20\" y=\"%f\" fill=\"#ffffff\" font-family=\"sans-serif\" font-size=\"18\" font-weight=\"bold\">Smart Colors Farbpalette</text>" % [total_height - 20.0])
	
	lines.append("</svg>")
	
	# Wir fügen die Zeilen mit einem sauberen, standardisierten Zeilenumbruch zusammen
	var full_svg_string = "\n".join(lines)
	
	var file = FileAccess.open("res://Smart_Colors_Farbpalette.svg", FileAccess.WRITE)
	if file:
		file.store_string(full_svg_string)
		file.flush()
		file.close()
		print("[Smart Colors] SVG erfolgreich exportiert -> res://Smart_Colors_Farbpalette.svg")

func generate_png_texture() -> void:
	var img_w = 8 * kachel_groesse_png
	var img_h = 10 * kachel_groesse_png
	var image = Image.create(img_w, img_h, false, Image.FORMAT_RGBA8)
	
	for shade in range(10):
		for theme in range(8):
			var current_color: Color = FIXED_PALETTE[theme][shade]
			var start_x = theme * kachel_groesse_png
			var start_y = shade * kachel_groesse_png
			
			for px in range(kachel_groesse_png):
				for py in range(kachel_groesse_png):
					image.set_pixel(start_x + px, start_y + py, current_color)
					
	var error = image.save_png("res://Smart_Colors_Texture.png")
	if error == OK:
		print("[Smart Colors] PNG-Textur erfolgreich exportiert -> res://Smart_Colors_Texture.png")
	else:
		print("[Smart Colors] Fehler beim PNG-Export Code: ", error)

func inline_scale_color(val: float) -> int:
	return int(round(val * 255.0))
