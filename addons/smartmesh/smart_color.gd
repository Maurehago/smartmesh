@tool
class_name SmartColor
extends Resource

# Farben Arrays
static var colors:Array = []
static var colors1:PackedColorArray = []
static var colors2:PackedColorArray = []
static var colors3:PackedColorArray = []
static var colors4:PackedColorArray = []
static var colors5:PackedColorArray = []
static var colors6:PackedColorArray = []
static var colors7:PackedColorArray = []
static var colors8:PackedColorArray = []


static func _init() -> void:
	colors1 = [Color8(245,245,245) #1
	, Color8(228,228,228) #2
	, Color8(206,206,206) #3
	, Color8(177,177,177) #4
	, Color8(142,142,142) #5
	, Color8(102,102,102) #6
	, Color8(62,62,62) #7
	, Color8(31,31,31) #8
	, Color8(0,0,0) #9
	]
	colors.append(colors1)
	
	colors2 = [Color8(251,180,161) #1
	, Color8(220,90,58) #2
	, Color8(171,58,29) #3
	, Color8(126,26,9) #4
	, Color8(211,233,166) #5
	, Color8(156,188,98) #6
	, Color8(102,145,50) #7
	, Color8(54,91,19) #8
	, Color8(255,0,0) #9
	]
	colors.append(colors2)

	colors3 = [Color8(255,198,76) #1
	, Color8(253,160,0) #2
	, Color8(240,121,0) #3
	, Color8(198,86,0) #4
	, Color8(120,254,122) #5
	, Color8(53,231,29) #6
	, Color8(26,151,9) #7
	, Color8(11,76,2) #8
	, Color8(0,255,0) #9
	]
	colors.append(colors3)

	colors4 = [Color8(246,218,248) #1
	, Color8(239,168,245) #2
	, Color8(229,84,243) #3
	, Color8(173,7,189) #4
	, Color8(217,185,157) #5
	, Color8(189,151,117) #6
	, Color8(146,104,66) #7
	, Color8(101,69,29) #8
	, Color8(0,0,255) #9
	]
	colors.append(colors4)

	colors5 = [Color8(211,175,247) #1
	, Color8(164,101,226) #2
	, Color8(125,58,191) #3
	, Color8(72,11,131) #4
	, Color8(123,91,65) #5
	, Color8(98,62,43) #6
	, Color8(67,40,26) #7
	, Color8(37,22,10) #8
	, Color8(255,255,0) #9
	]
	colors.append(colors5)

	colors6 = [Color8(193,234,255) #1
	, Color8(142,198,226) #2
	, Color8(75,147,184) #3
	, Color8(24,86,118) #4
	, Color8(249,243,166) #5
	, Color8(248,227,31) #6
	, Color8(223,183,10) #7
	, Color8(175,144,0) #8
	, Color8(255,0,255) #9
	]
	colors.append(colors6)

	colors7 = [Color8(120,180,254) #1
	, Color8(44,138,251) #2
	, Color8(10,97,203) #3
	, Color8(3,50,106) #4
	, Color8(248,213,201) #5
	, Color8(241,188,169) #6
	, Color8(217,161,123) #7
	, Color8(190,145,108) #8
	, Color8(0,255,255) #9
	]
	colors.append(colors7)

	colors8 = [Color8(196,217,255) #1
	, Color8(151,176,186) #2
	, Color8(101,120,127) #3
	, Color8(55,66,71) #4
	, Color8(255,217,193) #5
	, Color8(247,191,177) #6
	, Color8(214,162,163) #7
	, Color8(140,102,125) #8
	, Color8(255,255,255) #9
	]
	colors.append(colors8)

static func get_color(col:int, row:int) -> Color:
	if !colors1:
		_init()
	col -=1
	row -=1
	if col == null or col < 0:
		col = 0
	if col > 9:
		col = 9
	if row == null or row < 0:
		row = 0
	if row > 8:
		row = 8
	
	var r:PackedColorArray = colors[row]
	return r[col]
	
