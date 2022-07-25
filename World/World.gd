extends Node

var rng = RandomNumberGenerator.new()
var noise = OpenSimplexNoise.new()

var thread = Thread.new()
var chunk_amount = 8
var chunk_size = 16
var chunks = {}
var unready_chunks = {}

var player = preload("res://Player/Player.tscn").instance()
onready var anim = $AnimationPlayer

func _ready():
	rng.randomize()
	noise.seed = rng.randi()
	noise.octaves = 5
	noise.period = 75.0
	noise.persistence = 0.5
	noise.lacunarity = 2
	
	anim.play("start")

func _process(_delta):
	update_chunks()
	clean_up_chunks()
	reset_chunks()

func add_chunk(x, z):
	var key = str(x) + "," + str(z)
	
	# check if chunk already exists or if it is in the unready_chunks (going to exist)
	if chunks.has(key) or unready_chunks.has(key):
		return
		
	# see if thread is not active at the moment (working on another chunk)
	if not thread.is_active():
		thread.start(self, "load_chunk", [thread, x, z])
		unready_chunks[key] = 1
		
func load_chunk(arr):
	var thread = arr[0]
	var x = arr[1]
	var z = arr[2]

	# generate chunk
	var chunk = Chunk.new(noise, chunk_size, x * chunk_size, z * chunk_size)
	
	# set chunk position
	chunk.translation = Vector3(x * chunk_size, 0, z * chunk_size)
	
	call_deferred("load_done", chunk, thread)

func load_done(chunk, thread):
	add_child(chunk)
	var key = str(chunk.get_translation().x / chunk_size) + "," + str(chunk.get_translation().z / chunk_size)
	chunks[key] = chunk
	unready_chunks.erase(key)
	thread.wait_to_finish()

func get_chunk(x, z):
	var key = str(x) + "," + str(z)
	if chunks.has(key):
		return chunks.get(key)
		
	return null

func update_chunks():
	var player_translation = player.translation
	var p_x = int(player_translation.x) / chunk_size
	var p_z = int(player_translation.z) / chunk_size
	
	for x in range(p_x - chunk_amount * 0.5, p_x + chunk_amount * 0.5):
		for z in range(p_z - chunk_amount * 0.5, p_z + chunk_amount * 0.5):
			add_chunk(x, z)
			var chunk = get_chunk(x, z)
			if chunk != null:
				chunk.should_remove = false

func clean_up_chunks():
	for key in chunks:
		var chunk = chunks[key]
		if chunk.should_remove:
			chunk.queue_free()
			chunks.erase(key)

func reset_chunks():
	for key in chunks:
		chunks[key].should_remove = true
