extends Button

func _ready():
	pass 

func _on_MenuButton_pressed():
	get_parent().get_node("PopupMenu").popup()
