extends Node2D


enum PLAYER {WHITE, BLACK}
var CURRENT_TURN: int
var PAUSED = false
var rng = RandomNumberGenerator.new()


func _ready():
    """Initialization entrypoint."""

    rng.randomize()

    # show pause menu on init
    toggle_pause()

    print("[DEBUG] Cell size: ", get_node("TileMap").cell_size)
    print("[DEBUG] Grid offset: ", get_node("TileMap").transform.origin)
    
    
func _input(event):
    """Catch-all function for handling or routing Events.

    Args:
        event (InputEvent): any InputEvent (or its descendants).
    """

    # toggle pause menu on pressing escape key
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_ESCAPE:
            toggle_pause()

    # handle mouse clicks
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        
        print("[DEBUG] Got mouse click at ", event.position, ".")
        
        if PAUSED:
        
            print("[DEBUG] Game is paused!")
        
        else:
            
            var game_board = get_node("TileMap")
            
            var relative_pos = event.position - game_board.transform.origin
            var cell = game_board.pos2cell(relative_pos)
            var in_bounds = game_board.cell_in_bounds(cell)
            if in_bounds:
                print(">>> Cell: ", cell)
                game_board.handle_selection(cell, CURRENT_TURN)
            else:
                print(">>> Isn't in bounds.")
                game_board.clear_possible_moves()


func coin_toss() -> void:
    """Sets the first player's turn."""

    if rng.randi_range(0, 1) == PLAYER.WHITE:
        CURRENT_TURN = PLAYER.WHITE
    else:
        CURRENT_TURN = PLAYER.BLACK
        
    next_turn()
    

func next_turn() -> void:
    """Move on to the next turn."""
    
    if CURRENT_TURN == PLAYER.WHITE:
        CURRENT_TURN = PLAYER.BLACK
    elif CURRENT_TURN == PLAYER.BLACK:
        CURRENT_TURN = PLAYER.WHITE

    get_node("TurnIndicatorLabel").text = "Current Turn: " + \
        ("Black" if CURRENT_TURN == PLAYER.BLACK else "White")

    print("[DEBUG] Player turn is now ", CURRENT_TURN)

    get_node("TileMap").clear_possible_moves()


func toggle_pause() -> void:
    if PAUSED:
        get_node("MenuPanel").hide()
        PAUSED = false
    else:
        get_node("MenuPanel").show()
        PAUSED = true
    print("[DEBUG] Game paused: ", PAUSED)


func _on_ButtonReset_pressed():
    self.get_node("TileMap").empty_gameboard()


func _on_ButtonStart_pressed():
    
    toggle_pause()
    coin_toss()
    get_node("TileMap").init_game_board()
    
    
func _on_ButtonQuit_pressed():
    """Gracefully quit the game."""
    get_tree().quit()
