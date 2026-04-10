extends Node

@onready var 创建学习小组:Control=$"注册团队"
@onready var 强制匹配:Control=$"强制匹配"
func _on_返回_pressed() -> void:
	get_tree().change_scene_to_file("res://骰子对决.tscn")

func _ready() -> void:
	创建学习小组.global_position=Vector2(-1152.0,0)

func _on_组团_pressed() -> void:
	创建学习小组_初始化()
	创建学习小组.global_position=Vector2(0,0)

func _on_放弃_pressed() -> void:
	创建学习小组.global_position=Vector2(-1152.0,0)


func 成员展示框_初始化():
	var 成员展示框:VBoxContainer=$"注册团队/Panel/成员栏"
	if 成员展示框.get_child_count() > 0:
		for i in 成员展示框.get_children():
			i.queue_free()
	for i in 新添加成员:
		成员展示框.add_child(制作水牌(i))

func 创建学习小组_初始化():
	新添加成员=[]
	var 名字:LineEdit=$"注册团队/Panel/输入框"
	$"注册团队/Panel/生命/SpinBox".value=0
	#$"注册团队/Panel/生命/SpinBox".changed.connect(更新加成.bind($"注册团队/Panel/生命/SpinBox"))
	$"注册团队/Panel/防御/SpinBox".value=0
	#$"注册团队/Panel/防御/SpinBox".changed.connect(更新加成.bind($"注册团队/Panel/防御/SpinBox"))
	$"注册团队/Panel/幸运/SpinBox".value=0
	#$"注册团队/Panel/幸运/SpinBox".changed.connect(更新加成.bind($"注册团队/Panel/幸运/SpinBox"))
	$"注册团队/Panel/攻击/SpinBox".value=0
	#$"注册团队/Panel/攻击/SpinBox".changed.connect(更新加成.bind($"注册团队/Panel/攻击/SpinBox"))
	名字.text=""
	成员展示框_初始化()

func 强制匹配_初始化():
	var 强制匹配展示:GridContainer=强制匹配.get_node("Panel/ScrollContainer/展示栏")
	if 强制匹配展示.get_child_count()!=0:
		for i in 强制匹配展示.get_children():
			i.queue_free()
	for i in 素材.名字:
		var 新水牌=制作水牌(i)
		新水牌.get_node("点击框").pressed.connect(添加成员.bind(i,新水牌))
		if i in 新添加成员:
			新水牌.get_node("颜色").color=Color(0.0, 0.0, 0.0, 0.667)
		强制匹配展示.add_child(新水牌)

func 制作水牌(名字:String):
	var 新水牌:Panel=$"水牌模版".duplicate()
	新水牌.get_child(2).text=名字
	新水牌.get_child(3).text=素材.神秘标签[randi()%素材.神秘标签.size()]
	新水牌.get_child(0).texture=load("res://图片/骰子对决/"+素材.段位[名字]+".svg")
	return 新水牌

var 新添加成员:Array=[]
func 添加成员(名字:String,目标:Panel):
	if (not 名字 in 新添加成员):
		if 新添加成员.size()==4:
			return
		新添加成员.append(名字)
		目标.get_node("颜色").color=Color(0.0, 0.0, 0.0, 0.667)
	else:
		新添加成员.erase(名字)
		目标.get_node("颜色").color=Color(0.0, 0.0, 0.0, 0.0)
	成员展示框_初始化()

func _on_选择_pressed() -> void:
	强制匹配_初始化()
	强制匹配.global_position=Vector2(400,20)

func _on_完成_pressed() -> void:
	强制匹配.global_position=Vector2(-1592.0,-624.0)


func _on_注册学习小组_pressed() -> void:
	var 学习小组:Dictionary=素材.学习小组模版.duplicate()
	学习小组["名字"]=创建学习小组.get_node("Panel/输入框").text
	var 生命=int(创建学习小组.get_node("Panel/生命/SpinBox").value)
	var 防御=int(创建学习小组.get_node("Panel/防御/SpinBox").value)
	var 攻击=int(创建学习小组.get_node("Panel/攻击/SpinBox").value)
	var 幸运=int(创建学习小组.get_node("Panel/幸运/SpinBox").value)
	学习小组["生命加成"]=生命
	学习小组["防御加成"]=防御
	学习小组["攻击加成"]=攻击
	学习小组["幸运加成"]=幸运
	学习小组["成员"]=新添加成员
	if 生命+防御+攻击+幸运!=10:
		print("不满足")
		return
	素材.学习小组名单.append(学习小组)
	print(素材.学习小组名单)
	创建学习小组.get_node("Panel/生命/SpinBox").value=0
	创建学习小组.get_node("Panel/防御/SpinBox").value=0
	创建学习小组.get_node("Panel/攻击/SpinBox").value=0
	创建学习小组.get_node("Panel/幸运/SpinBox").value=0
	创建学习小组.global_position=Vector2(-1152.0,0)

func 更新加成(目标:SpinBox):
	var 生命=int(创建学习小组.get_node("Panel/生命/SpinBox").value)
	var 防御=int(创建学习小组.get_node("Panel/防御/SpinBox").value)
	var 攻击=int(创建学习小组.get_node("Panel/攻击/SpinBox").value)
	var 幸运=int(创建学习小组.get_node("Panel/幸运/SpinBox").value)
	if 目标.value>10:
		目标.value=10
	目标.max_value=10-生命-防御-攻击-幸运

func 制作学习小组(idx:int):
	var 学习小组信息:Dictionary=素材.学习小组名单[idx]
	var 新=$"学习小组模版".duplicate()
	新.get_node("名字").text=学习小组信息["名字"]
	for i in 学习小组信息["成员"]:
		新.get_node("成员栏").add_child(制作水牌(i))
	return 新

func 团队排名初始化():
	if $"排行榜/ScrollContainer/展示框".get_child_count()>0:
		for i in $"排行榜/ScrollContainer/展示框".get_children():
			i.queue_free()
	for i in range(素材.学习小组名单.size()):
		$"排行榜/ScrollContainer/展示框".add_child(制作学习小组(i))

func _on_团队排名_pressed() -> void:
	团队排名初始化()
	$"Camera2D".global_position.y-=648
	

func _on_返回键_pressed() -> void:
	素材.保存存档()
	$"Camera2D".global_position.y+=648
