extends Node

var menu_music = load("res://assets/music/mainmenu_music.mp3")
var game_over_music = load("res://assets/music/Game_over.mp3")
var stage_1_music = load("res://assets/music/Stage1_Music.mp3")
var stage_2_music = load("res://assets/music/Stage2_Music.mp3")
var InfiniteMusic = load("res://assets/music/Infinite_bgm.mp3")
var projectile_sound = load("res://assets/music/Electric_projectile.mp3")

func play_menumusic():
	var music_player = $mainmenu_bgm
	if music_player:
		menu_music.loop = true  # Set loop mode
		if music_player.stream != menu_music:
			music_player.stream = menu_music
		if not music_player.playing:
			music_player.play()
	else:
		print("Error: mainmenu_bgm node not found")

func play_gameovermusic():
	var music_player = $gameover_music
	if music_player:
		if music_player.stream != game_over_music:
			music_player.stream = game_over_music
		if not music_player.playing:
			music_player.play()
	else:
		print("Error: gameover_music node not found")

func play_stage1music():
	var music_player = $stage1_music
	if music_player:
		stage_1_music.loop = true  # Set loop mode
		if music_player.stream != stage_1_music:
			music_player.stream = stage_1_music
		if not music_player.playing:
			music_player.play()
	else:
		print("Error: stage1_music node not found")

	
func play_stage2music():
	var music_player = $stage2_music
	if music_player:
		stage_2_music.loop = true  # Set loop mode
		if music_player.stream != stage_2_music:
			music_player.stream = stage_2_music
		if not music_player.playing:
			music_player.play()
	else:
		print("Error: stage2_music node not found")

func play_infinitemusic():
	var music_player = $infinite_music
	if music_player:
		InfiniteMusic.loop = true  # Set loop mode
		if music_player.stream != InfiniteMusic:
			music_player.stream = InfiniteMusic
		if not music_player.playing:
			music_player.play()
	else:
		print("Error: infinite_music node not found")

func stop_menumusic():
	var music_player = $mainmenu_bgm
	if music_player:
		music_player.stop()
	else:
		print("Error: mainmenu_bgm node not found")

func stop_gameovermusic():
	var music_player = $gameover_music
	if music_player:
		music_player.stop()
	else:
		print("Error: gameover_music node not found")

func stop_stage1music():
	var music_player = $stage1_music
	if music_player:
		music_player.stop()
	else:
		print("Error: stage 1 music node not found")

func stop_stage2music():
	var music_player = $stage2_music
	if music_player:
		music_player.stop()
	else:
		print("Error: stage 2 music node not found")

func stop_infinitemusic():
	var music_player = $infinite_music
	if music_player:
		music_player.stop()
	else:
		print("Error: infinite music node not found")

