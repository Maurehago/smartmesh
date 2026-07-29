@tool
extends SmartGen

var wall_n:SmartWall # Wand Norden
var wall_o:SmartWall # Wand Osten
var wall_s:SmartWall # Wand Süden
var wall_w:SmartWall # Wand Westen
var wall_t:SmartWall # Decke
var wall_b:SmartWall # Boden

func _init() -> void:
	super()

func _ready() -> void:
	wall_n = Smart.get_or_create(self, "wall_n", SmartWall)
	wall_o = Smart.get_or_create(self, "wall_o", SmartWall)
	wall_s = Smart.get_or_create(self, "wall_s", SmartWall)
	wall_w = Smart.get_or_create(self, "wall_w", SmartWall)
	
func _generate():
	#super()
	var size = Vector3(size_x, size_y, size_z)
	if wall_n:
		var size_n = Vector3(size_x, size_y, 0.1)
		var obj_n = Smart.get_object_position(size, size_n, Vector3.FORWARD)
		wall_n.size_x = size_x
		wall_n.size_y = size_y
		wall_n.size_z = 0.1
		wall_n.position = obj_n.pos
		wall_n._generate()
		
	
