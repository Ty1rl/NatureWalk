extends Control

onready var player = get_parent()
onready var pause = $CenterContainer/Pause
onready var settings = $CenterContainer/Settings
onready var volume = $CenterContainer/Settings/HSplitContainer/VolumeSlider
onready var fullscreen = $CenterContainer/Settings/HBoxContainer2/FullscreenCheckBox

func _ready():
	volume.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	if OS.window_fullscreen == true:
		fullscreen.pressed = true

func _on_ContinueButton_pressed():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_SettingsButton_pressed():
	pause.visible = false
	settings.visible = true

func _on_BackButton_pressed():
	pause.visible = true
	settings.visible = false

func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)

func _on_MouseSlider_value_changed(value):
	player.mouse_sensitivity = value

func _on_FullscreenCheckBox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
