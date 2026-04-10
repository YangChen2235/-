extends Control

@export var idx:String
@onready var 名字:Label = $"Panel/名字"
@onready var 卡背:TextureRect = $"Panel/图片"
@export var cnt:int

func _ready() -> void:
	var 动画=create_tween()
	动画.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	名字.text=idx
	$ColorRect.color=Color(1.0, 1.0, 1.0, 1.0)
	var 颜色:Color=Color(1.0, 1.0, 1.0, 1.0)
	if cnt<1:
		卡背.texture=load("res://图片/五星.svg")
		颜色=Color("FBFF08")
	elif cnt<3:
		卡背.texture=load("res://图片/四星.svg")
		颜色=Color("E208FF")
	elif cnt<10:
		卡背.texture=load("res://图片/三星.svg")
		颜色=Color("08B1FF")
	elif cnt<20:
		卡背.texture=load("res://图片/二星.svg")
		颜色=Color("08FF1C")
	else :
		卡背.texture=load("res://图片/一星.svg")
		颜色=Color("FFFFFF")
	动画.tween_property($ColorRect,"color",颜色,0.1)
	动画.tween_property($ColorRect,"color",Color(0.0, 0.0, 0.0, 0.0),0.1)
