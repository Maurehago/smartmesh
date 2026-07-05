extends Resource
class_name SmartObject

# Mesh Type
@export_storage var mesh_id: String = "box"

# Größe des Objektes
@export_storage var size: Vector3 = Vector3.ONE

# Position des Objektes
@export_storage var pos: Vector3 = Vector3.ZERO

# Rotation des Objektes
@export_storage var target_up: Vector3 = Vector3.UP

@export_storage var target_forward: Vector3 = Vector3.RIGHT

#@export_storage var rotate: Vector3 = Vector3.ZERO

# Farbmaske
@export_storage var color_number: float = 0.0
