extends ConfirmationDialog

func _ready():
    get_ok().text = "Play Again"
    get_cancel().text = "Quit"
    get_cancel().connect("pressed", get_parent(), "_on_ButtonQuit_pressed")
