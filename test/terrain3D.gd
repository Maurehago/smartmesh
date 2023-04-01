@tool
extends MultiMeshInstance3D

@export var test:bool = false : set = _test
@export var noise:FastNoiseLite

func _test(value):
	if value:
		calc_terrain()
		test = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func calc_terrain():
	#var noise = FastNoiseLite.new()
	var height:int = 30
	var h_test =  clampf(height, 0.000, 1.000)
	var size:int = 50
	var pos:PackedVector3Array = []
	
	# Daten ermitteln
	for x in range(size):
		for z in range(size):
			var high_value = noise.get_noise_2d(x, z)
			#print("high: ", high_value)
			for h in range(height):
				if high_value * height >= h:
					pos.append(Vector3(x, h, z))

	var count = pos.size()
	self.multimesh.instance_count = count
	for i in range(count):
		self.multimesh.set_instance_transform(i, Transform3D(Basis(),pos[i]))
	
	
