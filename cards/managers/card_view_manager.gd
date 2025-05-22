extends Node
class_name CardViewManager

# 卡面UI组件引用
var card_title: Label               # 卡牌名称
var card_type_icon: TextureRect     # 右上角类别图标
var card_frame: TextureRect         # 卡套背景
var card_image: TextureRect         # 卡牌图片
var cost_container: Control         # 左侧成本区容器
var effect_container: Control       # 右侧效果区容器
var card_effect_text: Label         # 卡牌效果文字
var mechanism_text: Label           # 机制解释文字

# 资源映射
var card_type_icons = {
	"Attack": preload("res://assets/icons/attack.png") if ResourceLoader.exists("res://assets/icons/attack.png") else null,
	"Defense": preload("res://assets/icons/defense.png") if ResourceLoader.exists("res://assets/icons/defense.png") else null,
	"Gain": preload("res://assets/icons/gain.png") if ResourceLoader.exists("res://assets/icons/gain.png") else null,
	"Event": preload("res://assets/icons/event.png") if ResourceLoader.exists("res://assets/icons/event.png") else null
}

var attribute_icons = {
	"RV": preload("res://assets/icons/rv_icon.png") if ResourceLoader.exists("res://assets/icons/rv_icon.png") else null,
	"AV": preload("res://assets/icons/av_icon.png") if ResourceLoader.exists("res://assets/icons/av_icon.png") else null,
	"MV": preload("res://assets/icons/mv_icon.png") if ResourceLoader.exists("res://assets/icons/mv_icon.png") else null,
	"DM": preload("res://assets/icons/dm_icon.png") if ResourceLoader.exists("res://assets/icons/dm_icon.png") else null
}

# 更新卡套资源映射，增加脑区特定卡套
var card_frames = {
	# 脑区卡套
	"伏隔核": preload("res://assets/frames/nucleus_accumbens_frame.png") if ResourceLoader.exists("res://assets/frames/nucleus_accumbens_frame.png") else null,
	"杏仁核": preload("res://assets/frames/amygdala_frame.png") if ResourceLoader.exists("res://assets/frames/amygdala_frame.png") else null,
	"海马体": preload("res://assets/frames/hippocampus_frame.png") if ResourceLoader.exists("res://assets/frames/hippocampus_frame.png") else null,
	"上皮层": preload("res://assets/frames/cortex_frame.png") if ResourceLoader.exists("res://assets/frames/cortex_frame.png") else null
}

# 卡牌类别颜色映射
var card_class_colors = {
	"Attack": Color(1.0, 0.2, 0.2),  # 红色
	"Defense": Color(0.2, 0.2, 1.0),  # 蓝色
	"Gain": Color(0.2, 1.0, 0.2),    # 绿色
	"Event": Color(1.0, 1.0, 0.2)    # 黄色
}

func _init(card_node: Control):
	# 获取各UI组件引用
	card_title = card_node.get_node_or_null("CardTitle")
	card_type_icon = card_node.get_node_or_null("CardTypeIcon")
	card_frame = card_node.get_node_or_null("CardFrame")
	card_image = card_node.get_node_or_null("CardImage")
	cost_container = card_node.get_node_or_null("CostContainer")
	effect_container = card_node.get_node_or_null("EffectContainer")
	card_effect_text = card_node.get_node_or_null("CardEffectText")
	mechanism_text = card_node.get_node_or_null("MechanismText")
	
	# 如果没有找到节点，尝试使用已有的节点结构
	if card_title == null:
		card_title = card_node.get_node_or_null("Control/ColorRect/name")
	
	if card_type_icon == null:
		card_type_icon = card_node.get_node_or_null("Control/ColorRect/CardTypeIcon")
	
	if card_frame == null:
		card_frame = card_node.get_node_or_null("Control/TextureRect")
	
	if card_image == null:
		card_image = card_node.get_node_or_null("Control/ColorRect/itemImg")
		
	# 如果没有找到容器和文本节点，打印警告
	if cost_container == null:
		print("警告: 卡牌节点中未找到 CostContainer")
		
	if effect_container == null:
		print("警告: 卡牌节点中未找到 EffectContainer")
		
	if card_effect_text == null:
		print("警告: 卡牌节点中未找到 CardEffectText")
		
	if mechanism_text == null:
		print("警告: 卡牌节点中未找到 MechanismText")

# 主要更新函数
func update_card_view(card_info_or_name):
	var card_info
	
	# 检查输入是字符串（卡牌名称）还是字典（卡牌信息）
	if card_info_or_name is String:
		# 获取卡牌管理器
		var card_info_manager = get_node_or_null("/root/CardInfoManager")
		if card_info_manager:
			card_info = card_info_manager.get_card_info(card_info_or_name)
			if card_info.empty():
				print("警告: 找不到卡牌信息: " + card_info_or_name)
				return
		else:
			print("错误: 卡牌信息管理器未加载")
			return
	else:
		# 已经是字典
		card_info = card_info_or_name
	
	# 1. 设置卡牌名称
	set_card_title(card_info.get("base_displayName", ""))
	
	# 2. 设置卡牌类别图标
	var card_class = card_info.get("base_cardClass", "")
	set_card_type(card_class)
	
	# 3. 分别设置卡套和图片
	set_card_frame(card_class, card_info.get("Brain Region", ""))
	set_card_image(card_info.get("base_cardName", ""))
	
	# 4. 解析成本和效果
	var effects_text = card_info.get("Effects", "")
	
	# 清空现有的成本和效果显示
	clear_containers()
	
	# 解析成本和效果
	var costs = parse_costs(card_info)
	var effects = parse_effects(effects_text)
	
	# 显示成本
	show_costs(costs)
	
	# 显示效果
	show_effects(effects)
	
	# 5. 设置卡牌效果文字
	set_card_effect_text(effects_text)
	
	# 6. 设置机制解释文字
	set_mechanism_text(card_info.get("Biological Mechanism", ""))

# 设置卡牌名称
func set_card_title(title: String):
	if card_title:
		card_title.text = title

# 设置卡牌类别图标
func set_card_type(card_class: String):
	if card_type_icon == null:
		return
		
	if card_type_icons.has(card_class) and card_type_icons[card_class] != null:
		card_type_icon.texture = card_type_icons[card_class]
	else:
		# 如果没有图标，可以考虑显示文本
		if card_type_icon is TextureRect and card_type_icon.get_parent().has_node("TypeLabel"):
			var type_label = card_type_icon.get_parent().get_node("TypeLabel")
			if type_label is Label:
				type_label.text = card_class
				card_type_icon.visible = false
				type_label.visible = true

# 设置卡套，优先使用脑区卡套，其次使用卡牌类别卡套
func set_card_frame(card_class: String, brain_region: String):
	if card_frame == null:
		return
		
	# 首先检查是否有对应脑区的卡套
	if brain_region != "" and card_frames.has(brain_region) and card_frames[brain_region] != null:
		if card_frame is TextureRect:
			card_frame.texture = card_frames[brain_region]
			return
			
	# 如果没有脑区卡套，再使用卡牌类别卡套
	if card_frames.has(card_class) and card_frames[card_class] != null:
		if card_frame is TextureRect:
			card_frame.texture = card_frames[card_class]
			return
	
	# 如果没有任何卡套可用，使用默认白色
	card_frame.modulate = Color.WHITE

# 设置卡牌图片
func set_card_image(card_name: String):
	if card_image == null:
		return
		
	# 首先尝试加载特定卡牌的图片
	var img_path = "res://cardImg/" + card_name + ".png"
	
	# 检查特定卡牌图片是否存在
	if ResourceLoader.exists(img_path):
		card_image.texture = load(img_path)
	else:
		# 如果特定卡牌图片不存在，尝试根据卡牌信息加载通用图片
		# 获取卡牌信息
		var card_info_manager = get_node_or_null("/root/CardInfoManager")
		if card_info_manager and card_info_manager.infosDic.has(card_name):
			var info = card_info_manager.infosDic[card_name]
			var brain_region = info.get("Brain Region", "")
			var card_class = info.get("base_cardClass", "")
			
			# 尝试加载基于脑区和类别的通用图片
			var region_path = ""
			match brain_region:
				"杏仁核":
					region_path = "res://assets/images/amygdala_"
				"伏隔核":
					region_path = "res://assets/images/nucleus_accumbens_"
				"前额叶皮层":
					region_path = "res://assets/images/prefrontal_cortex_"
				"海马体":
					region_path = "res://assets/images/hippocampus_"
			
			# 添加卡牌类别
			var class_suffix = card_class.to_lower() + ".png"
			var combined_path = region_path + class_suffix
			
			if region_path != "" and ResourceLoader.exists(combined_path):
				card_image.texture = load(combined_path)
			elif card_class != "" and ResourceLoader.exists("res://assets/images/" + class_suffix):
				# 仅使用类别的通用图片
				card_image.texture = load("res://assets/images/" + class_suffix)
			else:
				# 使用默认图片
				var default_path = "res://assets/images/default_card.png"
				if ResourceLoader.exists(default_path):
					card_image.texture = load(default_path)
				else:
					print("警告: 找不到卡牌图片: " + card_name)
		else:
			print("警告: 找不到卡牌信息: " + card_name)

# 清空成本和效果容器
func clear_containers():
	if cost_container:
		for child in cost_container.get_children():
			child.queue_free()
			
	if effect_container:
		for child in effect_container.get_children():
			child.queue_free()

# 解析卡牌成本
func parse_costs(card_info: Dictionary) -> Dictionary:
	var result = {"RV": 0, "AV": 0, "MV": 0, "DM": 0}
	
	# 这里需要根据你的卡牌数据结构确定成本字段
	# 假设成本存在 base_cost_rv, base_cost_av 等字段
	if card_info.has("base_cost_rv"):
		result["RV"] = int(card_info["base_cost_rv"])
	
	if card_info.has("base_cost_av"):
		result["AV"] = int(card_info["base_cost_av"])
	
	if card_info.has("base_cost_mv"):
		result["MV"] = int(card_info["base_cost_mv"])
	
	if card_info.has("base_cost_dm"):
		result["DM"] = int(card_info["base_cost_dm"])
	
	return result

# 解析卡牌效果
func parse_effects(effects_text: String) -> Dictionary:
	var result = {"RV": 0, "AV": 0, "MV": 0, "DM": 0}
	
	# 使用正则表达式查找所有属性变化
	var regexes = {
		"RV": RegEx.new(),
		"AV": RegEx.new(),
		"MV": RegEx.new(),
		"DM": RegEx.new()
	}
	
	regexes["RV"].compile("RV[（(理性值）]*([+-]\\d+)")
	regexes["AV"].compile("AV[（(警觉值|杏仁核值）]*([+-]\\d+)")
	regexes["MV"].compile("MV[（(记忆值）]*([+-]\\d+)")
	regexes["DM"].compile("DM[（(多巴胺值）]*([+-]\\d+)")
	
	for key in regexes.keys():
		var match = regexes[key].search(effects_text)
		if match:
			result[key] = int(match.get_string(1))
	
	return result

# 显示成本
func show_costs(costs: Dictionary):
	if cost_container == null:
		return
	
	for attr in costs.keys():
		if costs[attr] > 0:
			var cost_entry = create_attribute_entry(attr, costs[attr], true)
			cost_container.add_child(cost_entry)

# 显示效果
func show_effects(effects: Dictionary):
	if effect_container == null:
		return
	
	for attr in effects.keys():
		if effects[attr] != 0:
			var effect_entry = create_attribute_entry(attr, effects[attr], false)
			effect_container.add_child(effect_entry)

# 创建属性条目（图标+数值）
func create_attribute_entry(attr_type: String, value: int, is_cost: bool) -> Control:
	# 创建水平容器
	var h_box = HBoxContainer.new()
	
	# 创建图标
	var icon = TextureRect.new()
	if attribute_icons.has(attr_type) and attribute_icons[attr_type] != null:
		icon.texture = attribute_icons[attr_type]
	icon.expand = true
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(24, 24)
	
	# 创建数值标签
	var label = Label.new()
	if is_cost:
		label.text = str(value)  # 成本用正数
	else:
		label.text = ("%+d" % value)  # 效果用带符号形式
	
	# 设置颜色
	if not is_cost and value > 0:
		label.modulate = Color(0.2, 1.0, 0.2)  # 正面效果为绿色
	elif not is_cost and value < 0:
		label.modulate = Color(1.0, 0.2, 0.2)  # 负面效果为红色
	
	# 添加到容器
	h_box.add_child(icon)
	h_box.add_child(label)
	
	return h_box

# 设置卡牌效果文字
func set_card_effect_text(effect: String):
	if card_effect_text:
		card_effect_text.text = effect

# 设置机制解释文字
func set_mechanism_text(mechanism: String):
	if mechanism_text:
		mechanism_text.text = mechanism 
