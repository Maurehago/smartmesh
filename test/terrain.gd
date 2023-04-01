@tool
extends MeshInstance3D

@export var test:bool = false : set = _test
@export var size:int = 64
@export var power:float = 50.0
@export var errode:bool = false
@export var noise:FastNoiseLite


func _test(value):
	generate()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_highvalue(pos:Vector2) -> float:
	var value:float = noise.get_noise_2dv(pos)
	
	# Errode
	if errode:
		#for y in range(-3,3,1):
		#	for x in range(-3,3,1):
		var size = 2.0

		var check_h:float = noise.get_noise_2d(pos.x +size, pos.y -size)
		if check_h < value:
			value -= (value-check_h) /2

		check_h = noise.get_noise_2d(pos.x +size, pos.y +size)
		if check_h < value:
			value -= (value-check_h) /2
		
		check_h = noise.get_noise_2d(pos.x -size, pos.y +size)
		if check_h < value:
			value -= (value-check_h) /2

		check_h = noise.get_noise_2d(pos.x -size, pos.y -size)
		if check_h < value:
			value -= (value-check_h) /2

	return value * power

func generate():
	if !noise:
		return
	var glob_pos:Vector3 = self.global_position
	var plane:PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(size, size)
	var subdev:int = size -2
	plane.subdivide_width = subdev
	plane.subdivide_depth = subdev

	var am:ArrayMesh = ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane.get_mesh_arrays())
	
	var mdt:MeshDataTool = MeshDataTool.new()
	mdt.create_from_surface(am, 0)
	
	# Höhe
	for i in range(mdt.get_vertex_count()):
		var vertex:Vector3 = mdt.get_vertex(i)
		# Punkte lesen
		vertex.y = get_highvalue(Vector2(vertex.x, vertex.z) + Vector2(glob_pos.x, glob_pos.z))
		mdt.set_vertex(i, vertex)

	# Farben
	for i in range(mdt.get_face_count()):
		var norm:Vector3 = mdt.get_face_normal(i)
		var diff:float = norm.dot(Vector3.UP)
		
		for v in range(3):
			var index:int = mdt.get_face_vertex(i, v)
			var col = 0.2 #diff/3.000
			var vertex:Vector3 = mdt.get_vertex(index)
			mdt.set_vertex_normal(index, norm)

			if diff >= 0.900 and vertex.y < power * 0.15:
				# Wiese
				mdt.set_vertex_color(index, Color(0,col,0))
			elif diff >= 0.600 and vertex.y > power * 0.3:
				# Schnee
				mdt.set_vertex_color(index, Color(0.9,0.9,0.9))
			else:
				# Stein
				col = 0.1 #diff/4.000
				mdt.set_vertex_color(index, Color(col,col,col))
	
	am.clear_surfaces()
	mdt.commit_to_surface(am)
	
	self.mesh = am
	
