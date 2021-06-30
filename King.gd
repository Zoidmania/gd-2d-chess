extends Sprite


export var is_black: bool = false
export var coords: Vector2


func _ready():
    var tex
    if is_black:
        tex = load("res://Sprites/king_black.png")
    else:
        tex = load("res://Sprites/king_white.png")
    set_texture(tex)

    position = get_parent().cell2pos(coords)
