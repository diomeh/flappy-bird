extends Control

@onready var digits_container: HBoxContainer = $VBoxContainer/MarginContainer/DigitsContainer

var _digits = [
	preload("res://assets/art/ui/numbers/0.png"),
	preload("res://assets/art/ui/numbers/1.png"),
	preload("res://assets/art/ui/numbers/2.png"),
	preload("res://assets/art/ui/numbers/3.png"),
	preload("res://assets/art/ui/numbers/4.png"),
	preload("res://assets/art/ui/numbers/5.png"),
	preload("res://assets/art/ui/numbers/6.png"),
	preload("res://assets/art/ui/numbers/7.png"),
	preload("res://assets/art/ui/numbers/8.png"),
	preload("res://assets/art/ui/numbers/9.png"),
]

var _score = -1


func _ready() -> void:
	SignalBus.player_scored.connect(_on_player_scored)
	_bump_score()


func _on_player_scored() -> void:
	_bump_score()


func _bump_score() -> void:
	_score += 1

	var children = digits_container.get_children()
	for child in children:
		digits_container.remove_child(child)
		child.queue_free()

	var digits = number_to_digits(_score)
	for digit in digits:
		var texture_rect = TextureRect.new()
		var texture = _digits[digit]
		texture_rect.texture = texture
		digits_container.add_child(texture_rect)


func number_to_digits(n: int) -> Array[int]:
	var digit_array: Array[int] = []
	for digit in str(n):
		if digit.is_valid_int():
			digit_array.push_back(digit.to_int())
	return digit_array
