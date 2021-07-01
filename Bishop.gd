extends Sprite


export var is_black: bool = false
export var coords: Vector2


func _ready():
    var tex
    if is_black:
        tex = load("res://Sprites/bishop_black.png")
    else:
        tex = load("res://Sprites/bishop_white.png")
    set_texture(tex)

    position = get_parent().cell2pos(coords)


func get_possible_moves(cell: Vector2) -> Array:
    """Determines the possible moves given the current position and player label.
    
    Args:
        cell (Vector2): the cell's coordinates for this piece.
       
    Returns:
        Array: a list of Vector2 cell locations where the piece may move.
    """

    var possible_moves = []
    
    return possible_moves
