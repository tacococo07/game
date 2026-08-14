extends CanvasLayer

var survival_time: int = 0
var money: int = 0

var timer_running: bool = false
var second_timer: float = 0.0

var gravity_multiplier_active: bool = false


func _ready() -> void:
	$TimerLabel.text = "0"
	$MoneyLabel.text = "$0"


func _process(delta: float) -> void:
	if not timer_running:
		return

	second_timer += delta

	if second_timer >= 1.0:
		second_timer -= 1.0
		survival_time += 1

		$TimerLabel.text = str(survival_time)


func start_run() -> void:
	# ONLY reset the timer.
	# Money is permanent between rounds.
	survival_time = 0
	second_timer = 0.0
	timer_running = true

	$TimerLabel.text = "0"


func end_run() -> void:
	if not timer_running:
		return

	timer_running = false

	var multiplier: int = 2

	if gravity_multiplier_active:
		multiplier = 5

	var money_earned: int = survival_time * multiplier

	money += money_earned

	$MoneyLabel.text = "$" + str(money)

	# Reset the timer, NOT the money.
	survival_time = 0
	second_timer = 0.0

	$TimerLabel.text = "0"

	gravity_multiplier_active = false


func set_gravity_multiplier(active: bool) -> void:
	gravity_multiplier_active = active
