extends TileMap


var PIECE_SCENE = preload("res://Piece.tscn")
var POSSIBLE_MOVE_SCENE = preload("res://PossibleMove.tscn")

var ACTIVE_PIECES = []
var CAPTURED_PIECES_WHITE = [] # black pieces that the white player has captured
var CAPTURED_PIECES_BLACK = [] # white pieces that the black player has captured

# cells currently indicating a possible move for the last selected piece.
var ACTIVE_POSSIBLE_MOVES = []
var SELECTED_PIECE


func _ready():
    
    init_game_board()


func __calc_next_position_in_capture_box() -> Vector2:
    
    if get_parent().CURRENT_TURN == get_parent().PLAYER.WHITE:
        
        return Vector2(
            cell_size[0] * (len(CAPTURED_PIECES_WHITE) % 2) + (cell_size[0] / 2),
            # warning-ignore:integer_division
            cell_size[1] * (len(CAPTURED_PIECES_WHITE) / 2) + (cell_size[1] / 2)
        ) + get_node("WhiteCaptureZone").position

    else:

        return Vector2(
            cell_size[0] * (len(CAPTURED_PIECES_BLACK) % 2) + (cell_size[0] / 2),
            # warning-ignore:integer_division
            cell_size[1] * (len(CAPTURED_PIECES_BLACK) / 2) + (cell_size[1] / 2)
        ) + get_node("BlackCaptureZone").position
    

func capture(piece) -> void:
    """Captures a piece at the specified location to the specified player's box, and removes it from
    the game board.
    
    Args:
        piece (Piece): a piece on the game board.
    """
    
    assert(piece in ACTIVE_PIECES)
    
    ACTIVE_PIECES.erase(piece)
    piece.coords = Vector2(-1, -1)
    piece.position = __calc_next_position_in_capture_box()
    
    if get_parent().CURRENT_TURN == get_parent().PLAYER.WHITE:
    
        assert(piece.is_black)
        CAPTURED_PIECES_WHITE.append(piece)
    
    else:
    
        assert(not piece.is_black)
        CAPTURED_PIECES_BLACK.append(piece)


func cell_in_bounds(cell: Vector2) -> bool:
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


func clear_possible_moves() -> void:
    """Removes the actively drawn possible moves from the game board."""
    while len(ACTIVE_POSSIBLE_MOVES) > 0:
        var pm = ACTIVE_POSSIBLE_MOVES[0]
        ACTIVE_POSSIBLE_MOVES.erase(pm)
        pm.queue_free()


func draw_possible_moves(possible_moves: Array) -> void:
    """Draws the possible moves a piece may make on the gmae board.
    
    Args:
        possible_moves (Array): of Vector2 cell locations where a piece may move.
    """
    
    for entry in possible_moves:
        
        var pm = POSSIBLE_MOVE_SCENE.instance()
        pm.coords = entry[0] # cell
        if entry[1]: # capture flag
            pm.capturable = true
        add_child(pm)
        ACTIVE_POSSIBLE_MOVES.append(pm)


func get_occupant(cell: Vector2):
    """Gets the piece in a specified cell, if one exists there.
    
    Does not consider captured pieces.
    
    Args:
        cell (Vector2): the cell's coordinates.
        
    Returns:
        Either a Piece occupying the cell or a `null` if the cell was empty.
    """
    
    for piece in ACTIVE_PIECES:
        if piece.coords == cell:
            return piece
    
    return null


func get_possible_move(cell: Vector2) -> PossibleMove:
    """Gets the piece in a specified cell, if one exists there.
    
    Does not consider captured pieces.
    
    Args:
        cell (Vector2): the cell's coordinates.
        
    Returns:
        Either a Piece occupying the cell or a `null` if the cell was empty.
    """
    for pm in ACTIVE_POSSIBLE_MOVES:
        if pm.coords == cell:
            return pm
    
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

    var pm = get_possible_move(cell)
    if pm:
        
        print("[DEBUG] Found possible move for piece ", SELECTED_PIECE.repr(), ".")
        print(">>> Moving piece ", SELECTED_PIECE.repr(), " to cell ", cell, ".")
        
        if pm.capturable:
        
            var target = get_occupant(cell)
            assert(target != null)
            assert(target.is_black == (not SELECTED_PIECE.is_black))
        
            capture(target)
        
        SELECTED_PIECE.move(cell)
        
        # reset
        SELECTED_PIECE = null
        get_parent().next_turn()
    
    else: # might be a piece
        
        var occupant = get_occupant(cell)
        if occupant:
            
            clear_possible_moves()
            
            print(
                "[DEBUG] Found piece ", occupant.repr(), " at cell ", occupant.coords, "."
            )

            if (current_turn == get_parent().PLAYER.WHITE and not occupant.is_black) or \
                    (current_turn == get_parent().PLAYER.BLACK and occupant.is_black):
                
                occupant.find_possible_moves()
                print(">>> Possible moves: ", occupant.possible_moves)
                draw_possible_moves(occupant.possible_moves)
                SELECTED_PIECE = occupant
            
            else:
                
                print(">>> Not player's turn!")
        
        else: 
            
            print("[DEBUG] Nothing there.")
            clear_possible_moves()
    

func init_game_board() -> void:
    """Initialize the game board with player pieces."""
       
    # white pawns
    for _i in range(8):
        var piece = PIECE_SCENE.instance()
        piece.coords = Vector2(_i, 6)
        add_child(piece)
        ACTIVE_PIECES.append(piece)

    # white rooks
    var piece = PIECE_SCENE.instance()
    piece.coords = Vector2(0, 7)
    piece.type = piece.TYPE.ROOK
    add_child(piece)
    ACTIVE_PIECES.append(piece)
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(7, 7)
    piece.type = piece.TYPE.ROOK
    add_child(piece)
    ACTIVE_PIECES.append(piece)

    # white knights
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(1, 7)
    piece.type = piece.TYPE.KNIGHT
    add_child(piece)
    ACTIVE_PIECES.append(piece)
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(6, 7)
    piece.type = piece.TYPE.KNIGHT
    add_child(piece)
    ACTIVE_PIECES.append(piece)

    # white bishops
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(2, 7)
    piece.type = piece.TYPE.BISHOP
    add_child(piece)
    ACTIVE_PIECES.append(piece)
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(5, 7)
    piece.type = piece.TYPE.BISHOP
    add_child(piece)
    ACTIVE_PIECES.append(piece)

    # white royals
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(3, 7)
    piece.type = piece.TYPE.KING
    add_child(piece)
    ACTIVE_PIECES.append(piece)
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(4, 7)
    piece.type = piece.TYPE.QUEEN
    add_child(piece)
    ACTIVE_PIECES.append(piece)

    # black pawns
    for _i in range(8):
        piece = PIECE_SCENE.instance()
        piece.coords = Vector2(_i, 1)
        piece.is_black = true
        add_child(piece)
        ACTIVE_PIECES.append(piece)

    # black rooks
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(0, 0)
    piece.type = piece.TYPE.ROOK
    piece.is_black = true
    add_child(piece)
    ACTIVE_PIECES.append(piece)
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(7, 0)
    piece.type = piece.TYPE.ROOK
    piece.is_black = true
    add_child(piece)
    ACTIVE_PIECES.append(piece)

    # black knights
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(1, 0)
    piece.type = piece.TYPE.KNIGHT
    piece.is_black = true
    add_child(piece)
    ACTIVE_PIECES.append(piece)
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(6, 0)
    piece.type = piece.TYPE.KNIGHT
    piece.is_black = true
    add_child(piece)
    ACTIVE_PIECES.append(piece)

    # black bishops
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(2, 0)
    piece.type = piece.TYPE.BISHOP
    piece.is_black = true
    add_child(piece)
    ACTIVE_PIECES.append(piece)
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(5, 0)
    piece.type = piece.TYPE.BISHOP
    piece.is_black = true
    add_child(piece)
    ACTIVE_PIECES.append(piece)

    # black royals
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(4, 0)
    piece.type = piece.TYPE.KING
    piece.is_black = true
    add_child(piece)
    ACTIVE_PIECES.append(piece)
    piece = PIECE_SCENE.instance()
    piece.coords = Vector2(3, 0)
    piece.type = piece.TYPE.QUEEN
    piece.is_black = true
    add_child(piece)
    ACTIVE_PIECES.append(piece)

#    # TEST
#    piece = PIECE_SCENE.instance()
#    piece.coords = Vector2(3, 2)
#    piece.is_black = true
#    add_child(piece)
#    ACTIVE_PIECES.append(piece)


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

