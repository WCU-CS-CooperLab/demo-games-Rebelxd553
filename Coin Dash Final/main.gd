extends Node
@export var coin_scene : PackedScene
@export var cactus_scene : PackedScene
@export var playtime = 30
var level = 1
var score = 0
var time_left = 0
var screensize = Vector2.ZERO
var playing = false
var cacti = []


func _ready():
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
	$Player.hide()



func new_game():
	playing = true
	level = 1
	score = 0
	time_left = playtime
	$Player.start()
	$Player.show()
	$GameTimer.start()
	spawn_coins()
	spawn_cacti()
	
	
func spawn_coins():
	for i in level + 4:
		var c = coin_scene.instantiate()
		add_child(c)
		c.screensize = screensize
		c.position = Vector2(randi_range(0, screensize.x),
			randi_range(0, screensize.y))
	$LevelSound.play()

func spawn_cacti():
	for cactus in cacti:
		cactus.queue_free()
	cacti.clear()  # Clear the list of cacti references

	randomize()  # Ensure randomization for each level
	var min_distance = 100  # Minimum distance from the player in pixels
	var player_position = $Player.position  # Get the player's position
	
	var number_of_cacti = randi_range(1, 5)
	
	for i in range(number_of_cacti):
		var cactus = cactus_scene.instantiate()
		var cactus_position = Vector2.ZERO
		
		while true:
			cactus_position = Vector2(randi_range(0, screensize.x), randi_range(0, screensize.y))
			if cactus_position.distance_to(player_position) >= min_distance:
				break  # Exit the loop if the position is far enough from the player
				
		cactus.position = cactus_position
		add_child(cactus)
		cacti.append(cactus)  # Keep track of the cactus instance

func _process(delta):
	if playing and get_tree().get_nodes_in_group("coins").size() == 0:
		level += 1
		time_left += 5
		spawn_coins()
		spawn_cacti()

func _on_game_timer_timeout():
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left <= 0:
		game_over()


func _on_player_hurt():
	game_over()

func _on_player_pickup():
	score += 1
	$HUD.update_score(score)
	$CoinSound.play()

func game_over():
	playing = false
	$GameTimer.stop()
	get_tree().call_group("coins", "queue_free")
	$HUD.show_game_over()
	$Player.die()
	$EndSound.play()


func _on_hud_start_game():
	new_game()
	$HUD.update_score(score)
	$HUD.update_timer(time_left)


