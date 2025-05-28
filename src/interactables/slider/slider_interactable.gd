@tool
class_name SliderInteractable
extends InteractableBase

signal value_changed(new_value: float)

@export var slider_label_prefix: String = "":
	set(value):
		slider_label_prefix = value
		
		if not is_node_ready():
			await ready
		
		_update_slider_label()
@export var value: float = 0:
	set(new_value):
		value = snappedf(new_value, step)
		
		if not is_node_ready():
			await ready
		
		h_slider.value = value
@export var max_value: float = 100:
	set(value):
		max_value = value
		notify_property_list_changed()
		
		if not is_node_ready():
			await ready
		
		h_slider.max_value = value
@export var min_value: float = 0:
	set(value):
		min_value = value
		notify_property_list_changed()
		
		if not is_node_ready():
			await ready
		
		h_slider.min_value = min_value
@export var step: float = 1.0:
	set(value):
		step = value
		notify_property_list_changed()
		
		if not is_node_ready():
			await ready
		
		h_slider.step = step

@onready var h_slider: HSlider = $HSlider
@onready var slider_label: Label = $SliderLabel



func _ready() -> void:
	_update_slider_label()
	h_slider.value_changed.connect(_on_HSlider_value_changed)


func _validate_property(property: Dictionary) -> void:
	if property.name == "value":
		property.hint = PROPERTY_HINT_RANGE
		property.hint_string = ",".join([min_value, max_value, step])



func _update_slider_label() -> void:
	slider_label.text = str(h_slider.value, slider_label_prefix)



func _on_HSlider_value_changed(new_value: float) -> void:
	_update_slider_label()
	value = new_value
	value_changed.emit(value)
