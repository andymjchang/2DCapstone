extends CanvasLayer

var time: float = 0.0
var initial_y: float
var amplitude: float = 30.0  # How far up/down the boss moves
var speed: float = 1.5      # How fast the boss moves
var horizontal_amplitude: float = 30.0  # How far left/right the boss moves
var horizontal_speed: float = 0.5      # How fast the horizontal movement is
var random_offset: float = 0.0
var random_timer: float = 0.0
var initial_x: float
var health: int = 175

@export var sprite : AnimatedSprite2D
@export var glitch : ColorRect

var attack_timer: float = 0.0
var attack_interval: float = 3.0  # 
var attack_chance: float = 0.3   

func _ready() -> void:
	if !Globals.curFile.begins_with("BossLevel"):
		self.visible = false
	$Sprite/TextureProgressBar.max_value = health
	$Sprite/TextureProgressBar.value = health
	initial_y = $Sprite.position.y
	initial_x = $Sprite.position.x
	
	glitch.modulate.a = 1.0
	glitch.visible = true
	sprite.modulate.a = 0.0
	
	# fade out glitch and reduce shake
	var glitch_tween = create_tween()
	glitch_tween.set_parallel(true)  # Allow multiple properties to tween simultaneously
	glitch_tween.tween_property(glitch, "modulate:a", 0.0, 3.0)
	glitch_tween.tween_property(glitch.material, "shader_parameter/shake_rate", 0.0, 3.0)
	
	# fade in sprite
	var sprite_tween = create_tween()
	sprite_tween.tween_property(sprite, "modulate:a", 1.0, 5.0)
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("idle")

func _process(delta: float) -> void:
	time += delta
	random_timer += delta
	
	# Update random offset every 2 seconds
	if random_timer >= 2.0:
		random_timer = 0.0
		random_offset = randf_range(-10.0, 10.0)
	
	# Calculate new Y position using sine wave + random offset
	var new_y = initial_y + (sin(time * speed) * amplitude) + random_offset
	
	# Calculate new X position using sine wave (slower and smaller movement)
	var new_x = initial_x + (sin(time * horizontal_speed) * horizontal_amplitude)
	
	# Clamp the positions to prevent moving too far
	new_y = clamp(new_y, initial_y - amplitude, initial_y + amplitude)
	new_x = clamp(new_x, initial_x - horizontal_amplitude, initial_x + horizontal_amplitude)
	
	# Update sprite position
	sprite.position = Vector2(new_x, new_y)
	
	# Handle attack animation
	attack_timer += delta
	if attack_timer >= attack_interval:
		attack_timer = 0.0
		if randf() < attack_chance and sprite.animation == "idle":
			sprite.play("attack")

func _on_animation_finished() -> void:
	if sprite.animation == "attack":
		sprite.play("idle")

# Called when an enemy dies in boss level
func enemy_died_in_boss_level() -> void:
	take_damage(1)
	await get_tree().create_timer(0.4).timeout
	
	sprite.material.set_shader_parameter("damage_intensity", 0.5)
	# sprite.scale = sprite.scale * 1.2
	await get_tree().create_timer(0.25).timeout
	sprite.material.set_shader_parameter("damage_intensity", 0.0)
	# sprite.scale = Vector2(1, 1)

func take_damage(amount: int) -> void:
	health -= amount
	var progress_bar = sprite.get_node("TextureProgressBar")
	progress_bar.value = health
	
	if health <= 0:
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(sprite, "modulate:a", 0.0, 2.0)
		await fade_out_tween.finished 