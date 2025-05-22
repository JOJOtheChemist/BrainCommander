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

# 资源映射 - 只保留卡牌类型图标
var card_type_icons = {
	"Attack": preload("res://assets/icons/attack.png") if ResourceLoader.exists("res://assets/icons/attack.png") else null,
	"Defense": preload("res://assets/icons/defense.png") if ResourceLoader.exists("res://assets/icons/defense.png") else null,
	"Gain": preload("res://assets/icons/gain.png") if ResourceLoader.exists("res://assets/icons/gain.png") else null,
	"Event": preload("res://assets/icons/event.png") if ResourceLoader.exists("res://assets/icons/event.png") else null
}

# 删除attribute_icons预加载，改成使用颜色或文本
var attribute_colors = {
	"RV": Color(0.2, 0.7, 1.0),  # 蓝色
	"AV": Color(1.0, 0.3, 0.3),  # 红色
	"MV": Color(0.8, 0.3, 0.8),  # 紫色
	"DM": Color(1.0, 0.8, 0.2)   # 金色
}



# 卡套资源映射，使用assets/frames目录下的图片
var card_frames = {
	"nucleus_accumbens": preload("res://assets/frames/nucleus_accumbens_frame.png") if ResourceLoader.exists("res://assets/frames/nucleus_accumbens_frame.png") else null,
	"amygdala": preload("res://assets/frames/amygdala_frame.png") if ResourceLoader.exists("res://assets/frames/amygdala_frame.png") else null,
	"hippocampus": preload("res://assets/frames/hippocampus_frame.png") if ResourceLoader.exists("res://assets/frames/hippocampus_frame.png") else null,
	"cortex": preload("res://assets/frames/cortex_frame.png") if ResourceLoader.exists("res://assets/frames/cortex_frame.png") else null
}

func _init(card_node: Control):
	# 根据场景树结构精确查找UI组件
	# CardTypeIcon是Control的直接子节点
	print("开始查找CardTypeIcon节点...")
	print("卡牌节点路径: ", card_node.get_path())
	print("卡牌节点的直接子节点: ")
	for child in card_node.get_children():
		print("- ", child.name, " (", child.get_class(), ")")
	
	# 尝试直接获取CardTypeIcon节点
	if card_node.has_node("CardTypeIcon"):
		card_type_icon = card_node.get_node("CardTypeIcon")
		print("直接找到CardTypeIcon: ", card_type_icon.get_path())
	else:
		print("直接子节点中没有CardTypeIcon，尝试递归查找")
		card_type_icon = find_exact_node(card_node, "CardTypeIcon")
	
	# 其他组件继续使用递归查找
	card_title = _find_node_by_name(card_node, "CardTitle")
	card_frame = _find_node_by_name(card_node, "CardFrame")
	card_image = _find_node_by_name(card_node, "itemImg")
	
	# 查找成本和效果容器及文本
	cost_container = _find_node_by_name(card_node, "costarea")
	effect_container = _find_node_by_name(card_node, "effectContainer")
	card_effect_text = _find_node_by_name(card_node, "CardEffectText")
	mechanism_text = _find_node_by_name(card_node, "MechanismText")
	
	# 检查并打印结果
	print("CardViewManager初始化: ")
	print("- 卡牌标题: ", card_title != null)
	print("- 卡牌类型图标: ", card_type_icon != null, " 路径: ", get_node_path(card_type_icon))
	if card_type_icon != null:
		print("  图标类型: ", card_type_icon.get_class())
		print("  图标可见性: ", card_type_icon.visible)
		if card_type_icon is TextureRect:
			print("  当前图标纹理: ", card_type_icon.texture)
	print("- 卡牌框架: ", card_frame != null)
	print("- 卡牌图片: ", card_image != null)
	print("- 成本容器: ", cost_container != null)
	print("- 效果容器: ", effect_container != null)
	print("- 效果文本: ", card_effect_text != null)
	print("- 机制文本: ", mechanism_text != null)

func _ready():
	# 打印图标资源加载状态
	print("图标资源加载状态:")
	print("- Attack 图标: ", card_type_icons["Attack"] != null)
	print("- Defense 图标: ", card_type_icons["Defense"] != null)
	print("- Gain 图标: ", card_type_icons["Gain"] != null)
	print("- Event 图标: ", card_type_icons["Event"] != null)

# 获取节点的完整路径（用于调试）
func get_node_path(node: Node) -> String:
	if node == null:
		return "null"
	return node.get_path()

# 查找卡牌场景中的精确节点
func find_exact_node(card_node: Control, name: String) -> Node:
	# 首先尝试直接子节点
	if card_node.has_node(name):
		var node = card_node.get_node(name)
		print("找到精确节点(直接子节点): " + name)
		return node
		
	# 然后尝试二级子节点
	for child in card_node.get_children():
		if child.has_node(name):
			var node = child.get_node(name)
			print("找到精确节点(二级子节点): " + name)
			return node
			
	# 最后使用递归查找
	var node = _find_node_by_name(card_node, name)
	if node:
		print("找到精确节点(递归): " + name)
	return node

# 通过名称递归查找节点
func _find_node_by_name(parent: Node, name: String) -> Node:
	if parent.name == name:
		return parent
		
	for child in parent.get_children():
		var found = _find_node_by_name(child, name)
		if found != null:
			return found
			
	return null

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
	
	# 2. 设置卡牌类别图标 - 优先使用CardType字段，其次使用base_cardType
	var card_type = card_info.get("CardType", "")
	if card_type == "":
		card_type = card_info.get("base_cardType", "")
	
	print("卡牌 " + card_info.get("base_cardName", "") + " 的类型是: " + card_type)
	set_card_type(card_type)
	
	# 3. 设置卡套
	var brain_region = card_info.get("Brain Region", "")
	set_card_frame(brain_region)
	
	# 4. 设置卡牌图片
	set_card_image(card_info.get("base_cardName", ""))
	
	# 5. 解析成本和效果
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
	
	# 6. 设置卡牌效果文字
	set_card_effect_text(effects_text)
	
	# 7. 设置机制解释文字
	set_mechanism_text(card_info.get("Biological Mechanism", ""))

# 设置卡牌名称
func set_card_title(title: String):
	if card_title:
		card_title.text = title

# 设置卡牌类别图标
func set_card_type(card_type: String):
	if card_type_icon == null:
		print("错误: CardTypeIcon节点未找到，无法设置图标")
		return
		
	# 确定要使用的图标
	var icon_key = card_type.strip_edges()
	print("设置卡牌类型: " + icon_key)
	
	# 检查图标路径是否存在
	var icon_path = "res://assets/icons/" + icon_key.to_lower() + ".png"
	print("检查图标路径: " + icon_path + ", 资源存在: " + str(ResourceLoader.exists(icon_path)))
	
	# 尝试直接加载图标（不使用预加载）
	var texture = null
	
	# 方法1: 使用预加载的资源（大小写敏感匹配）
	if icon_key in card_type_icons and card_type_icons[icon_key] != null:
		texture = card_type_icons[icon_key]
		print("方法1: 使用预加载资源，键匹配: " + icon_key)
	
	# 方法2: 尝试不区分大小写的键匹配
	if texture == null:
		for key in card_type_icons.keys():
			if key.to_lower() == icon_key.to_lower() and card_type_icons[key] != null:
				texture = card_type_icons[key]
				print("方法2: 不区分大小写匹配成功，键: " + key)
				break
	
	# 方法3: 直接加载资源
	if texture == null and ResourceLoader.exists(icon_path):
		texture = load(icon_path)
		print("方法3: 直接加载资源: " + icon_path)
	
	# 方法4: 尝试加载小写文件名
	if texture == null:
		var lowercase_path = "res://assets/icons/" + icon_key.to_lower() + ".png"
		if ResourceLoader.exists(lowercase_path):
			texture = load(lowercase_path)
			print("方法4: 加载小写文件名资源: " + lowercase_path)
	
	# 设置纹理
	if texture != null:
		if card_type_icon is TextureRect:
			print("设置图标之前状态: 可见性=", card_type_icon.visible, ", 纹理=", card_type_icon.texture)
			card_type_icon.texture = texture
			card_type_icon.visible = true
			print("成功设置卡牌类型图标! 新纹理=", texture, ", 可见性=", card_type_icon.visible)
			
			# 强制重绘 (使用queue_redraw而不是已被移除的update方法)
			if card_type_icon is Control:
				card_type_icon.queue_redraw()
				print("请求重绘图标")
			
			# 更新父节点
			var parent = card_type_icon.get_parent()
			if parent and parent is Control:
				parent.queue_redraw()
				print("请求重绘父节点: " + parent.name)
		else:
			print("错误: CardTypeIcon不是TextureRect类型，而是: " + card_type_icon.get_class())
	else:
		# 无法找到图标时隐藏
		if card_type_icon:
			card_type_icon.visible = false
			print("警告: 无法找到图标，隐藏CardTypeIcon")

# 添加一个新函数：规范化脑区名称（转换为小写并移除空格）
func normalize_brain_region(region: String) -> String:
	return region.strip_edges().to_lower().replace(" ", "_")

# 设置卡套，使用脑区对应的框架图片
func set_card_frame(brain_region: String):
	if card_frame == null:
		print("未找到卡牌框架节点，尝试搜索...")
		card_frame = find_card_frame_node()
		if card_frame == null:
			print("警告: 找不到卡牌框架节点，无法设置框架")
			return
		
	print("设置卡套，脑区: " + brain_region)
		
	# 根据脑区选择对应的框架图片
	var frame_texture = null
	var normalized_region = normalize_brain_region(brain_region)
	print("规范化后的脑区名称: " + normalized_region)
	
	if brain_region != "":
		# 方法1：直接匹配（大小写敏感）
		if brain_region in card_frames and card_frames[brain_region] != null:
			frame_texture = card_frames[brain_region]
			print("方法1: 直接匹配框架: " + brain_region)
		
		# 方法2：尝试规范化后的键匹配
		elif normalized_region in card_frames and card_frames[normalized_region] != null:
			frame_texture = card_frames[normalized_region]
			print("方法2: 规范化匹配框架: " + normalized_region)
		
		# 方法3：尝试不区分大小写的键匹配
		else:
			for key in card_frames.keys():
				if key.to_lower() == normalized_region and card_frames[key] != null:
					frame_texture = card_frames[key]
					print("方法3: 不区分大小写匹配框架: " + key)
					break
			
			# 如果上述方法都失败，尝试直接加载
			if frame_texture == null:
				# 确定备用框架名
				var frame_name = ""
				match normalized_region:
					"amygdala": 
						frame_name = "amygdala_frame"
					"nucleus_accumbens", "nucleus accumbens": 
						frame_name = "nucleus_accumbens_frame"
					"cortex", "prefrontal_cortex", "prefrontal cortex": 
						frame_name = "cortex_frame"
					"hippocampus": 
						frame_name = "hippocampus_frame"
					_: 
						print("未匹配的脑区: " + normalized_region + "，使用默认框架")
						frame_name = "nucleus_accumbens_frame" # 默认框架
				
				# 尝试直接加载
				var frame_path = "res://assets/frames/" + frame_name + ".png"
				print("尝试加载框架: " + frame_path)
				if ResourceLoader.exists(frame_path):
					frame_texture = load(frame_path)
					print("方法4: 直接加载框架: " + frame_path)
				else:
					print("错误: 找不到框架文件: " + frame_path)
	
	# 如果成功找到纹理，应用它
	if frame_texture != null:
		print("设置前的框架: " + str(card_frame.texture))
		card_frame.texture = frame_texture
		print("成功设置卡片框架: " + brain_region + ", 新框架: " + str(card_frame.texture))
		
		# 强制重绘
		if card_frame is Control:
			card_frame.queue_redraw()
			print("请求重绘框架")
			
		# 更新父节点
		var parent = card_frame.get_parent()
		if parent and parent is Control:
			parent.queue_redraw()
			print("请求重绘父节点: " + parent.name)
	else:
		print("警告: 无法为脑区 " + brain_region + " 找到合适的框架")

# 查找卡片框架节点
func find_card_frame_node() -> TextureRect:
	# 首先尝试多种直接路径
	var possible_paths = [
		"Control/ColorRect/CardFrame",
		"Control/CardFrame",
		"CardFrame",
		"ColorRect/CardFrame"
	]
	
	for path in possible_paths:
		var node = get_node_or_null(path)
		if node and node is TextureRect:
			print("使用路径找到卡片框架节点: " + path)
			return node
	
	# 递归查找所有TextureRect节点
	print("使用递归查找卡片框架节点...")
	var texture_rects = []
	find_all_texture_rects(self.get_parent(), texture_rects)
	
	# 优先通过名称匹配
	for tex_rect in texture_rects:
		if "cardframe" in tex_rect.name.to_lower() or "frame" in tex_rect.name.to_lower():
			print("通过名称匹配找到框架节点: " + tex_rect.name)
			return tex_rect
	
	# 查找最大的非主图纹理作为背景框架
	if texture_rects.size() > 1:
		var largest_rect = null
		var largest_size = 0
		
		for tex_rect in texture_rects:
			if tex_rect.name != "itemImg" and tex_rect.name != "CardTypeIcon":
				var size = tex_rect.get_rect().size.x * tex_rect.get_rect().size.y
				if size > largest_size:
					largest_size = size
					largest_rect = tex_rect
		
		if largest_rect:
			print("使用找到的最大纹理作为卡片框架: " + largest_rect.name)
			return largest_rect
	
	return null

# 递归查找所有TextureRect节点
func find_all_texture_rects(node, texture_rects_array):
	if node == null:
		print("警告: 传入节点为空，无法查找纹理节点")
		return
		
	for child in node.get_children():
		if child is TextureRect:
			texture_rects_array.append(child)
		find_all_texture_rects(child, texture_rects_array)

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
			var card_class = info.get("base_cardType", "")  # 改为使用 base_cardType
			
			# 尝试加载基于脑区和类别的通用图片
			var region_path = ""
			match brain_region:
				"amygdala":
					region_path = "res://assets/images/amygdala_"
				"nucleus_accumbens":
					region_path = "res://assets/images/nucleus_accumbens_"
				"cortex":
					region_path = "res://assets/images/prefrontal_cortex_"
				"hippocampus":
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
	
	# 创建属性标签（不再使用图标）
	var attr_label = Label.new()
	attr_label.text = attr_type
	if attr_type in attribute_colors:
		attr_label.modulate = attribute_colors[attr_type]
	attr_label.custom_minimum_size = Vector2(30, 24)
	
	# 创建数值标签
	var value_label = Label.new()
	if is_cost:
		value_label.text = str(value)  # 成本用正数
	else:
		value_label.text = ("%+d" % value)  # 效果用带符号形式
	
	# 设置颜色
	if not is_cost and value > 0:
		value_label.modulate = Color(0.2, 1.0, 0.2)  # 正面效果为绿色
	elif not is_cost and value < 0:
		value_label.modulate = Color(1.0, 0.2, 0.2)  # 负面效果为红色
	
	# 添加到容器
	h_box.add_child(attr_label)
	h_box.add_child(value_label)
	
	return h_box

# 设置卡牌效果文字
func set_card_effect_text(effect: String):
	if card_effect_text:
		card_effect_text.text = effect

# 设置机制解释文字
func set_mechanism_text(mechanism: String):
	if mechanism_text:
		mechanism_text.text = mechanism 
