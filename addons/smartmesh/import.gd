@tool # Muss ein Editor Skript sein
extends EditorScenePostImport

# Pfade
var mesh_path: String = "res://mesh/"
var material_path: String = "res://mat/"
var scene_path: String = "res://scene/"

# Zwischenspeicher
var mesh_list:Dictionary = {}

# Wird nach dem automatischen Import aufgerufen
func _post_import(scene):
	# Zurücksetzen
	mesh_list = {}
	
	# Alle Nodes durchgehen
	print("Scene: ", scene)
	iterate(scene)
	
	# unter /scene/ speichern
	save_scene(scene)
	
	return scene # Wichtig! Szene muss wieder zurück gegeben werden

# Alle Nodes durchgehen
func iterate(node):
	if !node:
		return
	
	print("Node: ", node)
	
	# Wenn die Node ein Mesh hat
	if node is MeshInstance3D:
		node.mesh = extract_mesh(node)
		
		# todo: Transform in MeshList
	
	# Alle Kind Nodes von der Node durchgehen
	for child in node.get_children():
		iterate(child)


# Mesh als Resource speichern
func extract_mesh(node: MeshInstance3D) -> Mesh:
	var mesh:Mesh = node.mesh
	
	# Materialien neu zuordnen
	set_materials(mesh)
		
	# Pfad aus Namen extrahieren
	var fullName: String = mesh.resource_name
	var parts: PackedStringArray = fullName.split("_")
	var size = parts.size()
	var name = parts[size -1].to_lower()
	parts = parts.slice(0, size -1)
	
	# Pfad erstellen und prüfen ob dieser existiert
	var path = (mesh_path + "/".join(parts)).to_lower()
	if !DirAccess.dir_exists_absolute(path):
		# wenn der Pfad nicht exitiert, dann neuen Pfad anlegen
		DirAccess.make_dir_recursive_absolute(path)

	print("Path: ", path)
	fullName = path + "/" + name + ".mesh"
	mesh.resource_path = fullName
	
	# Test
	print("transform: ", node.transform)
	
	# Prüfen ob vorhanden
	if mesh_list.has(fullName):
		# neue Position hinzufügen
		mesh_list[fullName].transf.append(node.transform)
	else:
		# noch nicht in der Liste -> hinzufügen
		mesh_list[fullName] = {
			"name": name
			, "transf": [node.transform]
		}
		
		# Mesh speichern
		ResourceSaver.save(mesh, fullName)
	
	# Mesh zurück
	return mesh

# Material nach dem Namen dem Mesh zuweisen
func set_materials(mesh: Mesh):
	var s_count := mesh.get_surface_count()
	for i in range(s_count):
		var old_mat: Material = mesh.surface_get_material(i)
		
		# Name prüfen
		var path = (material_path + old_mat.resource_name + ".material").to_lower()
		if !FileAccess.file_exists(path):
			ResourceSaver.save(old_mat, path)

		# Gespeichertes Material setzen
		var new_mat: BaseMaterial3D = load(path)
		mesh.surface_set_material(i, new_mat)


# Szene speichern
func save_scene(scene: Node):
	# Pfad aus Namen extrahieren
	var fullName: String = scene.name
	var parts: PackedStringArray = fullName.split("_")
	var size = parts.size()
	var name = parts[size -1].to_lower()
	parts = parts.slice(0, size -1)
	
	# Pfad erstellen und prüfen ob dieser existiert
	var path = (scene_path + "/".join(parts)).to_lower()
	if !DirAccess.dir_exists_absolute(path):
		# wenn der Pfad nicht exitiert, dann neuen Pfad anlegen
		DirAccess.make_dir_recursive_absolute(path)

	print("Scene Path: ", path)
	fullName = path + "/" + name + ".tscn"

	# alle Kinder entfernen
	for n in scene.get_children():
		scene.remove_child(n)

	# neue Szene Generieren
	for key in mesh_list:
		var item:Dictionary = mesh_list[key]
		var mesh:Mesh = ResourceLoader.load(key)
		var mesh_name:String = item.name
		var count = item.transf.size()
		
		# wenn mehr als eines
		if count > 1:
			# neues Multimesh
			var mm:MultiMesh = MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = mesh
			mm.instance_count = count
			for i in range(count):
				mm.set_instance_transform(i, item.transf[i])
			
			# MultimesInstanz
			var mmi:MultiMeshInstance3D = MultiMeshInstance3D.new()
			mmi.name = mesh_name
			mmi.multimesh = mm
			scene.add_child(mmi)
			mmi.set_owner(scene)
		else:
			# Einzelnes Mesh
			var mi:MeshInstance3D = MeshInstance3D.new()
			mi.name = mesh_name
			mi.mesh = mesh
			mi.transform = item.transf[0]
			scene.add_child(mi)
			mi.set_owner(scene)

	# Speichern
	var new_scene: PackedScene = PackedScene.new()
	new_scene.pack(scene)
	ResourceSaver.save(new_scene, fullName)
