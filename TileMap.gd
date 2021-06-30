extends TileMap


# Preload the scenes for the pieces
var pawn_scene = preload("res://Pawn.tscn")
var rook_scene = preload("res://Rook.tscn")
var knight_scene = preload("res://Knight.tscn")
var bishop_scene = preload("res://Bishop.tscn")
var king_scene = preload("res://King.tscn")
var queen_scene = preload("res://Queen.tscn")

var active_pieces = []
var white_captured_pieces = [] # black pieces that the white player has captured
var black_captured_pieces = [] # white pieces that the black player has captured

func _ready():
    """Init game board."""
       
    # white pawns
    for _i in range(8):
        var pawn = pawn_scene.instance()
        pawn.coords = Vector2(_i, 6)
        add_child(pawn)
        active_pieces.append(pawn)

    # white rooks
    var rook = rook_scene.instance()
    rook.coords = Vector2(0, 7)
    add_child(rook)
    active_pieces.append(rook)
    rook = rook_scene.instance()
    rook.coords = Vector2(7, 7)
    add_child(rook)
    active_pieces.append(rook)

    # white knights
    var knight = knight_scene.instance()
    knight.coords = Vector2(1, 7)
    add_child(knight)
    active_pieces.append(knight)
    knight = knight_scene.instance()
    knight.coords = Vector2(6, 7)
    add_child(knight)
    active_pieces.append(knight)

    # white bishops
    var bishop = bishop_scene.instance()
    bishop.coords = Vector2(2, 7)
    add_child(bishop)
    active_pieces.append(bishop)
    bishop = bishop_scene.instance()
    bishop.coords = Vector2(5, 7)
    add_child(bishop)
    active_pieces.append(bishop)
    
    # white royals
    var king = king_scene.instance()
    king.coords = Vector2(3, 7)
    add_child(king)
    active_pieces.append(king)
    var queen = queen_scene.instance()
    queen.coords = Vector2(4, 7)
    add_child(queen)
    active_pieces.append(queen)
    
    # black pawns
    for _i in range(8):
        var pawn = pawn_scene.instance()
        pawn.coords = Vector2(_i, 1)
        pawn.is_black = true
        add_child(pawn)
        active_pieces.append(pawn)
    
    # black rooks
    rook = rook_scene.instance()
    rook.coords = Vector2(0, 0)
    rook.is_black = true
    add_child(rook)
    active_pieces.append(rook)
    rook = rook_scene.instance()
    rook.coords = Vector2(7, 0)
    rook.is_black = true
    add_child(rook)
    active_pieces.append(rook)
    
    # black knights
    knight = knight_scene.instance()
    knight.coords = Vector2(1, 0)
    knight.is_black = true
    add_child(knight)
    active_pieces.append(knight)
    knight = knight_scene.instance()
    knight.coords = Vector2(6, 0)
    knight.is_black = true
    add_child(knight)
    active_pieces.append(knight)
    
    # black bishops
    bishop = bishop_scene.instance()
    bishop.coords = Vector2(2, 0)
    bishop.is_black = true
    add_child(bishop)
    active_pieces.append(bishop)
    bishop = bishop_scene.instance()
    bishop.coords = Vector2(5, 0)
    bishop.is_black = true
    add_child(bishop)
    active_pieces.append(bishop)
    
    # black royals
    king = king_scene.instance()
    king.coords = Vector2(4, 0)
    king.is_black = true
    add_child(king)
    active_pieces.append(king)
    queen = queen_scene.instance()
    queen.coords = Vector2(3, 0)
    queen.is_black = true
    add_child(queen)
    active_pieces.append(queen)


func cell_in_bounds(cell):
    """Checks whether a cell is within bounds.
    
    A standard chess board is 8x8.
    
    Args:
        cell (Vector2): the cell's coordinates.
    
    Returns:
        bool: whether the cell coords are within bounds.
    """

    if cell[0] < 0 or cell[0] > 7:
        return false
    elif cell[1] < 0 or cell[1] > 7:
        return false
    else:
        return true


func cell2pos(cell):
    """Converts cell coordinates to a position in 2D space, relative to the TileMap.
    
    The position refers to the center pixel of the cell.
    
    Args:
        cell (Vector2): the cell's coordinates.
    
    Returns:
        Vector2: the position of the cell in 2D space.
    """
    
    assert(cell is Vector2)
    
    assert(cell_size[0] == cell_size[1]) # make sure cells are still square
    
    if cell[0] < 0 or cell[1] < 0 or cell[0] > 7 or cell[1] > 7:
        push_error("Cell coords out of bounds: " + str(cell))
    
    var pos = Vector2(
        (cell[0] * cell_size[0]) + (cell_size[0] / 2),
        (cell[1] * cell_size[1]) + (cell_size[1] / 2)
    )
    
    return pos


func get_occupant(cell):
    """Gets the piece in a specified cell, if one exists there.
    
    Does not consider captured pieces.
    
    Args:
        cell (Vector2): the cell's coordinates.
        
    Returns:
        Either one of the Piece types (Pawn, Rook, Knight, Bishop, King, or Queen) or a `null` if
        the cell was empty.
    """
    
    for piece in active_pieces:
        if piece.coords == cell:
            return piece
    
    return null


func pos2cell(position):
    """Converts a position from a mouse event into cell coordinates.

    Args:
        position (Vector2): the mouse event's position.

    Returns:
        Vector2: the coordinates of the cell the event occurred within.
    """

    assert(position is Vector2)
    
    assert(cell_size[0] == cell_size[1]) # make sure cells are still square
    
    var cell = Vector2(
        int((position.x) / cell_size[0]),
        int((position.y) / cell_size[1])
    )
    
    if position.x < 0:
        cell[0] = -1
    elif position.x > cell_size[0] * 8:
        cell[0] = 8
    if position.y < 0:
        cell[1] -= 1
    elif position.y > cell_size[1] * 8:
        cell[1] = 8
        
    return cell

