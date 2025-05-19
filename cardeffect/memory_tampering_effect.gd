extends BaseCardEffect
class_name MemoryTamperingEffect

func apply_effect(target: Node) -> void:
    print("MemoryTamperingEffect: apply_effect called on target: ", target)
    # Main effect: MV-2, reverse all action effects
    target.modify_mv(-2)
    print("MemoryTamperingEffect: MV modified by -2. Action effect reversal noted.")
    # Note: Action effect reversal would be handled by the action system
    
    # Check for special condition
    if check_special_condition(target):
        print("MemoryTamperingEffect: Special condition met (MV <= 5).")
        # Special effect: Randomly discard 1 card
        emit_signal("card_discarded", target)
        print("MemoryTamperingEffect: card_discarded signal emitted for target: ", target)
    else:
        print("MemoryTamperingEffect: Special condition not met (MV > 5).")

func check_special_condition(target: Node) -> bool:
    print("MemoryTamperingEffect: check_special_condition called on target: ", target)
    # Special condition: MV ≤ 5
    return target.mv <= 5 