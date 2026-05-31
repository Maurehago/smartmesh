@tool
extends Node3D

@export var source_mesh:Mesh

@export_category("Aktionen")

# Erzeugt einen Button mit der Aufschrift "Blender Mesh konvertieren"
# Beim Klick wird die Funktion "convert_mesh" aufgerufen
@export_tool_button("Mesh konvertieren", "Mesh")
var import_button = convert_mesh

# Erzeugt einen zweiten Button für das Kombinieren
@export_tool_button("Bauteile verschmelzen", "MultiMeshInstance3D")
var kombi_button = kombiniere_bauteile_aus_liste


func kombiniere_bauteile_aus_liste() -> void:
	print("Button geklickt: Kombination startet...")
	# Deine Kombinier-Logik hier...

func convert_mesh() -> void:
	if !source_mesh: return
	
	## Mesh anpassen
	var target_mesh:SmartMesh = Smart.mesh_to_smartmesh(source_mesh)
	target_mesh.emit_changed()
	print("Import via Vertex-Colors abgeschlossen! Gruppen: ", target_mesh.vertex_group.keys())
