extends Node2D


func _ready():
    """Initialization entrypoint."""

    print("Cell size: ", get_node("TileMap").cell_size)
    print("Grid offset: ", get_node("TileMap").transform.origin)


func _input(event):
    """Catch-all function for handling or routing Events.

    Args:
        event (InputEvent): any InputEvent (or its descendants).
    """

    # handle mouse clicks when in edit mode
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        
        print("[DEBUG] Got mouse click at ", event.position, ".")
        
        var relative_pos = event.position - get_node("TileMap").transform.origin
        var cell = get_node("TileMap").pos2cell(relative_pos)
        print(">>> Cell: ", cell)
        print(">>> ", "Is" if get_node("TileMap").cell_in_bounds(cell) else "Isn't", " in bounds.")
