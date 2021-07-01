extends Node2D


enum PLAYER {WHITE, BLACK}
var CURRENT_TURN: int
var PAUSED = true


func _ready():
    """Initialization entrypoint."""

    print("[DEBUG] Cell size: ", get_node("TileMap").cell_size)
    print("[DEBUG] Grid offset: ", get_node("TileMap").transform.origin)
    
    # for now, just start with black. implement a coin toss later.
    CURRENT_TURN = PLAYER.BLACK
    print("[DEBUG] First player turn: ", CURRENT_TURN)
    
    # for now, just start the game immediately. implement a start/pause later.
    PAUSED = false
    print("[DEBUG] Game paused: ", PAUSED)


func _input(event):
    """Catch-all function for handling or routing Events.

    Args:
        event (InputEvent): any InputEvent (or its descendants).
    """

    # handle mouse clicks
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        
        print("[DEBUG] Got mouse click at ", event.position, ".")
        
        var game_board = get_node("TileMap")
        
        var relative_pos = event.position - game_board.transform.origin
        var cell = game_board.pos2cell(relative_pos)
        print(">>> Cell: ", cell)
        var in_bounds = game_board.cell_in_bounds(cell)
        print(">>> ", "Is" if in_bounds else "Isn't", " in bounds.")
        
        if in_bounds:
            game_board.handle_selection(cell, CURRENT_TURN)
    

func next_turn() -> void:
    """Move on to the next turn."""
    
    if CURRENT_TURN == PLAYER.WHITE:
        CURRENT_TURN = PLAYER.BLACK
    elif CURRENT_TURN == PLAYER.BLACK:
        CURRENT_TURN = PLAYER.WHITE

    print("[DEBUG] Player turn is now ", CURRENT_TURN)
