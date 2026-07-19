@tool
extends SmartGen
class_name SmartWindow

@export_range(0.01, 0.2, 0.01) var width:float = 0.05:
	set(v):width = v; emit_changed()
@export_range(0.01, 0.2, 0.01) var deph:float = 0.05:
	set(v):deph = v; emit_changed()

func generate() -> Array[SmartObject]:
	object_list = []
	
	object_list = Smart.get_objectarray_border(self.size, Vector2(width, deph))
	return object_list
