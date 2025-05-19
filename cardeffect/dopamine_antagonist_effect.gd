extends BaseCardEffect
class_name DopamineAntagonistEffect

func apply_effect(target: Node) -> void:
    print("DopamineAntagonistEffect: apply_effect called on target: ", target)
    # Main effect: DM-3, cannot gain resources this turn
    target.modify_dm(-3)
    print("DopamineAntagonistEffect: DM modified by -3. Resource gain prevention noted.")
    # Note: Resource gain prevention would be handled by the resource system
    
    # Check for special condition
    if check_special_condition(target):
        print("DopamineAntagonistEffect: Special condition met (DM <= 3). Skip next turn noted.")
        # Special effect: Skip next turn
        # This would typically be handled by the turn management system
        pass
    else:
        print("DopamineAntagonistEffect: Special condition not met (DM > 3).")

func check_special_condition(target: Node) -> bool:
    print("DopamineAntagonistEffect: check_special_condition called on target: ", target)
    # Special condition: DM ≤ 3
    return target.dm <= 3 