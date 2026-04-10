extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_关闭_pressed() -> void:
	queue_free()

func _on_确定_pressed() -> void:
	var t:String=$"Panel/抽取次数".text
	if not t.is_valid_int():
		return
	素材.自定义抽取次数=int(t)
	素材.自定义抽取信号.emit()
	queue_free()
	
