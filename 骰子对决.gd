extends Node

var 倍速:float=1.0
var 抽到的人:Array=[]
var 抽取到的人:Array=[] # 移到前面，用于保存初始名单用于颁奖
var 最终胜者:String=""
var MVP:String=""

@onready var 摄像头:Camera2D=$Camera2D
@onready var 开始按钮:Button=$"匹配界面/开始"
@onready var 匹配按钮:Button=$"匹配界面/匹配"
@onready var 抽取名单:VBoxContainer=$"匹配界面/滑块/抽取名单"
@onready var 水牌=$"幸运儿"
@onready var 行动牌=$"行动"
@onready var 结束牌=$"参与者水牌"
var 阶段:String = "匹配"

# 新增：用于记录整场比赛的数据
var 击杀统计:Dictionary={}
var 幸运星:String=""
var 分数变动记录:Dictionary={}

func 抽取(a:int):
	if 抽到的人.size()!=0:
		抽到的人.clear()
	for i in range(a):
		var man:String=素材.名字[randi()%素材.名字.size()]
		while man in 抽到的人:
			man=素材.名字[randi()%素材.名字.size()]
		抽到的人.append(man)

@onready var 强制匹配UI:Control=$"强制匹配"
@onready var 强制匹配展示:GridContainer=$"强制匹配/Panel/ScrollContainer/展示栏"
func 强制匹配_初始化():
	var cnt=0
	if 强制匹配展示.get_child_count()!=0:
		for i in 强制匹配展示.get_children():
			i.queue_free()
	for i in 素材.名字:
		var 新水牌=制作水牌(cnt,i)
		var 按钮:Button=新水牌.get_child(5)
		if i in 抽到的人:
			新水牌.get_node("颜色").color=Color(0.0, 0.0, 0.0, 0.784)
		else:
			新水牌.get_node("颜色").color=Color(1.0, 1.0, 1.0, 0.0)
		按钮.pressed.connect(添加角色.bind(i,新水牌))
		强制匹配展示.add_child(新水牌)
	var 新水牌=制作水牌(cnt,"孙晨曦")
	强制匹配展示.add_child(新水牌)
	新水牌=制作水牌(cnt,"孙晨曦")
	强制匹配展示.add_child(新水牌)

func 检查函数():
	print("Sun")

func 添加角色(s:String,目标:Control):
	if s in 抽到的人:
		抽到的人.erase(s)
		目标.get_node("颜色").color=Color(1.0, 1.0, 1.0, 0.0)
	else:
		抽到的人.append(s)
		目标.get_node("颜色").color=Color(0.0, 0.0, 0.0, 0.784)
	刷新匹配栏()

func 刷新匹配栏():
	if 抽取名单.get_child_count()!=0:
		for i in 抽取名单.get_children():
			i.queue_free()
	var cnt=0
	for i in 抽到的人:
		cnt+=1
		var 新水牌=制作水牌(cnt,i)
		抽取名单.add_child(新水牌)

func _ready() -> void:
	读取存档()
	开始按钮.hide()
	强制匹配UI.hide()
	摄像头.global_position=Vector2(0,0)
	if 素材.段位.size()==0:
		for i in 素材.名字:
			素材.段位[i]="青铜"
	if 素材.分数.size()==0:
		for i in 素材.名字:
			素材.分数[i]=0
	if 素材.胜利次数.size()==0:
		for i in 素材.名字:
			素材.胜利次数[i]=0
	if 素材.失败次数.size()==0:
		for i in 素材.名字:
			素材.失败次数[i]=0

func 分数增加(名字:String,分数变化:int):
	if 分数变化!=0:
		if 素材.分数[名字]+分数变化<0:
			素材.分数[名字]=0
		else:
			素材.分数[名字]+=分数变化
	if 素材.分数[名字]<=5:
		素材.段位[名字]="青铜"
	elif 素材.分数[名字]<=10:
		素材.段位[名字]="白银"
	elif 素材.分数[名字]<=20:
		素材.段位[名字]="黄金"
	elif 素材.分数[名字]<=40:
		素材.段位[名字]="铂金"
	elif 素材.分数[名字]<=80:
		素材.段位[名字]="钻石"
	elif 素材.分数[名字]<=160:
		素材.段位[名字]="星辉"
	elif 素材.分数[名字]<=320:
		素材.段位[名字]="王者"
	else:
		素材.段位[名字]="古戈尔"

func 类型查找(索引:int)->String:
	if 索引>=0 and 索引<=9: 
		return "攻击"
	elif 索引>=10 and 索引<=14:
		return "防御"
	elif 索引>=15 and 索引<=20:
		return "增益"
	else:
		return "特殊"

func 抽取行动(行动点:int)->int:
	var 我的行动:int=-1
	var 尝试次数:int=0
	while 我的行动==-1 and 尝试次数<50:
		尝试次数+=1
		var 选择=randi()%5
		if 选择==0 or 选择==4:
			我的行动=randi()%10
		elif 选择==1:
			我的行动=randi()%5+10
		elif 选择==2:
			我的行动=randi()%6+15 
		else:
			我的行动=randi()%3+21
		
		if 花费[我的行动]>行动点:
			我的行动=-1
			
	if 我的行动==-1:
		return 22
	return 我的行动

var 行动:Array=素材.行动
var 花费:Array=素材.花费
var 神秘标签:Array=素材.神秘标签
var 互怼语录:Array=素材.互怼语录

@onready var 聊天栏:RichTextLabel=$"游戏/聊天框"
func 互怼():
	var 记录:String=聊天栏.text
	if randi()%3==0:
		if randi()%2==1:
			记录+="[color=#0b9000]["+左+"][/color]"+"："+互怼语录[randi()%互怼语录.size()]+"\n"
		else:
			记录+="[color=#0b9000]["+右+"][/color]"+"："+互怼语录[randi()%互怼语录.size()]+"\n"
	聊天栏.text=记录
	await get_tree().process_frame

func 制作水牌(索引:int,名字:String):
	var 新水牌=水牌.duplicate()
	新水牌.name="水牌"+String.num_int64(索引)
	新水牌.get_child(2).text=名字
	新水牌.get_child(3).text=神秘标签[randi()%神秘标签.size()]
	# 优化：幸运星优先级高于段位
	if 幸运星==名字:
		新水牌.get_child(0).texture=load("res://图片/骰子对决/幸运星.svg")
	else:
		新水牌.get_child(0).texture=load("res://图片/骰子对决/"+素材.段位[名字]+".svg")
	return 新水牌

func 制作行动牌(类型:String,内容:String):
	var 新行动=行动牌.duplicate()
	if 类型=="攻击":
		新行动.get_child(0).texture=load("res://图片/骰子对决/攻击.svg")
	elif 类型=="防御":
		新行动.get_child(0).texture=load("res://图片/骰子对决/防御.svg")
	elif 类型=="提示":
		新行动.get_child(0).texture=load("res://图片/骰子对决/提示.svg")
	elif 类型=="特殊":
		新行动.get_child(0).texture=load("res://图片/骰子对决/特殊.svg")
	else:
		新行动.get_child(0).texture=load("res://图片/骰子对决/增益.svg")
	新行动.get_child(1).text=内容
	return 新行动

func 制作结束牌(名字:String):
	var 新结束牌=结束牌.duplicate()
	if 最终胜者==名字:
		新结束牌.get_child(0).texture=load("res://图片/骰子对决/冠军.svg")
	elif MVP==名字:
		新结束牌.get_child(0).texture=load("res://图片/骰子对决/MVP.svg")
	elif 幸运星==名字:
		新结束牌.get_child(0).texture=load("res://图片/骰子对决/幸运星牌底.svg")
	else:
		新结束牌.get_child(0).texture=load("res://图片/骰子对决/参与者.svg")
	新结束牌.get_child(1).text=名字
	return 新结束牌

func _on_匹配_pressed() -> void:
	if 抽到的人.size()==0:
		匹配按钮.text="开始匹配"
	else:
		匹配按钮.text="再次匹配"
	抽取(12)
	刷新匹配栏()
	开始按钮.show()

func _on_开始_pressed() -> void:
	if 阶段=="匹配":
		pass
	var 动画=create_tween()
	动画.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	动画.tween_property(摄像头,"global_position",Vector2(0,摄像头.global_position.y+648),0.5)
	阶段="对决"
	await 动画.finished
	抽取到的人=抽到的人.duplicate()
	对决()
	
var 左:String
var 右:String
@onready var 提示:Label=$"游戏/提示"
@onready var 左边水牌:BoxContainer=$"游戏/左水牌"
@onready var 右边水牌:BoxContainer=$"游戏/右水牌"
@onready var 左边滑动条:ScrollContainer=$"游戏/ScrollContainer"
@onready var 右边滑动条:ScrollContainer=$"游戏/ScrollContainer2"
@onready var 左边行动栏:VBoxContainer=$"游戏/ScrollContainer/左边"
@onready var 右边行动栏:VBoxContainer=$"游戏/ScrollContainer2/右边"
@onready var 左血条:ProgressBar=$"游戏/左血条"
@onready var 右血条:ProgressBar=$"游戏/右血条"
@onready var 左行动点显示:Label=$"游戏/左行动点"
@onready var 右行动点显示:Label=$"游戏/右行动点"
var 属性:Dictionary={
	"攻击力":1,
	"攻击力增益":1,
	"帽":0,
	"衣":0,
	"裤":0,
	"鞋":0,
	"盾":0,
	"血量":10,
	"血量上限":10,
	"行动点":0
}

func 等待(时间:float):
	await get_tree().create_timer(时间/倍速).timeout

@onready var 左骰子:TextureRect=$"游戏/左骰子"
@onready var 右骰子:TextureRect=$"游戏/右骰子"
func 投掷动画()->Array:
	var 图片:Array=["sunchenxi","res://图片/骰子对决/1.svg","res://图片/骰子对决/2.svg","res://图片/骰子对决/3.svg","res://图片/骰子对决/4.svg","res://图片/骰子对决/5.svg","res://图片/骰子对决/6.svg"]
	var 左数:int=randi()%6+1
	for i in range(5):
		左骰子.texture=load(图片[randi()%6+1])
		右骰子.texture=load(图片[randi()%6+1])
		await 等待((6-i)*0.05)
	var 右数:int=randi()%6+1
	左骰子.texture=load(图片[左数])
	右骰子.texture=load(图片[右数])
	var rt:Array=[];rt.append(左数);rt.append(右数)
	互怼()
	return rt

func 刷新():
	await get_tree().process_frame
	#scroll_vertical才是对的不需要修改
	左边滑动条.scroll_vertical=左边滑动条.get_v_scroll_bar().max_value
	右边滑动条.scroll_vertical=右边滑动条.get_v_scroll_bar().max_value

@onready var 左盾值:Label=$"游戏/左盾值"
@onready var 右盾值:Label=$"游戏/右盾值"

func 更新状态显示(左属性:Dictionary, 右属性:Dictionary):
	左盾值.text=String.num_int64(左属性["鞋"])+"👟"+String.num_int64(左属性["衣"])+"🦺"+String.num_int64(左属性["裤"])+"👖"+String.num_int64(左属性["帽"])+"🧢"+String.num_int64(左属性["盾"])+"🛡"
	右盾值.text=String.num_int64(右属性["鞋"])+"👟"+String.num_int64(右属性["衣"])+"🦺"+String.num_int64(右属性["裤"])+"👖"+String.num_int64(右属性["帽"])+"🧢"+String.num_int64(右属性["盾"])+"🛡"
	左血条.max_value=左属性["血量上限"]
	左血条.value=左属性["血量"]
	右血条.max_value=右属性["血量上限"]
	右血条.value=右属性["血量"]
	左行动点显示.text=String.num_int64(左属性["行动点"])+"🎲"
	右行动点显示.text=String.num_int64(右属性["行动点"])+"🎲"

func 添加行动日志(容器:VBoxContainer, 类型:String, 内容:String):
	容器.add_child(制作行动牌(类型, 内容))
	刷新()

func 执行行动(行动索引:int, 施法者属性:Dictionary, 目标属性:Dictionary, 施法者容器:VBoxContainer, 左属性:Dictionary, 右属性:Dictionary):
	var 类型=类型查找(行动索引)
	var 消耗=花费[行动索引]
	施法者属性["行动点"] -= 消耗
	更新状态显示(左属性, 右属性)
	
	var 总防御=目标属性["帽"]+目标属性["衣"]+目标属性["裤"]+目标属性["鞋"]+目标属性["盾"]
	
	if 行动索引==0:
		var 伤害=施法者属性["攻击力"] * 施法者属性["攻击力增益"]
		var 实际伤害=max(伤害-总防御,1)
		目标属性["血量"]=max(目标属性["血量"]-实际伤害,0)
		伤害显示(施法者属性["位置"],伤害)
		添加行动日志(施法者容器, "提示", "造成了 "+String.num_int64(实际伤害)+" 点伤害！")
	elif 行动索引>=1 and 行动索引<=7:
		var 伤害=2
		var 实际伤害=max(伤害-总防御,1)
		目标属性["血量"]=max(目标属性["血量"]-实际伤害,0)
		伤害显示(施法者属性["位置"],伤害)
		添加行动日志(施法者容器, "提示", "元素附着！额外造成 "+String.num_int64(实际伤害)+" 点伤害")
	elif 行动索引==8:
		var 伤害=2
		var 实际伤害=max(伤害-总防御,1)
		目标属性["血量"]=max(目标属性["血量"]-实际伤害,0)
		伤害显示(施法者属性["位置"],伤害)
		添加行动日志(施法者容器, "提示", "重击！造成 "+String.num_int64(实际伤害)+" 点伤害！")
	elif 行动索引==9:
		var 伤害=3
		var 实际伤害=max(伤害-总防御,1)
		目标属性["血量"]=max(目标属性["血量"]-实际伤害,0)
		伤害显示(施法者属性["位置"],伤害)
		添加行动日志(施法者容器, "提示", "格斗术！造成 "+String.num_int64(实际伤害)+" 点伤害！")
		
	elif 行动索引==10: 
		施法者属性["帽"]=1
		添加行动日志(施法者容器, "提示", "头盔装备！防御+1")
	elif 行动索引==11: 
		施法者属性["衣"]=2
		添加行动日志(施法者容器, "提示", "胸甲装备！防御+2")
	elif 行动索引==12: 
		施法者属性["裤"]=1
		添加行动日志(施法者容器, "提示", "裤腿装备！防御+1")
	elif 行动索引==13: 
		施法者属性["鞋"]=1
		添加行动日志(施法者容器, "提示", "鞋子装备！防御+1")
	elif 行动索引==14: 
		施法者属性["盾"]=2
		添加行动日志(施法者容器, "提示", "盾牌装备！防御+2")
	
	elif 行动索引==15:
		施法者属性["血量"]=min(施法者属性["血量"]+1, 施法者属性["血量上限"])
		添加行动日志(施法者容器, "提示", "回血1点！")
	elif 行动索引==16:
		施法者属性["血量"]=min(施法者属性["血量"]+2, 施法者属性["血量上限"])
		添加行动日志(施法者容器, "提示", "回血2点！")
	elif 行动索引==17:
		施法者属性["血量"]=min(施法者属性["血量"]+1, 施法者属性["血量上限"])
		添加行动日志(施法者容器, "提示", "回血1点！")
	elif 行动索引==18:
		施法者属性["攻击力增益"]=2
		添加行动日志(施法者容器, "提示", "攻击力翻倍了！")
	elif 行动索引==19:
		施法者属性["血量上限"]+=2
		施法者属性["血量"]+=2
		添加行动日志(施法者容器, "提示", "血量上限+2，当前血量+2！")
	elif 行动索引==20:
		var 随机防御=randi()%2+1
		施法者属性["盾"]+=随机防御
		添加行动日志(施法者容器, "提示", "获得纸板！防御+"+String.num_int64(随机防御))
		
	elif 行动索引==21:
		var 伤害=3
		var 实际伤害=max(伤害-总防御,1)
		目标属性["血量"]=max(目标属性["血量"]-实际伤害,0)
		添加行动日志(施法者容器, "提示", "对方破防了！受到"+String.num_int64(实际伤害)+"点伤害！")
	elif 行动索引==22:
		添加行动日志(施法者容器, "提示", "我的刀顿了...")
		施法者属性["攻击力增益"]=1
	elif 行动索引==23:
		施法者属性["行动点"]+=1
		添加行动日志(施法者容器, "提示", "孙晨曦眷顾！行动点+1")
	elif 行动索引==24:
		施法者属性["血量"]=max(施法者属性["血量"]-1,0)
		添加行动日志(施法者容器, "提示", "哎呀！不小心滑倒了，自己扣了1点血")
	
	更新状态显示(左属性, 右属性)

func 对决():
	# 初始化数据统计
	击杀统计.clear()
	分数变动记录.clear()
	最终胜者=""
	MVP=""
	for i in 抽到的人:
		击杀统计[i]=0
		分数变动记录[i]=0
	# 随机选一名幸运星
	幸运星=抽到的人[randi()%抽到的人.size()]

	var 场数:int=0
	while 抽到的人.size()>1:
		聊天栏.text=""
		提示.text="抽取同学中"
		左=抽到的人[randi()%抽到的人.size()]
		抽到的人.erase(左)
		右=抽到的人[randi()%抽到的人.size()]
		抽到的人.erase(右)
		
		for i in 左边水牌.get_children(): i.queue_free()
		for i in 右边水牌.get_children(): i.queue_free()
		for i in 左边行动栏.get_children(): i.queue_free()
		for i in 右边行动栏.get_children(): i.queue_free()
		
		左边水牌.add_child(制作水牌(0,左))
		右边水牌.add_child(制作水牌(0,右))
		
		var 左属性:Dictionary=属性.duplicate()
		var 右属性:Dictionary=属性.duplicate()
		左属性["位置"]=右边水牌.global_position
		右属性["位置"]=左边水牌.global_position
		更新状态显示(左属性, 右属性)
		
		await 等待(1)
		提示.text="开始对决"
		var 轮数:int=1
		var 主:String=""
		场数+=1
		if 左==幸运星:
			左属性["血量"]+=2
		if 右==幸运星:
			右属性["血量"]+=2
			
		while 左属性["血量"]>0 and 右属性["血量"]>0:
			左属性["攻击力增益"]=1
			右属性["攻击力增益"]=1
			
			await 等待(1.0)
			提示.text="第 "+String.num_int64(场数)+" 场"+"\n第 "+String.num_int64(轮数)+" 轮\n"+"开始掷骰子"
			
			var 结果:Array=[0,0]
			while 结果[0]==结果[1]:
				结果=await 投掷动画()
			await 等待(0.1)
			
			添加行动日志(左边行动栏, "提示", "我获得 "+String.num_int64(结果[0])+" 点骰子的力量")
			添加行动日志(右边行动栏, "提示", "我获得 "+String.num_int64(结果[1])+" 点骰子的力量")
			
			if 结果[0]>结果[1]:
				添加行动日志(左边行动栏, "提示", "我获得了优先权")
				主=左
			else:
				添加行动日志(右边行动栏, "提示", "我获得了优先权")
				主=右
				
			左属性["行动点"]=结果[0]
			右属性["行动点"]=结果[1]
			更新状态显示(左属性, 右属性)
			
			await 等待(0.1)
			
			while 左属性["行动点"]>0 or 右属性["行动点"]>0:
				if 主==左:
					if 左属性["行动点"]>0:
						var 我的行动:int=抽取行动(左属性["行动点"])
						var 类型:String=类型查找(我的行动)
						添加行动日志(左边行动栏, 类型, 行动[我的行动])
						执行行动(我的行动, 左属性, 右属性, 左边行动栏, 左属性, 右属性)
					else:
						添加行动日志(左边行动栏, "提示", 左+"没有足够的行动点，跳过")
						左属性["行动点"]=0
						更新状态显示(左属性, 右属性)
				else:
					if 右属性["行动点"]>0:
						var 我的行动:int=抽取行动(右属性["行动点"])
						var 类型:String=类型查找(我的行动)
						添加行动日志(右边行动栏, 类型, 行动[我的行动])
						执行行动(我的行动, 右属性, 左属性, 右边行动栏, 左属性, 右属性)
					else:
						添加行动日志(右边行动栏, "提示", 右+"没有足够的行动点，跳过")
						右属性["行动点"]=0 
						更新状态显示(左属性, 右属性)
						
				await 等待(1.0)
				
				if 主==左:
					主=右
				else:
					主=左
				if 轮数 > 10:
					var 扣除:int=轮数-10
					if 左属性["血量"]-扣除<0 and 右属性["血量"]-扣除:
						添加行动日志(左边行动栏,"特殊","孙晨曦发怒双方各扣"+String.num_int64(扣除)+"点生命")
						添加行动日志(左边行动栏,"特殊","孙晨曦发怒双方各扣"+String.num_int64(扣除)+"点生命")
						更新状态显示(左属性, 右属性)
						break
					else:
						左属性["血量"]=max(0,左属性["血量"]-扣除)
						右属性["血量"]=max(0,右属性["血量"]-扣除)
						添加行动日志(左边行动栏,"特殊","孙晨曦发怒双方各扣"+String.num_int64(扣除)+"点生命")
						添加行动日志(左边行动栏,"特殊","孙晨曦发怒双方各扣"+String.num_int64(扣除)+"点生命")
						更新状态显示(左属性, 右属性)
				if 左属性["血量"]<=0 or 右属性["血量"]<=0:
					break
			
			if 轮数>999:
				print("错误：超出预期")
				break
			else:
				轮数+=1
		
		# 决出单场胜负并记录分数
		var 胜者:String
		var 败者:String
		if 左属性["血量"]>0 or 左属性["血量"]>右属性["血量"]:
			胜者=左
			败者=右
		else:
			胜者=右
			败者=左
		素材.胜利次数[胜者]+=1
		素材.失败次数[败者]+=1
		抽到的人.append(胜者)
		击杀统计[胜者]+=1
		
		var 胜者加分=2
		var 败者扣分=-2
		if 素材.段位[败者]=="古戈尔":
			败者扣分*=3
		if 素材.段位[胜者]=="古戈尔":
			胜者加分=1
		
		if 胜者==幸运星: 胜者加分*=2
		if 败者==幸运星: 败者扣分*=2
		
		分数变动记录[胜者]+=胜者加分
		
		if 素材.段位[败者]!="青铜" and 素材.段位[败者]!="白银":
			分数变动记录[败者]+=败者扣分
		
		提示.text=胜者+" 获胜！进入下一轮"
		await 等待(3)
	
	最终胜者=抽到的人[0]
	
	var 最终加分=5
	if 最终胜者==幸运星: 最终加分*=2
	分数变动记录[最终胜者]+=最终加分
	
	var 最高击杀=0
	MVP=""
	for i in 击杀统计:
		if 击杀统计[i]>最高击杀:
			最高击杀=击杀统计[i]
			MVP=i
			
	if MVP!="":
		var MVP加分=4
		if MVP==幸运星: MVP加分*=2
		分数变动记录[MVP]+=MVP加分
	
	for i in 分数变动记录:
		分数增加(i, 分数变动记录[i])
		
	提示.text="愿骰子保佑每个人的运气\n最终胜者是："+最终胜者+"\nMVP是："+MVP
	await 等待(3)
	# 新增：自动切换到颁奖台
	颁奖()

func 伤害显示(目标位置:Vector2,伤害:int):
	var 伤显:Label=$"伤害显示".duplicate()
	伤显.text=String.num_int64(伤害)
	伤显.global_position=目标位置
	$"伤害显示".add_child(伤显)
	var 动画=create_tween()
	动画.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	动画.tween_property(伤显,"global_position",Vector2(0,伤显.global_position.y+35),0.5)
	伤显.queue_free()

@onready var 颁奖展示台:GridContainer=$"颁奖台/展示台"
@onready var 颁奖_返回键:Button=$"颁奖台/返回建"
func 颁奖():
	倍速=1.0
	加速按钮.text="一倍速"
	# 移动摄像头到颁奖台
	var 动画=create_tween()
	动画.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	动画.tween_property(摄像头,"global_position",Vector2(0,摄像头.global_position.y+648),0.5)
	await 动画.finished
	颁奖_返回键.hide()
	if 颁奖展示台.get_child_count()>0:
		for i in 颁奖展示台.get_children():
			i.queue_free()
	var 已展示:Array=[]
	if 最终胜者!="":
		var 水牌=制作结束牌(最终胜者)
		颁奖展示台.add_child(水牌)
		已展示.append(最终胜者)
		
	if MVP!="" and MVP!=最终胜者:
		var 水牌=制作结束牌(MVP)
		颁奖展示台.add_child(水牌)
		已展示.append(MVP)
		
	for i in 抽取到的人:
		if not i in 已展示:
			var 水牌=制作结束牌(i)
			颁奖展示台.add_child(水牌)
			
	await 等待(1)
	抽到的人=抽取到的人
	刷新匹配栏()
	保存存档()
	颁奖_返回键.show()

func _on_返回建_pressed() -> void:
	幸运星=""
	MVP=""
	最终胜者=""
	var 动画=create_tween()
	动画.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	动画.tween_property(摄像头,"global_position",Vector2(0,0),0.5)
	await 动画.finished

@onready var 排行榜:GridContainer=$"排行榜/ScrollContainer/展示框"
func _on_返回键_pressed() -> void:
	var 动画=create_tween()
	动画.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	动画.tween_property(摄像头,"global_position",Vector2(0,0),0.5)
	await 动画.finished

@onready var 毁灭存档对话:Control=$"毁灭存档"
func _on_排行榜_pressed() -> void:
	毁灭存档对话.hide()
	$"毁灭存档/Panel/返回".pressed.connect(_on_返回键_pressed)
	回档按钮.text="毁灭存档"
	氪金按钮.text="氪金"
	解释栏.text="这里显示详情"
	if 排行榜.get_child_count()>0:
		for i in 排行榜.get_children():
			i.queue_free()
	var cnt:int=0
	var 排行:Array=素材.名字.duplicate()
	排行.sort_custom(func(名字1:String,名字2:String)->bool:return 素材.分数[名字1]>素材.分数[名字2])
	for i in 排行:
		var 新水牌=制作水牌(cnt,i)
		新水牌.get_node("点击框").pressed.connect(解释.bind(i))
		排行榜.add_child(新水牌)
	var 动画=create_tween()
	动画.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	动画.tween_property(摄像头,"global_position",Vector2(0,-648),0.5)
	await 动画.finished

@onready var 加速按钮:Button=$"游戏/加速器"
func _on_加速器_pressed() -> void:
	if 加速按钮.text=="一倍速":
		倍速=2.0
		加速按钮.text="二倍速"
	elif 加速按钮.text=="二倍速":
		倍速=3.0
		加速按钮.text="三倍速"
	elif 加速按钮.text=="三倍速":
		倍速=10.0
		加速按钮.text="十倍速"
	elif 加速按钮.text=="十倍速":
		倍速=20.0
		加速按钮.text="二十倍速"
	elif 加速按钮.text=="二十倍速":
		倍速=50.0
		加速按钮.text="五十倍速"
	elif 加速按钮.text=="五十倍速":
		倍速=100.0
		加速按钮.text="一百倍速"
	else :
		倍速=1.0
		加速按钮.text="一倍速"


func _on_强制匹配_pressed() -> void:
	阶段="选择"
	强制匹配UI.show()
	强制匹配_初始化()

func _on_完成_pressed() -> void:
	阶段="匹配"
	强制匹配UI.hide()
	if 抽到的人.size()>1:
		开始按钮.show()

func _on_一键清空_pressed() -> void:
	抽到的人.clear()
	开始按钮.hide()
	刷新匹配栏()

func 保存存档():
	素材.保存存档()

func 读取存档():
	素材.读取存档()

func _on_导入按钮_pressed() -> void:
	保存存档()


func _on_导出按钮_pressed() -> void:
	读取存档()


func _on_退出_pressed()->void:
	get_tree().change_scene_to_file("res://主场景.tscn")


func _on_组团匹配_pressed() -> void:
	get_tree().change_scene_to_file("res://骰子对决团队.tscn")

@onready var 回档按钮:Button=$"排行榜/毁档"
func _on_毁档_pressed() -> void:
	if 回档按钮.text=="毁灭存档":
		回档按钮.text="你确定？"
	else:
		毁灭存档对话.show()
		#for i in 素材.名字:
			#素材.分数[i]=0
			#素材.段位[i]="青铜"
		#保存存档()
		#get_tree().change_scene_to_file("res://主场景.tscn")

@onready var 氪金按钮:Button=$"排行榜/氪金"
func _on_氪金_pressed() -> void:
	氪金按钮.text="余额不足"

@onready var 解释栏:Label=$"排行榜/详情"
func 解释(名字:String):
	var 分数:String=String.num_int64(素材.分数[名字])
	var 胜利:String=String.num_int64(素材.胜利次数[名字])
	var 失败:String=String.num_int64(素材.失败次数[名字])
	解释栏.text=名字+" 段位:"+素材.段位[名字]+" 分数:"+分数+" 胜利:"+胜利+" 失败:"+失败


func _on_完成毁灭_pressed() -> void:
	if $"毁灭存档/Panel/密码输入框".text=="sunchenxi114514":
		for i in 素材.名字:
			素材.分数[i]=0
			素材.段位[i]="青铜"
			素材.胜利次数[i]=0
			素材.失败次数[i]=0
		保存存档()
		get_tree().change_scene_to_file("res://主场景.tscn")


func _on_关闭游戏_pressed() -> void:
	get_tree().quit()
