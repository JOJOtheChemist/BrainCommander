extends Node
class_name CardFrameManager

# 存储框架路径映射
var brain_region_to_frame = {
	# 中文名称
	"杏仁核": "res://assets/frames/amygdala_frame.png",
	"伏隔核": "res://assets/frames/nucleus_accumbens_frame.png",
	"前额叶皮层": "res://assets/frames/cortex_frame.png",
	"海马体": "res://assets/frames/hippocampus_frame.png",
	
	# 英文名称
	"amygdala": "res://assets/frames/amygdala_frame.png",
	"nucleus_accumbens": "res://assets/frames/nucleus_accumbens_frame.png",
	"nucleus accumbens": "res://assets/frames/nucleus_accumbens_frame.png",
	"cortex": "res://assets/frames/cortex_frame.png",
	"prefrontal cortex": "res://assets/frames/cortex_frame.png",
	"hippocampus": "res://assets/frames/hippocampus_frame.png"
}

# 默认框架
var default_frame_path = "res://assets/frames/nucleus_accumbens_frame.png" # 如果没有默认框架，使用已有的任一框架

# 当前卡牌引用
var _card: Node

func _init(card_node: Node) -> void:
	_card = card_node
	# 打印调试信息
	print("CardFrameManager 初始化, 卡牌节点: ", _card.name)

# 规范化脑区名称（转换为小写并移除多余空格）
func normalize_region_name(region: String) -> String:
	return region.strip_edges().to_lower().replace(" ", "_")

# 根据脑区更新框架
func update_frame(brain_region: String) -> void:
	print("========== 开始更新框架 ==========")
	print("脑区: " + brain_region)
	
	# 尝试直接匹配
	var frame_path = brain_region_to_frame.get(brain_region, "")
	
	# 如果直接匹配失败，尝试规范化名称后匹配
	if frame_path == "":
		var normalized_region = normalize_region_name(brain_region)
		print("规范化后的脑区名称: " + normalized_region)
		frame_path = brain_region_to_frame.get(normalized_region, "")
		
		# 如果规范化匹配也失败，尝试通用匹配
		if frame_path == "":
			for key in brain_region_to_frame.keys():
				if key.to_lower() == normalized_region:
					frame_path = brain_region_to_frame[key]
					print("通过通用匹配找到框架: " + key)
					break
	
	# 如果所有匹配都失败，使用默认框架
	if frame_path == "":
		frame_path = default_frame_path
		print("使用默认框架: " + frame_path)
	else:
		print("找到匹配框架: " + frame_path)
	
	# 尝试加载框架纹理
	var frame_texture = null
	if ResourceLoader.exists(frame_path):
		frame_texture = load(frame_path)
		print("成功加载纹理: " + frame_path)
		print("纹理对象信息: " + str(frame_texture))
	else:
		print("错误: 无法加载框架纹理，路径不存在: " + frame_path)
		return
	
	# 查找并更新框架节点
	var frame_sprite = find_frame_sprite()
	
	print("查找到的框架节点: " + str(frame_sprite))
	if frame_sprite == null:
		print("错误: 找不到框架节点，无法更新")
		return
		
	# 检查节点类型
	print("框架节点类型: " + frame_sprite.get_class())
	if not (frame_sprite is TextureRect or frame_sprite is Sprite2D):
		print("错误: 框架节点不是纹理或精灵类型")
		return
		
	# 保存并打印旧纹理信息
	var old_texture = null
	if frame_sprite.has_method("get_texture"):
		old_texture = frame_sprite.texture
		print("更新前的纹理: " + str(old_texture))
	
	# 更新纹理
	frame_sprite.texture = frame_texture
	print("纹理已设置为: " + str(frame_texture))
	
	# 再次检查是否更新成功
	if frame_sprite.has_method("get_texture"):
		print("更新后的纹理: " + str(frame_sprite.texture))
		
	# 强制重绘 (不使用update方法，该方法在Godot 4.x中被移除)
	if frame_sprite is Control:
		frame_sprite.queue_redraw()
		print("调用queue_redraw请求重绘")
	
	# 更新父节点
	var parent = frame_sprite.get_parent()
	if parent and parent is Control:
		parent.queue_redraw()
		print("调用父节点的queue_redraw: " + parent.name)
			
	print("=========== 框架更新完成 ===========")

# 查找卡牌框架的精灵节点
func find_frame_sprite() -> Node:
	print("========== 开始查找框架节点 ==========")
	
	# 检查卡牌有效性
	if _card == null:
		print("错误: 卡牌对象为空")
		return null
	
	# 首先尝试精确路径
	var exact_paths = [
		"Control/ColorRect/CardFrame",
		"Control/CardFrame",
		"CardFrame",
		"ColorRect/CardFrame"
	]
	
	print("尝试的路径: " + str(exact_paths))
	for path in exact_paths:
		var node = _card.get_node_or_null(path)
		if node:
			print("找到路径 " + path + " 的节点: " + str(node) + ", 类型: " + node.get_class())
			if node is TextureRect or node is Sprite2D:
				print("成功: 使用路径找到框架节点: " + path)
				return node
			
	# 第二步：使用场景树中的节点名查找
	print("使用节点名称查找框架...")
	var nodes = _find_nodes_by_name(_card, "CardFrame")
	print("通过名称找到 " + str(nodes.size()) + " 个节点")
	
	for node in nodes:
		print("找到名为 CardFrame 的节点: " + str(node) + ", 类型: " + node.get_class())
		if node is TextureRect or node is Sprite2D:
			print("成功: 通过精确名称找到框架节点: " + node.name)
			return node
			
	# 第三步：递归查找所有纹理节点，并进行名称模糊匹配
	print("尝试模糊匹配查找框架节点...")
	var textures = []
	find_all_texture_nodes(_card, textures)
	print("找到 " + str(textures.size()) + " 个纹理节点")
	
	# 打印每个纹理节点的信息
	for i in range(textures.size()):
		print("纹理节点 " + str(i) + ": " + textures[i].name + ", 类型: " + textures[i].get_class())
	
	# 优先查找名称包含"frame"的节点
	for tex_node in textures:
		if "frame" in tex_node.name.to_lower() or ("card" in tex_node.name.to_lower() and "frame" in tex_node.name.to_lower()):
			print("成功: 通过名称模糊匹配找到框架节点: " + tex_node.name)
			return tex_node
	
	# 如果有多个纹理节点，尝试找到最可能是框架的纹理（通常是覆盖整个卡面的较大纹理）
	if textures.size() > 1:
		var largest_texture = null
		var largest_size = 0
		
		for tex_node in textures:
			# 排除明显是卡牌图片的纹理
			if tex_node.name != "itemImg" and tex_node.name != "CardTypeIcon":
				var rect = tex_node.get_rect()
				var rect_size = rect.size.x * rect.size.y
				print("节点 " + tex_node.name + " 的尺寸: " + str(rect.size) + ", 面积: " + str(rect_size))
				if rect_size > largest_size:
					largest_size = rect_size
					largest_texture = tex_node
		
		if largest_texture:
			print("成功: 使用找到的最大纹理节点作为框架: " + largest_texture.name)
			return largest_texture
	
	# 如果仍然找不到，但有纹理节点，使用第一个非卡牌图片的纹理
	if textures.size() > 0:
		for tex_node in textures:
			if tex_node.name != "itemImg" and tex_node.name != "CardTypeIcon":
				print("成功: 使用备选纹理节点作为框架: " + tex_node.name)
				return tex_node
			
	print("失败: 无法找到合适的卡牌框架节点")
	print("=========== 框架节点查找结束 ===========")
	return null

# 根据名称查找节点
func _find_nodes_by_name(parent: Node, name: String) -> Array:
	var result = []
	if parent.name == name:
		result.append(parent)
		
	for child in parent.get_children():
		result.append_array(_find_nodes_by_name(child, name))
		
	return result

# 递归查找所有纹理节点
func find_all_texture_nodes(node: Node, textures_array: Array) -> void:
	for child in node.get_children():
		if child is TextureRect or child is Sprite2D:
			if child.name != "itemImg": # 排除卡牌主图
				textures_array.append(child)
		find_all_texture_nodes(child, textures_array) 
