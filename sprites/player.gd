extends CanvasLayer

@export var gravity_bullets_price: int = 50

var gravity_bullets_bought: bool = false

@onready var cube = $"../Cube"
@onready var hud = $"../HUD"
@onready var gravity_button: Button = $Panel/GravityBulletsButton


func _ready() -> void:
	visible = false
	gravity_button.pressed.connect(_buy_gravity_bullets)

	update_button()


func _process(_delta: float) -> void:
	# I only opens the shop when the cube is idle.
	if Input.is_key_pressed(KEY_I):
		if not visible and cube.is_idle():
			visible = true


func _buy_gravity_bullets() -> void:
	if gravity_bullets_bought:
		return

	if hud.money < gravity_bullets_price:
		return

	# Spend the money.
	hud.money -= gravity_bullets_price
	hud.update_money_display()

	# Buy the upgrade.
	gravity_bullets_bought = true

	# Tell the cube about the upgrade.
	cube.gravity_bullets_enabled = true

	# Make the item disappear.
	gravity_button.visible = false


func update_button() -> void:
	gravity_button.text = "GRAVITY BULLETS\n$" + str(gravity_bullets_price)
