extends Node

@export var 名字:String
@export var 元素:int
@export var 简介:String 
@export var cnt:int
@onready var 元素显示:TextureRect=$"Panel/元素"
@onready var 简介显示:RichTextLabel=$"Panel/简介"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cnt=素材.次数查询(名字)
	简介=素材.介绍(名字)
	简介显示.text=简介
	元素=randi()%7
	var 动画=create_tween()
	动画.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	$ColorRect.color=Color(1.0, 1.0, 1.0, 1.0)
	var 颜色:Color=Color(1.0, 1.0, 1.0, 1.0)
	if cnt<1:
		颜色=Color("FBFF08")
	elif cnt<3:
		颜色=Color("E208FF")
	elif cnt<10:
		颜色=Color("08B1FF")
	elif cnt<20:
		颜色=Color("08FF1C")
	else :
		颜色=Color("FFFFFF")
	动画.tween_property($ColorRect,"color",颜色,0.05)
	动画.tween_property($ColorRect,"color",Color(0.0, 0.0, 0.0, 0.0),0.2)
	$"Panel/名字".text=名字
	if 元素==0:
		元素显示.texture=load("res://图片/风元素.png")
	elif 元素==1:
		元素显示.texture=load("res://图片/岩元素.png")
	elif 元素==2:
		元素显示.texture=load("res://图片/雷元素.png")
	elif 元素==3:
		元素显示.texture=load("res://图片/草元素.png")
	elif 元素==4:
		元素显示.texture=load("res://图片/水元素.png")
	elif 元素==5:
		元素显示.texture=load("res://图片/火元素.png")
	else :
		元素显示.texture=load("res://图片/冰元素.png")
	await $"Panel/下一个".pressed
	结束立绘.emit()
	queue_free()

signal 结束立绘()
