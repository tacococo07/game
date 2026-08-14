extends CanvasLayer

var survival_time: int = 0
var money: int = 0

var timer_running: bool = false
var second_timer: float = 0.0


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
	survival_time = 0
	money = 0
	second_timer = 0.0
	timer_running = true

	$TimerLabel.text = "0"
	$MoneyLabel.text = "$0"


func end_run() -> void:
	if not timer_running:
		return

	timer_running = false

	# $2 for every second survived.
	money = survival_time * 2

	# Show the money earned.
	$MoneyLabel.text = "$" + str(money)

	# Reset the timer after converting the time to money.
	survival_time = 0
	second_timer = 0.0

	$TimerLabel.text = "0"
