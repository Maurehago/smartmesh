@tool
extends Node3D
class_name IAArray

@export_group("Vorlagen")
# Die normalen Objekte für das Innere der Fläche
@export var kachel_vorlagen: Array[PackedScene] = []:
	set(value):
		kachel_vorlagen = value
		_update_grid()

# Spezielle Objekte, die NUR am Rand platziert werden (z.B. Zaun, Bordstein, Mauer)
@export var rand_vorlagen: Array[PackedScene] = []:
	set(value):
		rand_vorlagen = value
		_update_grid()

# Schaltet um, ob die Fläche im Inneren hohl sein soll oder gefüllt
@export var nur_rand_generieren: bool = false:
	set(value):
		nur_rand_generieren = value
		_update_grid()

@export_group("Dimensionen")
@export var spalten: int = 5:
	set(value):
		spalten = max(1, value)
		_update_grid()

@export var zeilen: int = 5:
	set(value):
		zeilen = max(1, value)
		_update_grid()

@export_group("Raster Einstellungen")
@export var kachel_groesse: Vector2 = Vector2(2.0, 2.0):
	set(value):
		kachel_groesse = value
		_update_grid()

@export var abstand: Vector2 = Vector2(0.0, 0.0):
	set(value):
		abstand = value
		_update_grid()

@export_group("Zufall (Nur für Innere Kacheln)")
@export var voll_zufall_rotation: bool = false:
	set(value):
		voll_zufall_rotation = value
		_update_grid()

@export var positions_streuung: float = 0.0:
	set(value):
		positions_streuung = max(0.0, value)
		_update_grid()

@export var min_skalierung: float = 1.0:
	set(value):
		min_skalierung = max(0.1, value)
		_update_grid()

@export var max_skalierung: float = 1.0:
	set(value):
		max_skalierung = max(0.1, value)
		_update_grid()

func _ready() -> void:
	# Wartet, bis die Node komplett im Tree registriert ist, 
	# bevor die allererste Generierung beim Laden der Szene triggert
	_update_grid()

func _update_grid() -> void:
	# SICHERHEIT 1: Wenn die Node noch nicht bereit ist (beim Laden der Szene),
	# brechen wir sofort ab, um Geister-Knoten und Fehler zu verhindern!
	if not is_node_ready():
		return

	# 1. Alte Objekte löschen
	# Wichtig: Wir nutzen 'free()' statt 'queue_free()' im Editor-Modus,
	# damit die Nodes SOFORT verschwinden und nicht erst am Frame-Ende.
	for child in get_children():
		if child.is_in_group("grid_kachel"):
			child.free()
			
	var bereinigte_kacheln = kachel_vorlagen.filter(func(scene): return scene != null)
	var bereinigte_raender = rand_vorlagen.filter(func(scene): return scene != null)
	
	if bereinigte_kacheln.is_empty() and bereinigte_raender.is_empty():
		return

	# Verwenden des stabilen Node-Pfad-Seeds
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(get_path()) + 1337

	# 2. Raster durchlaufen
	for x in range(spalten):
		for z in range(zeilen):
			
			var ist_linker_rand = (x == 0)
			var ist_rechter_rand = (x == spalten - 1)
			var ist_oberer_rand = (z == 0)
			var ist_unterer_rand = (z == zeilen - 1)
			
			var ist_am_rand = ist_linker_rand or ist_rechter_rand or ist_oberer_rand or ist_unterer_rand
			
			var gewaehlte_vorlage: PackedScene = null
			var ist_rand_objekt = false
			
			if ist_am_rand and not bereinigte_raender.is_empty():
				var idx = rng.randi_range(0, bereinigte_raender.size() - 1)
				gewaehlte_vorlage = bereinigte_raender[idx]
				ist_rand_objekt = true
			elif not nur_rand_generieren and not bereinigte_kacheln.is_empty():
				var idx = rng.randi_range(0, bereinigte_kacheln.size() - 1)
				gewaehlte_vorlage = bereinigte_kacheln[idx]
			
			if not gewaehlte_vorlage:
				continue
				
			# 3. Instanziieren
			# Erstellt die Instanz und dupliziert sie tiefenrein (entkoppelt Ressourcen)
			var neue_instanz = gewaehlte_vorlage.instantiate()
			# Option: Falls Sie Materialien/Eigenschaften der Instanz im Tool ändern wollen:
			# neue_instanz = neue_instanz.duplicate(Node.DUPLICATE_USE_INSTANTIATION) 

			neue_instanz.add_to_group("grid_kachel")
			add_child(neue_instanz)
			
			# SICHERHEIT 2: Das Setzen des Owners darf erst passieren, wenn die Szene
			# komplett geladen ist. Wir prüfen, ob ein gültiger Editor-Wurzelknoten existiert.
			if Engine.is_editor_hint() and get_tree() and get_tree().edited_scene_root:
				neue_instanz.owner = get_tree().edited_scene_root
			
			# keine verschiebung
			#var pos_x = x * (kachel_groesse.x + abstand.x)
			#var pos_z = z * (kachel_groesse.y + abstand.y)

			# Verschiebt die zentrierten Meshes um die Hälfte nach rechts und unten
			var pos_x = x * (kachel_groesse.x + abstand.x) + (kachel_groesse.x / 2.0)
			var pos_z = z * (kachel_groesse.y + abstand.y) + (kachel_groesse.y / 2.0)

			
			if not ist_rand_objekt and positions_streuung > 0.0:
				pos_x += rng.randf_range(-positions_streuung, positions_streuung)
				pos_z += rng.randf_range(-positions_streuung, positions_streuung)
				
			neue_instanz.transform.origin = Vector3(pos_x, 0, pos_z)
			
			if ist_rand_objekt:
				if ist_oberer_rand:
					neue_instanz.rotate_y(deg_to_rad(180))
				elif ist_unterer_rand:
					neue_instanz.rotate_y(deg_to_rad(0))
				elif ist_linker_rand:
					neue_instanz.rotate_y(deg_to_rad(-90))
				elif ist_rechter_rand:
					neue_instanz.rotate_y(deg_to_rad(90))
			else:
				if voll_zufall_rotation:
					neue_instanz.rotate_y(rng.randf_range(0, 2 * PI))
				if min_skalierung != 1.0 or max_skalierung != 1.0:
					var zufalls_scale = rng.randf_range(min_skalierung, max_skalierung)
					neue_instanz.scale = Vector3(zufalls_scale, zufalls_scale, zufalls_scale)

	# 5. Ganz am Ende der Funktion (nach der Schleife) einfügen:
	if Engine.is_editor_hint():
		update_gizmos() # Zwingt Godot, das Gizmo und seine Griffe SOFORT neu zu berechnen
