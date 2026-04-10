extends Node

var 动画:bool = false
var 目前状态
@onready var 抽取结果栏:HFlowContainer=$"Panel/抽取结果"
@onready var 摄像机:Camera2D=$"摄像机"
@onready var 名字:Array=素材.名字
@onready var 抽取次数:Dictionary=素材.抽取次数

func _ready() -> void:
	for i in 名字:
		抽取次数[i]=0

func 启用动画():
	if 动画:
		动画=0
	else:
		动画=1

func 抽取(a:int):
	目前状态="抽取中"
	var 抽取结果:Array=[]
	for i in range(a):
		var 人=名字[randi()%名字.size()]
		while 人 in 抽取结果:
			人=名字[randi()%名字.size()]
		抽取结果.append(人)
		if 动画:
			var 场景=load("res://立绘.tscn").instantiate()
			场景.名字=人
			$"启用动画".add_child(场景)
		if $"启用动画".get_child_count()>0:
			await $"启用动画".get_child(0).结束立绘
		await get_tree().create_timer(0.01).timeout
		
	抽取结果.sort_custom(func(a,b):return 抽取次数[a]<抽取次数[b])
	#print(抽取结果)
	
	for i in range(a):
		var 场景=load("res://卡牌.tscn").instantiate()
		场景.idx=抽取结果[i]
		场景.cnt=抽取次数[抽取结果[i]]
		抽取结果栏.add_child(场景)
		抽取次数[抽取结果[i]]+=1
	目前状态="待机"

func 自定义抽取(a:int) -> void:
	if 目前状态=="抽取中":
		return
	清空()
	抽取(a)

func 清空() -> void:
	if 抽取结果栏==null or 抽取结果栏.get_child_count()<=0:
		return
	for 孩子 in 抽取结果栏.get_children():
		孩子.queue_free()

func _on_抽取一次_pressed() -> void:
	if 目前状态=="抽取中":
		return
	清空()
	抽取(1)

func _on_抽取十次_pressed() -> void:
	if 目前状态=="抽取中":
		return
	清空()
	抽取(10)

func _on_抽取详情_pressed() -> void:
	var 显示:String=""
	for i in 名字:
		显示+=i+" : "+String.num_int64(抽取次数[i])+" 次\n"
	$"Panel2/详情".text=显示
	摄像机.global_position.y+=648

func _on_返回_pressed() -> void:
	摄像机.global_position.y-=648

func _on_启用动画_pressed() -> void:
	启用动画()


func _on_自定义抽取_pressed() -> void:
	var 场景=load("res://自定义抽取.tscn").instantiate()
	add_child(场景)
	await 素材.自定义抽取信号
	if 目前状态=="抽取中":
		return
	清空()
	抽取(素材.自定义抽取次数)


func _on_骰子对决_pressed() -> void:
	get_tree().change_scene_to_file("res://骰子对决.tscn")
