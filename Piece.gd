extends Sprite

class_name Piece

enum TYPE {PAWN, ROOK, BISHOP, KNIGHT, KING, QUEEN}

var is_black: bool = false
var coords: Vector2
var type = TYPE.PAWN
# will contain length-2 arrays, first element `coords`, second element `capturable`
var possible_moves: Array = []
var captured: bool = false


func _ready():
    
    set_texture(load(get_sprite_path()))
    move(coords)


func capturable(cell) -> bool:
    """Checks whether an emeny piece exists at the given cell.
    
    Args:
        cell (Vector2): the cell's coordinates.
    
    Returns:
        bool: whether a capturable piece exists at the given location.
    """
    var occupant = get_parent().get_occupant(cell)
    if occupant and occupant.is_black == (not is_black):
        return true
    else:
        return false


func find_possible_moves() -> void:
    """Determines the possible moves given the current position and player label."""

    possible_moves = [] # reset the list
    
    match type:
        
        TYPE.PAWN:
            
            # standard move
            var dir = Vector2(0, 1) if is_black else Vector2(0, -1)
            var proposed_cell = coords + dir
            if get_parent().cell_in_bounds(proposed_cell):
                var occupant = get_parent().get_occupant(proposed_cell)
                if not occupant:
                    possible_moves.append([proposed_cell, false])
            
            # longer move from starting position
            if possible_moves and (is_black and coords.y == 1) or (not is_black and coords.y == 6):
                proposed_cell = coords + (dir * 2)
                if get_parent().cell_in_bounds(proposed_cell):
                    var occupant = get_parent().get_occupant(proposed_cell)
                    if not occupant:
                        possible_moves.append([proposed_cell, false])
        
            # check if this pawn may capture another piece
            var dirs: Array
            if is_black:
                dirs = [Vector2(-1, 1), Vector2(1, 1)]
            else:
                dirs = [Vector2(-1, -1), Vector2(1, -1)]
            for _dir in dirs:
                proposed_cell = coords + _dir
                if get_parent().cell_in_bounds(proposed_cell) and capturable(proposed_cell):
                    possible_moves.append([proposed_cell, true])

        TYPE.ROOK:
            
            var dirs = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0),]
            for dir in dirs:
                var dist = 1
                while true:
                    var proposed_cell = coords + (dir * dist)
                    if get_parent().cell_in_bounds(proposed_cell):
                        var occupant = get_parent().get_occupant(proposed_cell)
                        if occupant:
                            if capturable(proposed_cell):
                                possible_moves.append([proposed_cell, true])
                            break
                            
                        else:
                            possible_moves.append([proposed_cell, false])
                    else:
                        break
                    dist += 1
        
        TYPE.BISHOP:
            
            var dirs = [Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1),]
            for dir in dirs:
                var dist = 1
                while true:
                    var proposed_cell = coords + (dir * dist)
                    if get_parent().cell_in_bounds(proposed_cell):
                        var occupant = get_parent().get_occupant(proposed_cell)
                        if occupant:
                            if capturable(proposed_cell):
                                possible_moves.append([proposed_cell, true])
                            break
                            
                        else:
                            possible_moves.append([proposed_cell, false])
                    else:
                        break
                    dist += 1
        
        TYPE.KNIGHT:
            
            var dirs = [
                Vector2(2, 1), Vector2(2, -1), Vector2(1, 2), Vector2(1, -2),
                Vector2(-2, 1), Vector2(-2, -1), Vector2(-1, 2), Vector2(-1, -2),
            ]
            for dir in dirs:
                var proposed_cell = coords + dir
                if get_parent().cell_in_bounds(proposed_cell):
                    var occupant = get_parent().get_occupant(proposed_cell)
                    if occupant:
                        if capturable(proposed_cell):
                            possible_moves.append([proposed_cell, true])
                        
                    else:
                        possible_moves.append([proposed_cell, false])
        
        TYPE.KING:
            
            var dirs = [
                Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0),
                Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1),
            ]
            for dir in dirs:
                var proposed_cell = coords + dir
                if get_parent().cell_in_bounds(proposed_cell):
                    var occupant = get_parent().get_occupant(proposed_cell)
                    if occupant:
                        if capturable(proposed_cell):
                            possible_moves.append([proposed_cell, true])
                        
                    else:
                        possible_moves.append([proposed_cell, false])
        
        TYPE.QUEEN:
            
            var dirs = [
                Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0),
                Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1),
            ]
            for dir in dirs:
                var dist = 1
                while true:
                    var proposed_cell = coords + (dir * dist)
                    if get_parent().cell_in_bounds(proposed_cell):
                        var occupant = get_parent().get_occupant(proposed_cell)
                        if occupant:
                            if capturable(proposed_cell):
                                possible_moves.append([proposed_cell, true])
                            break
                            
                        else:
                            possible_moves.append([proposed_cell, false])
                    else:
                        break
                    dist += 1


func get_sprite_path() -> String:
    """Determines which sprite this piece should use.
    
    Returns:
        String: the resource path to the sprite.
    """

    var fname = "res://Sprites/"
    
    match type:
        TYPE.PAWN:
            fname += "pawn_"
        TYPE.ROOK:
            fname += "rook_"
        TYPE.BISHOP:
            fname += "bishop_"
        TYPE.KNIGHT:
            fname += "knight_"
        TYPE.KING:
            fname += "king_"
        TYPE.QUEEN:
            fname += "queen_"
    
    if is_black:
        fname += "black"
    else:
        fname += "white"
    
    fname += ".png"
            
    return fname


func move(cell: Vector2) -> void:
    """Move this Piece to the specified location.
    
    Args:
        cell (Vector2): the cell's coordinates.
    """
    
    assert(get_parent().cell_in_bounds(cell))
        
    coords = cell
    # sets a pixel location relative to the parent
    position = get_parent().cell2pos(coords)
    
    if type == TYPE.PAWN:
        if is_black and cell.y == 7:
            promote()
        elif not is_black and cell.y == 0:
            promote()


func promote() -> void:
    # TO DO
    pass


func repr() -> String:
    
    var pretty_name = "Black " if is_black else "White "
    
    match type:
        TYPE.PAWN:
            pretty_name += "Pawn"
        TYPE.ROOK:
            pretty_name += "Rook"
        TYPE.BISHOP:
            pretty_name += "Bishop"
        TYPE.KNIGHT:
            pretty_name += "Knight"
        TYPE.KING:
            pretty_name += "King"
        TYPE.QUEEN:
            pretty_name += "Queen"
    
    return pretty_name
