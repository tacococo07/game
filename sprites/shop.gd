extends CanvasLayer

@export var gravity_bullets_price: int = 50
@export var retaliation_price: int = 75

var gravity_bullets_bought: bool = false
var retaliation_unlocked: bool = false

var cube: CharacterBody2D
var hud: CanvasLayer

@onready var save_manager = $"../../Node"

@onready var gravity_button: Button = $Panel/GravityBulletsButton
@onready var retaliation_button: Button = $Panel/RetaliationButton

func _ready() -> void:
	visible = false

	cube = get_node("../../Cube")
	hud = get_node("..")

	if gravity_button == null:
		push_error("Could not find GravityBulletsButton in the scene!")
		return
	if retaliation_button == null:
		push_error("Could not find RetaliationButton in the scene!")
		return

	gravity_button.pressed.connect(_buy_gravity_bullets)
	retaliation_button.pressed.connect(_buy_retaliation)

	gravity_bullets_bought = save_manager.gravity_bullets_bought
	retaliation_unlocked = save_manager.retaliation_unlocked

	if gravity_bullets_bought:
		gravity_button.visible = false
	if retaliation_unlocked:
		retaliation_button.visible = false

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

func _buy_retaliation() -> void:
	if retaliation_unlocked:
		return
	if hud.money < retaliation_price:
		return

	hud.money -= retaliation_price
	hud.update_money_display()

	retaliation_unlocked = true

	save_manager.retaliation_unlocked = true
	save_manager.money = hud.money
	save_manager.save_data()

	retaliation_button.visible = false

func update_button() -> void:
	if gravity_button != null:
		gravity_button.text = "GRAVITY BULLETS\n$" + str(gravity_bullets_price)
	if retaliation_button != null:
		retaliation_button.text = "RETALIATION\n$" + str(retaliation_price)
