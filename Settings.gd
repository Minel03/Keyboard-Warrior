extends Control

onready var Click_sound = get_node("/root/ClickSound")
onready var bgm_scene = get_node("/root/Bgm")

# Paths to the sliders - ensure these paths are correct
onready var master_slider = $Master
onready var music_slider = $Music
onready var sound_fx_slider = $Sound_FX

var config = ConfigFile.new()

func _ready():
	# Ensure sliders are correctly assigned
	if not master_slider:
		print("Error: Master slider not found")
		return
	if not music_slider:
		print("Error: Music slider not found")
		return
	if not sound_fx_slider:
		print("Error: Sound FX slider not found")
		return

	# Load volume settings
	load_volume_settings()

	# Set the audio buses if they exist
	if bgm_scene:
		bgm_scene.bus = "Music"
	if Click_sound:
		Click_sound.bus = "Sound_FX"
		
	# Connect the sliders to their respective functions
	master_slider.connect("value_changed", self, "_on_Master_value_changed")
	music_slider.connect("value_changed", self, "_on_Music_value_changed")
	sound_fx_slider.connect("value_changed", self, "_on_Sound_FX_value_changed")

func _on_SettingBackButton_pressed():
	Click_sound.play()	
	queue_free()

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)
	if value == -30:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)

	# Save the volume setting
	save_volume_settings()

func _on_Master_value_changed(value):
	volume(0, value)
	save_volume_settings()
	
func _on_Music_value_changed(value):
	volume(1, value)
	save_volume_settings()

func _on_Sound_FX_value_changed(value):
	volume(2, value)
	save_volume_settings()

func load_volume_settings():
	# Load the config file
	var err = config.load("user://settings.cfg")
	if err != OK:
		print("Failed to load config file")
		return
	
	# Load and apply the volume settings
	var master_volume = config.get_value("volume", "master", 0)
	var music_volume = config.get_value("volume", "music", 0)
	var sound_fx_volume = config.get_value("volume", "sound_fx", 0)
	
	if master_slider:
		master_slider.value = master_volume
	else:
		print("Error: Master slider is null during load")
		
	if music_slider:
		music_slider.value = music_volume
	else:
		print("Error: Music slider is null during load")
		
	if sound_fx_slider:
		sound_fx_slider.value = sound_fx_volume
	else:
		print("Error: Sound FX slider is null during load")
	
	volume(0, master_volume)
	volume(1, music_volume)
	volume(2, sound_fx_volume)

func save_volume_settings():
	# Save the volume settings to the config file
	if master_slider:
		config.set_value("volume", "master", master_slider.value)
	else:
		print("Error: Master slider is null during save")
		
	if music_slider:
		config.set_value("volume", "music", music_slider.value)
	else:
		print("Error: Music slider is null during save")
		
	if sound_fx_slider:
		config.set_value("volume", "sound_fx", sound_fx_slider.value)
	else:
		print("Error: Sound FX slider is null during save")
	
	var err = config.save("user://settings.cfg")
	if err != OK:
		print("Failed to save config file")
