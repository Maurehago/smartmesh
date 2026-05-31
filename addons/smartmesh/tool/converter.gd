@tool
extends Smart3D

@export_group("Base")
@export var base_mesh:Mesh

## Konvertiere Mesh zu SmartMesh Resource
@export_tool_button("Mesh to Smartmesh", "Mesh")
var import_button = convert_mesh

@export var smart_mesh:SmartMesh

@export_group("Test")
@export var smart_size:SmartSize:
	set(v):smart_size = _set_gen_func(smart_size, v, test_mesh)

var is_converting:bool = false

## Erzeugt aus einem Mesh eine SmartMesh Resource
func convert_mesh():
	# Mesh prüfen
	if !base_mesh: return
	if !self.mesh: self.mesh = ArrayMesh.new() # Mesh zum Anzeigen
	
	# Konvertierung start 
	is_converting = true
	
	# SmartMesh erstellen
	smart_mesh = Smart.mesh_to_smartmesh(base_mesh)
	
	# Test Größe setzen
	if  !smart_size: smart_size = SmartSize.new()
	smart_size.size_x = smart_mesh.base_size.x
	smart_size.size_y = smart_mesh.base_size.y
	smart_size.size_z = smart_mesh.base_size.z

	# Konvertierung ende
	is_converting = false

	# Mesh Testen und anzeigen
	test_mesh()

## Testet ob die SmartMesh größenänderung richtig funktioniert
func test_mesh():
	if is_converting or !mesh or !smart_mesh: return

	# Smart Objekte erstellen
	var box_list:Array[SmartObject] = smart_size.generate() 
	print("SmartObj:", box_list)
	
	# Mesh erstellen
	Smart.smart_to_mesh(box_list, self.mesh, [smart_mesh])
