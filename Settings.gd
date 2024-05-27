extends Control

onready var Click_sound = get_node("/root/ClickSound")
onready var bgm_scene = get_node("/root/Bgm")

func _ready():
	if bgm_scene:
		bgm_scene.bus = "Music"
	if Click_sound:
		Click_sound.bus = "Sound_FX"

func _on_SettingBackButton_pressed():
	Click_sound.play()	
	queue_free()

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)
	if value == -30:
		AudioServer.set_bus_mute(bus_index,true)
	else: 
		AudioServer.set_bus_mute(bus_index,false)
		
func _on_Master_value_changed(value):
	volume(0, value)	
	
func _on_Music_value_changed(value):
	volume(1, value)

func _on_Sound_FX_value_changed(value):
	volume(2, value)
