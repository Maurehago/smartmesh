@tool
extends MeshInstance3D
class_name SmartInstance3D

# =====================
#  Export Variablen
# ------------------
@export_category("SmartMesh")
@export_group("Resize", "resize_")
@export var resize_x: bool = false
@export var resize_y: bool = false
@export var resize_z: bool = false
@export var resize_save_zone: Vector3 = Vector3(0.16, 0.16, 0.16)
@export var resize_step: Vector3 = Vector3(0.16, 0.16, 0.16)
@export var resize_grow: bool = false : set = _resize_grow
@export var resize_shrink: bool = false : set = _resize_shrink

@export_group("Combine", "combine_")
@export var combine_surfaces: bool = false : set = _combine_surfaces

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Prüft auf das mesh
func check_mesh() -> ArrayMesh:
	var new_mesh: ArrayMesh = ArrayMesh.new()
	if self.mesh is PrimitiveMesh:
		for i in range(self.mesh.get_surface_count()):
			new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, self.mesh.surface_get_arrays(i))
			new_mesh.surface_set_material(i, self.mesh.surface_get_material(i))
	else:
		new_mesh = self.mesh
	
	return new_mesh


# Mesh soll wachsen
func _resize_grow(value: bool):
	resize_grow = value
	if !value:
		return
		
	var old_mesh = check_mesh()
	var new_mesh: ArrayMesh = ArrayMesh.new()
	var mdt = MeshDataTool.new()
	var isCancel: bool = false
	var step: Vector3 = resize_step/2
	
	# Alle oberflächen durchgehen
	for i in range(old_mesh.get_surface_count()):
		mdt.create_from_surface(old_mesh, i)
	
		for j in range(mdt.get_vertex_count()):
			var vertex = mdt.get_vertex(j)
			
			# X-Achse
			if resize_x:
				if vertex.x > 0 and vertex.x > resize_save_zone.x:
					vertex.x += step.x
				elif vertex.x < 0 and vertex.x < -resize_save_zone.x:
					vertex.x -= step.x

			# Y-Achse
			if resize_y:
				if vertex.y > 0 and vertex.y > resize_save_zone.y:
					vertex.y += step.y
				elif vertex.y < 0 and vertex.y < -resize_save_zone.y:
					vertex.y -= step.y

			# Z-Achse
			if resize_z:
				if vertex.z > 0 and vertex.z > resize_save_zone.z:
					vertex.z += step.z
				elif vertex.z < 0 and vertex.z < -resize_save_zone.z:
					vertex.z -= step.z
			
			# Änderung merken
			mdt.set_vertex(j, vertex)
	
		# Surface in neues Array
		mdt.commit_to_surface(new_mesh)
		new_mesh.surface_set_material(i, old_mesh.surface_get_material(i))

	# Mesh merken
	self.mesh = new_mesh
	resize_grow = false

	print("AABB: ", new_mesh.get_aabb())

# Mesh soll kleiner werden
func _resize_shrink(value: bool):
	resize_shrink = value
	if !value:
		return
		
	var old_mesh = check_mesh()
	var new_mesh: ArrayMesh = ArrayMesh.new()
	var mdt = MeshDataTool.new()
	var isCancel: bool = false
	var step: Vector3 = resize_step/2
	
	# Alle oberflächen durchgehen
	for i in range(old_mesh.get_surface_count()):
		mdt.create_from_surface(old_mesh, i)
	
		for j in range(mdt.get_vertex_count()):
			var vertex = mdt.get_vertex(j)
			
			# X-Achse
			if resize_x:
				if vertex.x > 0 and vertex.x > resize_save_zone.x:
					if vertex.x - step.x <= resize_save_zone.x:
						isCancel = true
						break
					vertex.x -= step.x
				elif vertex.x < 0 and vertex.x < -resize_save_zone.x:
					if vertex.x + step.x >= -resize_save_zone.x:
						isCancel = true
						break
					vertex.x += step.x

			# Y-Achse
			if resize_y:
				if vertex.y > 0 and vertex.y > resize_save_zone.y:
					if vertex.y - step.y <= resize_save_zone.y:
						isCancel = true
						break
					vertex.y -= step.y
				elif vertex.y < 0 and vertex.y < -resize_save_zone.y:
					if vertex.y + step.y >= -resize_save_zone.y:
						isCancel = true
						break
					vertex.y += step.y

			# Z-Achse
			if resize_z:
				if vertex.z > 0 and vertex.z > resize_save_zone.z:
					if vertex.z - step.z <= resize_save_zone.z:
						isCancel = true
						break
					vertex.z -= step.z
				elif vertex.z < 0 and vertex.z < -resize_save_zone.z:
					if vertex.z + step.z >= -resize_save_zone.z:
						isCancel = true
						break
					vertex.z += step.z
			
			# Änderung merken
			mdt.set_vertex(j, vertex)
	
		if isCancel:
			break
		
		# Surface in neues Array
		mdt.commit_to_surface(new_mesh)
		new_mesh.surface_set_material(i, old_mesh.surface_get_material(i))

	if isCancel:
		return
	# Mesh merken
	self.mesh = new_mesh
	resize_shrink = false

func _combine_surfaces(value: bool):
	var smartInstance: SmartInstance3D = SmartInstance3D.new()
	smartInstance.mesh = combine_mat(self.mesh)
	self.add_child(smartInstance)
	smartInstance.owner = self.owner

func combine_mat(old_mesh: ArrayMesh) -> ArrayMesh:
	var list:Array = []
	
	# alle Surfaces durchgehen
	for i in range(old_mesh.get_surface_count()):
		if i == 0:
			var st: SurfaceTool = SurfaceTool.new()
			var mat: Material = old_mesh.surface_get_material(i)
			st.create_from(old_mesh, i)
			st.set_material(mat)
			
			var new_surface: Dictionary = {
				"material": mat
				, "surface": st
			}
			list.append(new_surface)
			print("Meshdata: ", list)
		else:
			# Material vorhanden prüfen
			var mat: Material = old_mesh.surface_get_material(i)
			var isNew: bool = true
			for j in range(list.size()):
				if isNew and list[j].material == mat:
					list[j].surface.append_from(old_mesh, i, Transform3D(Basis(), Vector3.ZERO))
					isNew = false
			
			if isNew:
				# neues Surface
				var st: SurfaceTool = SurfaceTool.new()
				var mat2: Material = old_mesh.surface_get_material(i)
				st.create_from(old_mesh, i)
				st.set_material(mat2)
				
				var new_surface: Dictionary = {
					"material": mat2
					, "surface": st
				}
				list.append(new_surface)
			pass
		pass
	
	# neues Array Mesh
	var new_mesh:ArrayMesh = ArrayMesh.new()
	
	# alle vorhanden Surfaces hinzufügen
	for i in range(list.size()):
		new_mesh = list[i].surface.commit(new_mesh)
	
	# neues Mesh zurückgeben
	return new_mesh
	pass
