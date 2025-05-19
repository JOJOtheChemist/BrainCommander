extends BaseCardEffect
class_name AdrenalineSurgeEffect

var attack_damage_multiplier: float = 1.5  # 50% increase

func apply_effect(target: Node) -> void:
    print("AdrenalineSurgeEffect: apply_effect called on target: ", target)
    # Main effect: AV+4, attack damage +50%
    target.modify_av(4)
    print("AdrenalineSurgeEffect: AV modified by +4. Attack damage multiplier: ", attack_damage_multiplier)
    # Note: Attack damage multiplier would be applied in the combat system
    
    # Next turn effect: DM-2
    # This would typically be handled by a turn management system
    # For now, we'll just modify it directly
    target.modify_dm(-2)
    print("AdrenalineSurgeEffect: DM modified by -2 for next turn effect.") 