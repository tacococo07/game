extends CanvasLayer

@export var gravity_bullets_price: int = 50

var gravity_bullets_bought: bool = false

var cube: CharacterBody2D
var hud: CanvasLayer
var gravity_button: Button


func _ready() -> void:
	visible = false

	cube = get_node("../../Cube")
	hud = get_node("..")

	gravity_button = find_child(
		"GravityBulletsButton",
		true,
		false
	) as Button

	if gravity_button == null:
		push_error("Could not find GravityBulletsButton.")
		return

	gravity_button.pressed.connect(_buy_gravity_bullets)

	update_button()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_I and event.pressed and not event.echo:
			toggle_shop()


func toggle_shop() -> void:
	if visible:
		visible = false
		return

	# Don't open while the cube is attacking.
	if cube.shooting:
		return

	# Don't open during a run.
	if cube.run_started:
		return

	visible = true


func _buy_gravity_bullets() -> void:
	if gravity_bullets_bought:
		return

	if hud.money < gravity_bullets_price:
		return

	hud.money -= gravity_bullets_price
	hud.get_node("MoneyLabel").text = "$" + str(hud.money)

	gravity_bullets_bought = true
	cube.gravity_bullets_enabled = true

	gravity_button.visible = false


func update_button() -> void:
	if gravity_button != null:
		gravity_button.text = "GRAVITY BULLETS\n$" + str(gravity_bullets_price)
