@tool
extends Resource
class_name SmartMesh

@export var is_vertex_scale:bool = false # Wenn true dann werden Vertices verschoben und nicht skaliert
@export var save_area:Vector3 = Vector3.ZERO # Sicherer Bereich in dem Vertex Punkte nicht verschoben werden. Ausserhalb des Bereiches werden die VertexPunkte beim Skalieren verschoben.

@export var vertices: PackedVector3Array # ArrayType ARRAY_VERTEX = 0
@export var normals: PackedVector3Array # ArrayType ARRAY_NORMAL = 1
@export var indices: PackedInt32Array # ArrayType ARRAY_INDEX = 12

## Dynamische Vertex-Gruppen. 
## Key (String): Name der Gruppe (z.B. "oben", "radius_links")
## Value (PackedInt32Array): Die dazugehörigen Vertex-Indizes
@export var vertex_group: Dictionary = {}

@export var base_size:Vector3 # Nasis Größe um Skalierung und Vertex-Punkte Verschiebung berechnen zu können

## Hilfsfunktion, um eine Gruppe sicher abzurufen oder neu zu erstellen
func get_group(group_name: String) -> PackedInt32Array:
	if not vertex_group.has(group_name):
		vertex_group[group_name] = PackedInt32Array()
	return vertex_group[group_name]
	
