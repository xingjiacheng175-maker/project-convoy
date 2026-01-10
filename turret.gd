extends Node2D

@export var projectile_scene: PackedScene

var targets = [] # 存储进入射程的敌人
var current_target: Node2D = null

func _ready():
	# 确保 Timer 连接了信号
	# 如果你在编辑器里没连，这里可以用代码连，或者你去编辑器检查一下
	pass

func _physics_process(delta):
	# 1. 第一步：清理无效目标 (死掉的敌人)
	# 使用 filter 过滤掉那些已经无效 (null) 的实例
	targets = targets.filter(func(t): return is_instance_valid(t))
	
	# 2. 第二步：选择目标 (选最近的，或者列表第一个)
	if targets.size() > 0:
		current_target = targets[0] # 简单起见，这就选第一个进来的
		
		# 3. 第三步：瞬间锁定 (关键修改！)
		# 不要用 lerp, move_toward，直接 look_at
		look_at(current_target.global_position)
	else:
		current_target = null

# 当敌人进入射程
func _on_range_body_entered(body):
	if body.is_in_group("enemies"):
		targets.append(body)

# 当敌人离开射程
func _on_range_body_exited(body):
	if body in targets:
		targets.erase(body)

# 计时器结束，开火！
func _on_timer_timeout():
	# 再次检查目标是否有效
	if is_instance_valid(current_target) and projectile_scene:
		
		# === 核心修复：开火瞬间强制再瞄准一次 ===
		# 这能消除子弹生成那一毫秒的视觉误差，指哪打哪
		look_at(current_target.global_position)
		
		# 生成子弹
		var p = projectile_scene.instantiate()
		
		# 设置子弹位置为炮塔当前的枪口位置
		# 建议把子弹加到 World (get_tree().root) 而不是炮塔下面，这样子弹不会跟着船动
		get_tree().current_scene.add_child(p)
		
		p.global_position = global_position
		p.global_rotation = global_rotation
