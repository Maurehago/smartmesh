extends Resource
class_name SmartObject

# Mesh Type
@export_storage var mesh_type: String = "box"
@export_storage var mesh_number: int = 0

# Größe des Objektes
@export_storage var size: Vector3 = Vector3.ONE

# Position des Objektes
@export_storage var pos: Vector3 = Vector3.ZERO

# Rotation des Objektes
@export_storage var rotate: Vector3 = Vector3.ZERO

# Farbmaske
@export_storage var color_mask: float = 0.0
