extends BaseCardEffect
class_name ExperienceDownloadEffect

func apply_effect(target: Node) -> void:
    print("ExperienceDownloadEffect: apply_effect called on target: ", target)
    # Main effect: MV+3, copy 1 card
    target.modify_mv(3)
    print("ExperienceDownloadEffect: MV modified by +3. Card copy and special event effect noted.")
    # Note: Card copying would be handled by the deck system
    
    # Special effect: If copied card is an event card, gain its effect
    # This would be handled by the card effect system
    pass 