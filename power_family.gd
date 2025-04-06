extends Node

enum PowerType {
	POWER_TARGETTING_ANY_COIN, POWER_TARGETTING_MONSTER_COIN, POWER_TARGETTING_PLAYER_COIN, 
	POWER_NON_TARGETTING,
	
	PASSIVE,
	
	CHARON,
	
	# monsters
	PAYOFF_GAIN_SOULS, PAYOFF_LOSE_SOULS,
	PAYOFF_LOSE_LIFE, PAYOFF_GAIN_LIFE,
	PAYOFF_GAIN_ARROWS, 
	PAYOFF_STOKE_FLAME,
	PAYOFF_DO_NOTHING,
	PAYOFF_IGNITE_SELF, PAYOFF_IGNITE, PAYOFF_UNLUCKY, PAYOFF_CURSE, PAYOFF_BLANK, PAYOFF_LUCKY, PAYOFF_BURY_SELF_BOAR,
	PAYOFF_TROJAN_HORSE, PAYOFF_ALL_MONSTER_UNLUCKY, PAYOFF_FREEZE, PAYOFF_GAIN_THORNS_GADFLY,
	PAYOFF_INCREASE_PENALTY, PAYOFF_BURY_LAMIA, PAYOFF_BURY_OREAD, PAYOFF_TRANSFORM, PAYOFF_BLESS, PAYOFF_GAIN_OBOL,
	PAYOFF_DECREASE_COST, PAYOFF_INCREASE_COST, PAYOFF_DESTROY_SELF, PAYOFF_CURSE_UNLUCKY_SELF, PAYOFF_DOWNGRADE, PAYOFF_DOOM_RIGHTMOST,
	PAYOFF_GAIN_THORNS_SPHINX, PAYOFF_DOWNGRADE_AND_PRIME, PAYOFF_BURY_CYCLOPS, PAYOFF_FREEZE_TAILS, PAYOFF_HALVE_LIFE, 
	PAYOFF_UPGRADE_SELF,
	
	# nemesis
	PAYOFF_STONE, PAYOFF_DOWNGRADE_MOST_VALUABLE,
	PAYOFF_SPAWN_STRONG, PAYOFF_SPAWN_FLEETING, PAYOFF_UPGRADE_MONSTERS, PAYOFF_BLESS_MONSTERS,
	PAYOFF_PERMANENTLY_IGNITE_MONSTER, PAYOFF_AMPLIFY_IGNITE, PAYOFF_INCREASE_ALL_PENALTY, PAYOFF_DESECRATE,
	PAYOFF_SHUFFLE, PAYOFF_BLANK_LEFT_HALF, PAYOFF_BLANK_RIGHT_HALF,
	PAYOFF_CURSE_UNLUCKY_SCALING_MINOTAUR, PAYOFF_A_WAY_OUT, PAYOFF_UNLUCKY_SELF, PAYOFF_FREEZE_SELF, PAYOFF_BURY_SELF_LABYRINTH
}

class PowerFamily:
	enum Tag {
		REFLIP, FREEZE, LUCKY, GAIN, DESTROY, UPGRADE, HEAL, POSITIONING, CURSE, BLESS, TURN, TRADE, IGNITE, ANTIMONSTER, STONE, BLANK, CONSECRATE, DOOM, BURY, CHARGE
	}
	
	var description: String:
		get:
			return Global.replace_placeholders(description)
	var uses_for_denom: Array[int]
	var power_type: PowerType
	var icon_path: String
	var prefer_icon_only: bool
	var tags: Array
	
	func _init(desc: String, uses_per_denom: Array[int], pwrType: PowerType, icon: String, pref_icn_only: bool, tgs: Array = []) -> void:
		self.description = desc
		self.uses_for_denom = uses_per_denom
		self.power_type = pwrType
		self.icon_path = icon
		self.prefer_icon_only = pref_icn_only
		assert(FileAccess.file_exists(self.icon_path))
		self.tags = tgs
	
	func get_power_type_placeholder() -> String:
		if is_power():
			return "(POWER)"
		if is_passive():
			return "(PASSIVE)"
		if is_payoff():
			if power_type == PowerType.PAYOFF_GAIN_SOULS or power_type == PowerType.PAYOFF_LOSE_SOULS:
				return "(PAYOFF_SOULS)"
			elif power_type == PowerType.PAYOFF_LOSE_LIFE:
				return "(PAYOFF_LIFE)"
			elif power_type == PowerType.PAYOFF_STOKE_FLAME:
				return "(PAYOFF_FLAME)"
			elif power_type == PowerType.PAYOFF_GAIN_ARROWS or power_type == PowerType.PAYOFF_DO_NOTHING:
				return "(PAYOFF_OTHER)"
			else:
				return "(PAYOFF_PURPLE)"
		assert(is_charon())
		return ""
	
	func is_payoff() -> bool:
		return power_type != PowerType.POWER_TARGETTING_ANY_COIN and\
			power_type != PowerType.POWER_TARGETTING_MONSTER_COIN and\
			power_type != PowerType.POWER_TARGETTING_PLAYER_COIN and\
			power_type != PowerType.POWER_NON_TARGETTING and\
			power_type != PowerType.PASSIVE and\
			power_type != PowerType.CHARON
	
	func is_charon() -> bool:
		return power_type == PowerType.CHARON
	
	func is_power() -> bool:
		return power_type == PowerType.POWER_TARGETTING_ANY_COIN or\
			power_type == PowerType.POWER_TARGETTING_MONSTER_COIN or\
			power_type == PowerType.POWER_TARGETTING_PLAYER_COIN or\
			power_type == PowerType.POWER_NON_TARGETTING
	
	func is_passive() -> bool:
		return power_type == PowerType.PASSIVE
	
	func has_tag(tag: Tag) -> bool:
		return tags.has(tag)
	
	func can_target_monster_coins() -> bool:
		return power_type == PowerType.POWER_TARGETTING_ANY_COIN or power_type == PowerType.POWER_TARGETTING_MONSTER_COIN
		
	func can_target_player_coins() -> bool:
		return power_type == PowerType.POWER_TARGETTING_ANY_COIN or power_type == PowerType.POWER_TARGETTING_PLAYER_COIN
