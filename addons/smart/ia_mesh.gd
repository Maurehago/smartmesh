@tool
class_name IAMesh3D
extends MeshInstance3D

# Diese Variable wird vom Inspektor UND vom Gizmo gesteuert
@export var length: float = 2.0:
	set(value):
		length = max(0.1, value) # Verhindert negative Werte
		_update_mesh()

func _ready() -> void:
	if not mesh:
		mesh = BoxMesh.new()
	_update_mesh()

func _update_mesh() -> void:
	if mesh is BoxMesh:
		# Vertex-basiertes Ändern der Größe (keine Verzerrung der Scale-Eigenschaft!)
		mesh.size.z = length
		# Verschiebt das Mesh, damit es am Startpunkt (Nullpunkt) ausgerichtet bleibt
		mesh.center_offset.z = length / 2.0
		
