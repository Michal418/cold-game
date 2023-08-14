extends CharacterBody2D

signal died

enum CARRY_ITEMS { NONE, FUEL, BLOCK }

var internal_temperature = GridBlock.new(30.0, 0.45, GridBlock.STATE.SOLID)

var external_temperature = 0.0
var alive = true
var carying = CARRY_ITEMS.NONE

const Wood = preload("res://wood.gd")
const Block = preload("res://block.gd")

@onready var wood = $Wood as Wood
@onready var wood_collision_shape = $Wood/Area2D/CollisionShape2D as CollisionShape2D
@onready var block_collision_shape = $Block/StaticBody2D/CollisionShape2D as CollisionShape2D
@onready var cary_block = $Block as Block

const FREEZING_TEMPERATURE = 8.0
const COMFORTABLE_TEMPERATURE = 22.0
const REACH = 32 * 8

var put_wood = func (_pos: Vector2):
  push_error("`put_wood` function must be set")
var put_block = func (_pos: Vector2):
  push_error("put_block` function must be set")

func freeing_progress():
  var result = (internal_temperature.celsius - FREEZING_TEMPERATURE) \
         / (COMFORTABLE_TEMPERATURE - FREEZING_TEMPERATURE)
  result = clampf(result, 0.0, 1.0)
  result = pow(result, 2.0 / 3.0)
  return result

func _die():
  set_process(false)
  set_physics_process(false)
  alive = false
  died.emit()

func temperature_interaction(updated_block: GridBlock, grid_block: GridBlock):
  internal_temperature.celsius = updated_block.celsius
  external_temperature = grid_block.celsius

  if internal_temperature.celsius < FREEZING_TEMPERATURE:
    _die()

func gain_block():
  carying = CARRY_ITEMS.BLOCK
  cary_block.visible = true

func lose_block():
  carying = CARRY_ITEMS.NONE
  cary_block.visible = false

func lose_fuel():
  carying = CARRY_ITEMS.NONE
  wood.visible = false

func gain_fuel():
  carying = CARRY_ITEMS.FUEL
  wood.visible = true


func _input(event):
  if event is InputEventMouseButton and event.pressed:
    var mouse_position = get_global_mouse_position()

    if mouse_position.distance_to(position) < REACH:
      if carying == CARRY_ITEMS.FUEL:
        put_wood.call(mouse_position)

      elif carying == CARRY_ITEMS.BLOCK:
        put_block.call(mouse_position)

func _physics_process(delta):
  const K = 2400.0
  const MAX_SPEED = 180
  var speed = 2 # if Input.is_action_pressed("run") else 1

  speed *= 0.5 * freeing_progress()

  if carying == CARRY_ITEMS.BLOCK:
    speed *= 0.5

  var dv = Vector2(0, 0)

  if Input.is_action_pressed("move_left") and velocity.x >= -MAX_SPEED * speed:
    dv += Vector2.LEFT * speed * delta * K
  if Input.is_action_pressed("move_right") and velocity.x <= MAX_SPEED * speed:
    dv += Vector2.RIGHT * speed * delta * K
  if Input.is_action_pressed("move_up") and velocity.y >= -MAX_SPEED * speed:
    dv += Vector2.UP * speed * delta * K
  if Input.is_action_pressed("move_down") and velocity.y <= MAX_SPEED * speed:
    dv += Vector2.DOWN * speed * delta * K

  if dv.length() == 0.0:
    velocity -= velocity * delta * 8
  else:
    velocity += dv

  move_and_slide()

