extends Node
class_name CardFrameManager

# 存储框架路径映射
var brain_region_to_frame = {
	"杏仁核": "res://assets/frames/amygdala_frame.png",
	"伏隔核": "res://assets/frames/nucleus_accumbens_frame.png",
	"前额叶皮层": "res://assets/frames/cortex_frame.png",
	"海马体": "res://assets/frames/hippocampus_frame.png"
}

# 默认框架
var default_frame_path = "res://assets/frames/nucleus_accumbens_frame.png" # 如果没有默认框架，使用已有的任一框架

# 当前卡牌引用
var _card: Node

func _init(card_node: Node) -> void:
	_card = card_node

# 根据脑区更新框架
func update_frame(brain_region: String) -> void:
	var frame_path = brain_region_to_frame.get(brain_region, default_frame_path)
	
	# 尝试加载框架纹理
	var frame_texture = load(frame_path) if ResourceLoader.exists(frame_path) else null
	
	if frame_texture:
		var frame_sprite = find_frame_sprite()
		if frame_sprite and (frame_sprite is TextureRect or frame_sprite is Sprite2D):
			frame_sprite.texture = frame_texture
			print("更新卡牌框架: " + brain_region + " -> " + frame_path)
	else:
		print("无法加载框架纹理: " + frame_path)

# 查找卡牌框架的精灵节点
func find_frame_sprite() -> Node:
	# 首先尝试精确路径
	var exact_paths = [
		"Control/ColorRect/CardFrame",
		"CardFrame"
	]
	
	for path in exact_paths:
		var node = _card.get_node_or_null(path)
		if node and (node is TextureRect or node is Sprite2D):
			print("找到框架节点: " + path)
			return node
			
	# 若找不到，使用场景树中的节点名查找
	var nodes = _find_nodes_by_name(_card, "CardFrame")
	for node in nodes:
		if node is TextureRect or node is Sprite2D:
			print("通过名称找到框架节点: " + node.name)
			return node
			
	print("无法找到合适的卡牌框架节点")
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