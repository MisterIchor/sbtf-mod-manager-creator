@tool
class_name InteractableBase
extends HBoxContainer

@export var label_name: String = "Label me":
	set(value):
		label_name = value
		
		if not is_node_ready():
			await ready
		
		label.text = str(label_name, ":")
@onready var label: Label = $Label
