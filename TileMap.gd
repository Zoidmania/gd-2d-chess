extends TileMap


# Preload the scenes for the pieces
var PAWN_SCENE = preload("res://Pawn.tscn")
var ROOK_SCENE = preload("res://Rook.tscn")
var KNIGHT_SCENE = preload("res://Knight.tscn")
var BISHOP_SCENE = preload("res://Bishop.tscn")
var KING_SCENE = preload("res://King.tscn")
var QUEEN_SCENE = preload("res://Queen.tscn")

var ACTIVE_PIECES = []
var CAPTURED_PIECES_WHITE = [] # black pieces that the white player has captured
var CAPTURE_PIECES_BLACK = [] # white pieces that the black player has captured


func _ready():
    
    init_game_board()


func cell_in_bounds(cell) -> bool:
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


func cell2pos(cell: Vector2) -> Vector2:
    """Converts cell coordinates to a position in 2D space, relative to the TileMap.
    
    The position refers to the center pixel of the cell.
    
    Args:
        cell (Vector2): the cell's coordinates.
    
    Returns:
        Vector2: the position of the cell in 2D space.
    """
    
    assert(cell_size[0] == cell_size[1]) # make sure cells are still square
    
    if cell[0] < 0 or cell[1] < 0 or cell[0] > 7 or cell[1] > 7:
        push_error("Cell coords out of bounds: " + str(cell))
    
    var pos = Vector2(
        (cell[0] * cell_size[0]) + (cell_size[0] / 2),
        (cell[1] * cell_size[1]) + (cell_size[1] / 2)
    )
    
    return pos


func draw_possible_moves(possible_moves: Array) -> void:
    """Draws the possible moves a piece may make on the gmae board.
    
    Args:
        possible_moves (Array): of Vector2 cell locations where a piece may move.
    """
    
    for cell in possible_moves:
        pass


func get_occupant(cell: Vector2):
    """Gets the piece in a specified cell, if one exists there.
    
    Does not consider captured pieces.
    
    Args:
        cell (Vector2): the cell's coordinates.
        
    Returns:
        Either one of the Piece types (Pawn, Rook, Knight, Bishop, King, or Queen) or a `null` if
        the cell was empty.
    """
    
    for piece in ACTIVE_PIECES:
        if piece.coords == cell:
            return piece
    
    return null


func handle_selection(cell: Vector2, current_turn: int) -> void:
    """Handles cell selections on the game board, if anything is applicable.
    
    - If a cell is unoccupied, do nothing.
    - If a cell is occupied by one of the current player turn's pieces, enter show-possible-moves
      state.
    - If in show-possible-moves state:
        - If the selected cell is one of the possible moves, move the related piece to the selected
          cell, and capture an enemy piece or promote the moved piece if necessary.
        - Otherwise, if in show-possible-moves state and the selected cell is not one of the
          possible moves:
            - If the selected cell is another one of the current player turn's pieces, enter
              show-possible-moves state for that piece.
            - Otherwise, exit show-possible-moves state.
    
    Args:
        cell (Vector2): the cell's coordinates.
        current_turn (int): the player ID for the current turn, based on the `Main.PLAYER` enum.
    """
    
    var piece = get_occupant(cell)
    if piece:
        
        print(
            "[DEBUG] Found ", "Black " if piece.is_black else "White ",
            piece.get_name(), " at cell ", cell, "."
        )
    
        var possible_moves = []        
        
        if (current_turn == get_parent().PLAYER.WHITE and not piece.is_black) or \
            (current_turn == get_parent().PLAYER.BLACK and piece.is_black):
            
            possible_moves = piece.get_possible_moves(cell)
        
        print("[DEBUG] Possible moves: ", possible_moves)
        draw_possible_moves(possible_moves)
    
    else:
        
        print("[DEBUG] Nothing there.")
    

func init_game_board() -> void:
    """Initialize the game board with player pieces."""
       
    # white pawns
    for _i in range(8):
        var pawn = PAWN_SCENE.instance()
        pawn.coords = Vector2(_i, 6)
        add_child(pawn)
        ACTIVE_PIECES.append(pawn)

    # white rooks
    var rook = ROOK_SCENE.instance()
    rook.coords = Vector2(0, 7)
    add_child(rook)
    ACTIVE_PIECES.append(rook)
    rook = ROOK_SCENE.instance()
    rook.coords = Vector2(7, 7)
    add_child(rook)
    ACTIVE_PIECES.append(rook)

    # white knights
    var knight = KNIGHT_SCENE.instance()
    knight.coords = Vector2(1, 7)
    add_child(knight)
    ACTIVE_PIECES.append(knight)
    knight = KNIGHT_SCENE.instance()
    knight.coords = Vector2(6, 7)
    add_child(knight)
    ACTIVE_PIECES.append(knight)

    # white bishops
    var bishop = BISHOP_SCENE.instance()
    bishop.coords = Vector2(2, 7)
    add_child(bishop)
    ACTIVE_PIECES.append(bishop)
    bishop = BISHOP_SCENE.instance()
    bishop.coords = Vector2(5, 7)
    add_child(bishop)
    ACTIVE_PIECES.append(bishop)
    
    # white royals
    var king = KING_SCENE.instance()
    king.coords = Vector2(3, 7)
    add_child(king)
    ACTIVE_PIECES.append(king)
    var queen = QUEEN_SCENE.instance()
    queen.coords = Vector2(4, 7)
    add_child(queen)
    ACTIVE_PIECES.append(queen)
    
    # black pawns
    for _i in range(8):
        var pawn = PAWN_SCENE.instance()
        pawn.coords = Vector2(_i, 1)
        pawn.is_black = true
        add_child(pawn)
        ACTIVE_PIECES.append(pawn)
    
    # black rooks
    rook = ROOK_SCENE.instance()
    rook.coords = Vector2(0, 0)
    rook.is_black = true
    add_child(rook)
    ACTIVE_PIECES.append(rook)
    rook = ROOK_SCENE.instance()
    rook.coords = Vector2(7, 0)
    rook.is_black = true
    add_child(rook)
    ACTIVE_PIECES.append(rook)
    
    # black knights
    knight = KNIGHT_SCENE.instance()
    knight.coords = Vector2(1, 0)
    knight.is_black = true
    add_child(knight)
    ACTIVE_PIECES.append(knight)
    knight = KNIGHT_SCENE.instance()
    knight.coords = Vector2(6, 0)
    knight.is_black = true
    add_child(knight)
    ACTIVE_PIECES.append(knight)
    
    # black bishops
    bishop = BISHOP_SCENE.instance()
    bishop.coords = Vector2(2, 0)
    bishop.is_black = true
    add_child(bishop)
    ACTIVE_PIECES.append(bishop)
    bishop = BISHOP_SCENE.instance()
    bishop.coords = Vector2(5, 0)
    bishop.is_black = true
    add_child(bishop)
    ACTIVE_PIECES.append(bishop)
    
    # black royals
    king = KING_SCENE.instance()
    king.coords = Vector2(4, 0)
    king.is_black = true
    add_child(king)
    ACTIVE_PIECES.append(king)
    queen = QUEEN_SCENE.instance()
    queen.coords = Vector2(3, 0)
    queen.is_black = true
    add_child(queen)
    ACTIVE_PIECES.append(queen)


func pos2cell(position: Vector2) -> Vector2:
    """Converts a position from a mouse event into cell coordinates.

    Args:
        position (Vector2): the mouse event's position.

    Returns:
        Vector2: the coordinates of the cell the event occurred within.
    """

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

