extends Control

@onready var manage_mods_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/ManageModsButton
@onready var settings_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/SettingsButton
@onready var create_mod_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/CreateModButton



func _ready() -> void:
	manage_mods_button.pressed.connect(_on_ManageModsButton_pressed)
	settings_button.pressed.connect(_on_SettingsButton_pressed)
	create_mod_button.pressed.connect(_on_CreateModButton_pressed)



func _on_ManageModsButton_pressed() -> void:
	get_tree().change_scene_to_file("res://src/2_manager/manager.tscn")


func _on_SettingsButton_pressed() -> void:
	var settings: Window = load("res://src/2_settings/settings.tscn").instantiate()
	add_child(settings)


func _on_CreateModButton_pressed() -> void:
	get_tree().change_scene_to_file("res://src/2_creator/create_a_mod.tscn")
