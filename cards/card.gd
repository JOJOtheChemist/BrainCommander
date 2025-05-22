extends Control
class_name card

# 引入卡面管理器
const CardViewManager = preload("res://cards/managers/card_view_manager.gd")
const CardFrameManager = preload("res://cards/managers/card_frame_manager.gd")
var view_manager: CardViewManager
var frame_manager: CardFrameManager

var velocity = Vector2.ZERO
var damping = 0.35
var stiffness = 500

var preDeck

@export var cardClass:String
@export var cardName:String
@export var maxStackNum:int
@export var cardWeight:float
@export var cardInfo:Dictionary
@export var brainRegion:String
@export var cardType:String

var pickButton

enum cardState{following,dragging, in_play_area}
@export var cardCurrentState=cardState.following

@export var follow_target:Node
var whichDeckMouseIn

var is_in_play_area: bool = false

func _ready():
	# 初始化卡面管理器
	view_manager = CardViewManager.new(self)
	frame_manager = CardFrameManager.new(self)

func _process(delta: float) -> void:
	if is_in_play_area:
		return

	match  cardCurrentState:
		cardState.dragging:
			var target_position=get_global_mouse_position()-size/2
			global_position=global_position.lerp(target_position, 0.4)
			
			var mouse_position = get_global_mouse_position()
			var nodes = get_tree().get_nodes_in_group("cardDropable")
			for node in nodes:
				if node.get_global_rect().has_point(mouse_position)&&node.visible==true:
					whichDeckMouseIn=node
			
		cardState.following:
			if follow_target!=null:
				var target_position=follow_target.global_position
				var displacement = target_position - global_position
				var force = displacement * stiffness
				velocity += force * delta
				velocity *= (1.0 - damping)
				global_position += velocity * delta




func _on_button_button_down() -> void:
	if is_in_play_area:
		print(cardName + " is in play area, cannot be dragged.")
		return

	cardCurrentState = cardState.dragging
	if follow_target!=null:
		follow_target.queue_free()
		follow_target = null
	print(cardName + " started dragging.")


func _on_button_button_up() -> void:
	if is_in_play_area:
		return

	cardCurrentState = cardState.following

	if whichDeckMouseIn!=null:
		print(cardName + " dropped on " + whichDeckMouseIn.name)
		whichDeckMouseIn.add_card(self)
	else:
		print(cardName + " returned to preDeck " + preDeck.name)
		preDeck.add_card(self)

	whichDeckMouseIn = null

func initCard(Nm) -> void:
	cardInfo=CardInfos.infosDic[Nm]
	cardWeight=float(cardInfo["base_cardWeight"])
	cardClass=cardInfo["base_cardType"]
	cardName=cardInfo["base_cardName"]
	brainRegion=cardInfo["Brain Region"]
	cardType=cardInfo["CardType"]
	is_in_play_area = false
	cardCurrentState=cardState.following
	
	# 立即打印调试信息，检查数据是否正确加载
	print("初始化卡牌: " + cardName + ", 显示名称: " + cardInfo.get("base_displayName", cardName))
	print("卡牌类型: " + cardType + ", 脑区: " + brainRegion)
	
	# 直接设置卡牌类型图标
	update_card_type_icon()
	
	# 更新卡面显示
	if view_manager:
		view_manager.update_card_view(cardInfo)
	else:
		# 如果view_manager未初始化，则用老方法绘制卡牌
		drawCard()
		
	# 更新卡牌框架
	if frame_manager:
		frame_manager.update_frame(brainRegion)
		
	self.set_meta("is_card_instance", true)

func drawCard():
	pickButton = $Control/ColorRect/itemImg/Button
	var imgPath = "res://cardImg/" + str(cardName) + ".png"
	var texture: Texture2D = null
	if ResourceLoader.exists(imgPath):
		texture = load(imgPath)
	else:
		print("警告: 找不到图片资源: ", imgPath, "，使用默认图片。")

	var original_size = texture.get_size() if texture else Vector2(100, 100)
	var target_size = original_size * 0.3

	var item_img_node = $Control/ColorRect/itemImg if $Control and $Control.has_node("ColorRect/itemImg") else null
	if item_img_node:
		item_img_node.texture = texture
		item_img_node.anchor_left = 0
		item_img_node.anchor_top = 0
		item_img_node.anchor_right = 1
		item_img_node.anchor_bottom = 1
		item_img_node.custom_minimum_size = target_size
		item_img_node.expand = true
		item_img_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# 父容器和背景同理
	if $Control:
		$Control.anchor_left = 0
		$Control.anchor_top = 0
		$Control.anchor_right = 1
		$Control.anchor_bottom = 1
		$Control.custom_minimum_size = target_size
		if $Control/ColorRect:
			var color_rect = $Control/ColorRect
			color_rect.anchor_left = 0
			color_rect.anchor_top = 0
			color_rect.anchor_right = 1
			color_rect.anchor_bottom = 1
			color_rect.custom_minimum_size = target_size

	if pickButton:
		pickButton.anchor_left = 0
		pickButton.anchor_top = 0
		pickButton.anchor_right = 1
		pickButton.anchor_bottom = 1
		pickButton.custom_minimum_size = target_size

	# 根据实际场景结构更新路径
	var name_label_node = $Control/ColorRect/CardFrame/CardTitle if $Control and $Control.has_node("ColorRect/CardFrame/CardTitle") else null
	if name_label_node:
		# 确保使用base_displayName作为显示名称
		var display_name = cardInfo.get("base_displayName", cardName)
		name_label_node.text = display_name
		print("设置卡牌标签文本: " + display_name + " 到节点: " + str(name_label_node))
	else:
		print("找不到卡牌标题节点 CardTitle，尝试其他路径")
		# 尝试其他可能的路径
		name_label_node = find_card_title_node()
		if name_label_node:
			var display_name = cardInfo.get("base_displayName", cardName)
			name_label_node.text = display_name
			print("找到替代节点并设置卡牌标签: " + display_name)
		else:
			print("无法找到任何适合显示卡牌名称的节点")
	
	# 更新卡牌的脑区信息
	update_card_region_display()

func set_in_play_area(status: bool):
	is_in_play_area = status
	if is_in_play_area:
		cardCurrentState = cardState.in_play_area
		velocity = Vector2.ZERO
		print(cardName + " set to in_play_area: ", status)
	else:
		cardCurrentState = cardState.following

# 新增：更新卡牌脑区显示的函数
func update_card_region_display():
	# 尝试找到脑区标签节点
	var region_label = find_region_label_node()
	
	if region_label:
		region_label.text = brainRegion
		print("设置卡牌脑区: " + brainRegion + " 到节点: " + str(region_label))
	else:
		print("无法找到脑区标签节点")

# 查找脑区标签节点的辅助函数
func find_region_label_node():
	var possible_paths = [
		"Control/ColorRect/CardFrame/RegionLabel",
		"Control/ColorRect/region",
		"Control/ColorRect/CardFrame/BrainRegion",
		"Control/CardFrame/RegionLabel",
		"ColorRect/RegionLabel",
		"RegionLabel"
	]
	
	for path in possible_paths:
		var node = get_node_or_null(path)
		if node and node is Label:
			print("找到脑区标签节点: " + path)
			return node
	
	# 我们已经有了find_all_labels函数，可以复用它
	var labels = []
	find_all_labels(self, labels)
	
	# 尝试找到名字中包含"Region"的Label
	for label in labels:
		if "region" in label.name.to_lower() or "brain" in label.name.to_lower():
			print("找到可能的脑区标签: " + label.name)
			return label
	
	# 如果找不到明确的脑区标签，尝试使用第二个Label（假设第一个是标题）
	if labels.size() > 1:
		print("使用第二个Label作为脑区标签")
		return labels[1]
		
	return null

# 辅助函数：尝试查找卡牌标题节点
func find_card_title_node():
	# 尝试多种可能的路径
	var possible_paths = [
		"Control/ColorRect/CardFrame/CardTitle",
		"Control/CardFrame/CardTitle", 
		"ColorRect/CardFrame/CardTitle",
		"CardFrame/CardTitle",
		"Control/CardTitle",
		"CardTitle"
	]
	
	for path in possible_paths:
		var node = get_node_or_null(path)
		if node and node is Label:
			print("找到卡牌标题节点: " + path)
			return node
	
	# 找不到就递归搜索场景树中的Label节点
	var labels = []
	find_all_labels(self, labels)
	
	if labels.size() > 0:
		print("通过递归找到" + str(labels.size()) + "个Label节点，使用第一个")
		return labels[0]
	
	return null

# 递归查找所有Label节点
func find_all_labels(node, labels_array):
	for child in node.get_children():
		if child is Label:
			labels_array.append(child)
		find_all_labels(child, labels_array)

# 直接更新卡牌类型图标
func update_card_type_icon():
	var type_icon = $Control/CardTypeIcon
	if type_icon == null:
		print("CardTypeIcon 节点未找到")
		return
		
	print("找到CardTypeIcon节点: " + str(type_icon.get_path()))
	
	# 设置图标可见性
	type_icon.visible = true
	
	# 加载对应的图标
	var icon_path = "res://assets/icons/" + cardType.to_lower() + ".png"
	if ResourceLoader.exists(icon_path):
		type_icon.texture = load(icon_path)
		print("直接设置卡牌类型图标: " + cardType + ", 路径: " + icon_path)
	else:
		print("警告: 找不到图标资源: " + icon_path)
