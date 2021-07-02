extends Sprite

class_name PossibleMove

export var capturable: bool = false
export var coords: Vector2
const is_piece = false

func _ready():
    
    var tex
    if capturable:
        tex = load("res://Sprites/cell_legal_move_capture.png")
    else:
        tex = load("res://Sprites/cell_legal_move.png")
    set_texture(tex)
    
    modulate.a = 0.5 # opacity
    position = get_parent().cell2pos(coords)

