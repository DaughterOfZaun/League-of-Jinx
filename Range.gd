extends Area3D

@export var enabled := true
@onready var char := get_parent() as Unit

func _ready():
    monitoring = false
    monitorable = false
    input_ray_pickable = false
    if !enabled: return
    
    match name:
        'GameplayRange':
            monitorable = true
        'SelectionRange':
            input_ray_pickable = true
        'AcquisitionRange', 'AttackRange', 'CancelAttackRange':
            monitoring = true
    
    monitoring = true
    monitorable = true
    
    var team_mask := 1 << char.team
    collision_mask = ~(team_mask | 1) if monitoring else 0
    collision_layer = team_mask if monitorable else 0
    if input_ray_pickable and collision_layer == 0:
        collision_layer = 1

@onready var input_manager := get_node("%InputManager") as InputManager;
func _input_event(camera, event, position, normal, shape_idx):
    if event is InputEventMouseButton and event.pressed:
        input_manager.on_unit_clicked(char, event.button_index)
    elif event is InputEventMouseMotion:
        input_manager.on_unit_hovered(char)
