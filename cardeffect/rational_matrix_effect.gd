extends BaseCardEffect
class_name RationalMatrixEffect

var emotional_damage_reduction: float = 0.7  # 30% reduction

func apply_effect(target: Node) -> void:
    print("RationalMatrixEffect: apply_effect called on target: ", target)
    # Main effect: RV+4, draw 2 cards
    target.modify_rv(4)
    print("RationalMatrixEffect: RV modified by +4. Card draw (2) and emotional damage reduction (", emotional_damage_reduction, ") noted.")
    # Note: Card drawing would be handled by the deck system
    
    # Special effect: 30% reduction in emotional damage
    # This would be handled by the damage calculation system
    pass 