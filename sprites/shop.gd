extends CanvasLayer

@export var gravity_bullets_price: int = 50

var gravity_bullets_bought: bool = false

var cube: CharacterBody2D
var hud: CanvasLayer
var gravity_button: Button

@onready var save_manager = $"../../Node/SaveManager"

func _ready() -> void:
	visible = false

	cube = get_node("../../Cube")
	hud = get_node("..")

	gravity_button = find_child("GravityBulletsButton", true, false) as Button
	if gravity_button == null:
		push_error("Could not find GravityBulletsButton.")
		return

	gravity_button.pressed.connect(_buy_gravity_bullets)

	gravity_bullets_bought = save_manager.gravity_bullets_bought
	if gravity_bullets_bought:
		cube.gravity_bullets_enabled = true
		gravity_button.visible = false

	update_button()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_I and event.pressed and not event.echo:
			toggle_shop()

func toggle_shop() -> void:
	if visible:
		visible = false
		return
	if cube.shooting:
		return
	if cube.run_started:
		return
	visible = true

func _buy_gravity_bullets() -> void:
	if gravity_bullets_bought:
		return
	if hud.money < gravity_bullets_price:
		return

	hud.money -= gravity_bullets_price
	hud.update_money_display()

	gravity_bullets_bought = true
	cube.gravity_bullets_enabled = true

	save_manager.gravity_bullets_bought = true
	save_manager.money = hud.money
	save_manager.save_data()

	gravity_button.visible = false

func update_button() -> void:
	if gravity_button != null:
		gravity_button.text = "GRAVITY BULLETS\n$" + str(gravity_bullets_price)
