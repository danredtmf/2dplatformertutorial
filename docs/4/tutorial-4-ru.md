# 2D Платформер

> Часть четвёртая

## Содержание

- [1. Создание базового врага](#1-создание-базового-врага)
- [2. Создание врага](#2-создание-врага)
- [3. Монета вредит врагам](#3-монета-вредит-врагам)
- [4. Задания](#4-задания)

## 1. Создание базового врага

Создаём новую сцену типа `KinematicBody2D` и называем его `EnemyBase`.

Во вкладке `Collision` в группе `Layer` выберем слой `4` (`Enemy`) и выключим слой `1` (`World`). Группу `Mask` оставим без изменений.

Создаём следующую структуру внутри объекта:

- `Collision` (тип `CollisionShape2D`; не обращаем внимания на предупреждения в иерархии, оставляем без изменений)
- `Animation` (тип `AnimatedSprite2D`; оставляем без изменений)
- `AnimationPlayer` (рассмотрим чуть ниже)
- `ChaseZone` (тип `Area2D`; рассмотрим чуть ниже)

У узла `AnimationPlayer` создаём анимацию `death`. Длительность анимации - `1` секунда (иконка секундомера в левой части панели `Animation`). Во время активной нижней панели `Animation` нажмите на узел `Animation` и зафиксируйте (нажмите на иконку ключа возле свойства) значения свойства `Scale` во вкладке `Transform` и свойства `Modulate` во вкладке `Visibility` с разрешением создать анимацию `RESET`. Время двух только что созданных ключей анимации должен быть равен `0`.

Перетащите каретку на анимационной дорожке в значение времени `1` и создайте по одному ключу анимации на каждой из двух дорожек (ПКМ ➡️ `Insert Key...` или снова нажмите на иконку ключа у нужного свойства). Значение второго ключа анимации на анимационной дорожке `scale` равен `(x: 1, y: 0)`. Значение второго ключа анимации на анимационной дорожке `modulate` равен `000000` (чёрный цвет).

У узла `ChaseZone`, во вкладке `Collision` в группе `Layer` выключим слой `1` (`World`). В группе `Mask` включим слой `2` (`Player`) и выключим слой `1` (`World`).

Сохраните сцену в папке `objects` ➡️ `enemy` ➡️ `base` с названием файла `enemy_base.tscn`.

Создадим код для `EnemyBase`:

```gdscript
class_name EnemyBase
extends CharacterBody2D

enum States { IDLE, CHASE, DIE }

var state: States = States.IDLE:
	set(value):
		state = value
		_check_state()
	get:
		return state

@export var health: int
@export var speed: float
@export var has_gravity: bool

var _chase_run: bool
var _player: Player

@onready var _animation: AnimatedSprite2D = $Animation
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	state = States.IDLE

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("Player") as Player
	
	if has_gravity and not is_on_floor():
		velocity += get_gravity() * delta
	
	if _chase_run:
		var player_direction := \
		global_position.direction_to(_player.global_position)
		
		velocity += player_direction.normalized() * speed * delta
	
	# Отражение анимации по горизонтали
	if velocity.x < 0.0:
		_animation.flip_h = true
	else:
		_animation.flip_h = false
	
	move_and_slide()

func hit() -> void:
	health -= 1
	
	if health < 1:
		state = States.DIE

func _check_state() -> void:
	match state:
		States.IDLE:
			_chase_run = false
		States.CHASE:
			_chase_run = true
		States.DIE:
			_die()

func _play_death_animation() -> void:
	if not _animation_player.is_playing():
		_animation_player.play("death")

# Пригодится позже, нужно написать
func _die() -> void:
	pass

# Присоединить сигнал `body_entered`
# От объекта `ChaseZone`
# К родительскому объекту (`EnemyBase`)
func _on_chase_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		state = States.CHASE
```

> Данный объект создан в качестве примера и может иметь ограниченное количество применений 🥲.

## 2. Создание врага

Теперь создадим самого врага. Создаём новую сцену и после нажатия на иконку цепочки в иерархии находим и выбираем сцену `enemy_base.tscn`. Называем родительский узел `FloatingEnemy`.

> Рядом с PDF документом должен быть новый ресурс по пути `resources/sprites/enemy-red-light.png`.

Что изменилось?

- Родительский узел `FloatingEnemy`: укажите в свойствах `Health` и `Speed` значения `1` и `100` соответственно
- Узел `Collision`: в свойстве `Shape` создайте `RectangleShape2D` с размером `(x: 64, y: 64)`
- Узел `Animation`: вспомните, как создавать анимацию спрайтов, импортируйте все кадры анимации из файла `enemy-red-light.png` в анимацию `default`
- Узел `ChaseZone`: создайте дочерний узел типа `CollisionShape2D` и в свойстве `Shape` создайте `RectangleShape2D` с размером `(x: 256, y: 64)`

Сохраните сцену в папке `objects` ➡️ `enemy` ➡️ `floating` с названием файла `floating_enemy.tscn`.

Нажмите ПКМ на родительский узел `FloatingEnemy` и выберите `Extend Script...` (расширить скрипт).

Создадим код для `FloatingEnemy`:

```gdscript
class_name FloatingEnemy
extends EnemyBase

func _ready() -> void:
	super._ready()
	_animation.play("default")

func _die() -> void:
	_play_death_animation()
	await _animation_player.animation_finished
	
	queue_free()
```

Добавим одного или несколько врагов на уровень.

## 3. Монета вредит врагам

Зайдём на сцену `Coin` и рассмотрим некоторые изменения.

В прошлый раз мы включали `Contact Monitor` во вкладке `Solver` и указали значение `10` в свойстве `Max Contacts Reported`. Теперь нам это не понадобиться и можно сбросить их значения, нажав иконку сброса рядом со свойством. Если раньше мы подготавливались использовать сигнал `body_entered` у `Coin`, то сейчас данный сигнал будет не нужен и его можно отвязать.

Также у родительского узла `Coin` во вкладке `Collision` в группе `Mask` выключим слой `4` (`Enemy`), а слой `1` (`World`) оставим. Теперь монета будет останавливаться только от какой-либо поверхности слоя `1` (`World`), а врагов будет игнорировать.

Теперь, чтобы монета могла наносить урон врагам, у узла `Coin` нужно создать новый дочерний узел типа `ShapeCast2D` и изменить у неё следующие свойства:

- `Shape`: создать `RectangleShape2D` с размером `(x: 64, y: 64)`
- `Target Position`: `(x: 0, y: 0)`
- `Max Results`: `5`
- `Collision Mask`: выключить слой `1` (`World`) и включить слой `4` (`Enemy`)

Код `Coin`:

> Новые строчки кода будут помечаться комментарием `#!`, отредактированные строчки - `#?`

```gdscript
class_name Coin
extends RigidBody2D

var _last_object: EnemyBase #! Новая переменная

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _interactive_area: InteractiveArea = $InteractiveArea
@onready var _shape_cast_2d: ShapeCast2D = $ShapeCast2D #! Новая переменная

func _ready() -> void:
	_animation_player.play("show")
	gravity_scale = 0.0

#! Добавить функцию
func _physics_process(_delta: float) -> void:
	if _shape_cast_2d.is_colliding():
		var object := _shape_cast_2d.get_collider(0)
		if object is EnemyBase:
			if object != _last_object:
				_last_object = object
				
				_last_object.hit()
				can_sleep = false
				await _last_object.tree_exited
				can_sleep = true

func get_interactive() -> InteractiveArea:
	return _interactive_area

# Присоединить сигнал `tree_exited`
# От объекта `InteractiveArea`
# К родительскому объекту (`Coin`)
func _on_interactive_area_tree_exited() -> void:
	queue_free()

# Присоединить сигнал `animation_finished`
# От объекта `AnimationPlayer`
# К родительскому объекту (`Coin`)
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "show":
		gravity_scale = 1.0

#? Удалить функцию `_on_body_entered`
```

Попробуем на уровне подобрать монету и через режим расположения монеты (нажать на `Q`) расположить монету в мире так, чтобы она точно коснулась врага. Враг должен погибнуть.

## 4. Задания

1. Напишите функцию `_draw` (предустановленная) у узла `EnemyBase`, которая будет делать следующее:

- **Получать дочерние узлы `ChaseZone`**:
   - Используйте метод `get_children()` для получения всех дочерних узлов `ChaseZone`. Чтобы обратиться к узлу в коде нужно написать `$ChaseZone`.
- **Проверять наличие дочерних узлов**:
   - Убедитесь, что количество дочерних узлов больше нуля, чтобы продолжить выполнение.
- **Перебирать дочерние узлы**:
   - Пройдитесь циклом `for` по каждому дочернему узлу, который является экземпляром `CollisionShape2D`.
- **Получать прямоугольник (Rect2D) из свойства `Shape` узла `CollisionShape2D`**:
   - Используйте метод `get_rect()` из свойства `shape` узла `CollisionShape2D` для получения прямоугольника.
- **Задавать цвет**:
   - Установите цвет для рисования, например, `Color.ORANGE_RED`.
- **Устанавливать прозрачность**:
   - Установите альфа-канал (прозрачность) у цвета, например, `0.15` через свойство `a`.
- **Рисовать прямоугольник**:
   - Используйте метод `draw_rect()` для рисования прямоугольника (параметр функции `rect`) с заданными параметрами, такими как цвет (параметр функции `color`) и толщина линии (параметр функции `width`).

В результате, вы должны видеть, что враг находится внутри нарисованной рамки.

2. Сделайте так, чтобы враги не погибали, когда монета просто находится в игровом мире, а не падает и не играет анимации `show`. Редактируйте сцену `Coin`.

- **Добавьте новую переменную `_can_hit`:**
- **Обновите функцию `_physics_process`:**
   - Добавьте условие, которое будет устанавливать значение `_can_hit` в `true`, если анимация монеты играет или монета не спит (свойство `sleeping`).
   - Установить `_can_hit` в `false`, если анимация не играет и монета спит.
- **Дополните условие проверки столкновения:**
   - Добавьте дополнительное условие `and _can_hit` в проверку столкновения, чтобы монета могла нанести урон только тогда, когда `_can_hit` равно `true`.

В результате, монета будет поражать врагов только во время проигрывания своей анимации или когда физика монеты не "спит".