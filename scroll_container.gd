extends ScrollContainer

func _ready():
	# 监听垂直滚动条的显隐变化
	get_v_scroll_bar().visibility_changed.connect(_on_scrollbar_visibility_changed)

func _on_scrollbar_visibility_changed():
	var grid = get_node("展示栏")
	# 强制刷新网格布局
	grid.queue_sort()
	# 等待一帧，让Godot完成布局计算（关键步骤，不能省略）
	await get_tree().process_frame
	# 强制更新最小高度，让ScrollContainer拿到正确的总高度
	grid.update_minimum_size()
