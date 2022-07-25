extends Camera

onready var player = get_parent().player
onready var main = $Theme/CenterContainer/Main
onready var settings = $Theme/CenterContainer/Settings
onready var volume = $Theme/CenterContainer/Settings/HSplitContainer/VolumeSlider
onready var anim = $AnimationPlayer

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),-12)
	volume.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	anim.play("start")

func _process(delta):
	rotate_y(0.1*delta)

func _on_PlayButton_pressed():
	anim.play("dissolve")
	yield(anim,"animation_finished")
	get_parent().add_child(player)
	queue_free()

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_SettingsButton_pressed():
	main.visible = false
	settings.visible = true

func _on_BackButton_pressed():
	main.visible = true
	settings.visible = false

func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)

func _on_MouseSlider_value_changed(value):
	player.mouse_sensitivity = value

func _on_FullscreenCheckBox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
