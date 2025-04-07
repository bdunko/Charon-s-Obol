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
	
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		assert(false, "don't call 'abstract' method use_power")
	
	class CanUseResult:
		var can_use: bool = false
		var error_message: String = ""
		
		func _init(usable: bool, error_msg: String = "") -> void:
			can_use = usable
			error_message = error_msg
			assert(can_use or error_msg != "") # make sure we provide a message if not usable
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		assert(false, "don't call 'abstract' method can_use_power")
		return null


# Subclasses for each power
class Reflip extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		game.safe_flip(target, false)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_flip():
			return CanUseResult.new(false, "Can't flip stoned coin...")
		return CanUseResult.new(true)

class Freeze extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.freeze()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.is_frozen():
			return CanUseResult.new(false, "It's already (FROZEN)...")
		return CanUseResult.new(true)

class ReflipAndNeighbors extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		game.safe_flip(target, false)
		if left:
			left.play_power_used_effect(Global.active_coin_power_family)
			left.safe_flip(left, false)
		if right:
			right.play_power_used_effect(Global.active_coin_power_family)
			right.safe_flip(left, false)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if (not target.can_flip()) and (not left or (left and not left.can_flip())) and (not right or (right and not right.can_flip())):
			return CanUseResult.new(false, "Can't flip stoned coin...")
		return CanUseResult.new(true)

class TurnAndBlurse extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.turn()
		target.curse() if target.is_heads() else target.bless()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class ReducePenalty extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.change_life_penalty_for_round(-2)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_reduce_life_penalty():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class PrimeAndIgnite extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.prime()
		target.ignite()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.is_primed() and target.is_ignited():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class CopyPowerForToss extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		Global.active_coin_power_coin.overwrite_active_face_power_for_toss(target.get_copied_power_family())
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_copy_power() or target.get_copied_power_family() == Global.active_coin_power_family:
			return CanUseResult.new(false, "Can't copy that...")
		return CanUseResult.new(true)

class ClonePermanently extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		Global.active_coin_power_coin.init_coin(target.get_coin_family(), target.get_denomination(), Coin.Owner.PLAYER)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.get_copied_power_family() == Global.active_coin_power_family:
			return CanUseResult.new(false, "Can't copy that...")
		if Global.active_coin_power_coin.get_denomination() != target.get_denomination():
			return CanUseResult.new(false, "Can't copy a different denomination...")
		return CanUseResult.new(true)

class CopyPowerPermanently extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		Global.active_coin_power_coin.overwrite_active_face_power(target.get_copied_power_family())
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_copy_power() or target.get_copied_power_family() == Global.active_coin_power_family:
			return CanUseResult.new(false, "Can't copy that...")
		return CanUseResult.new(true)

class Exchange extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var new_coin = game._make_and_gain_coin(Global.random_coin_family_excluding([target.get_coin_family()]), target.get_denomination(), game._CHARON_NEW_COIN_POSITION, true)
		new_coin.get_parent().move_child(new_coin, target.get_index())
		new_coin.play_power_used_effect(Global.active_coin_power_family)
		game.remove_coin_from_row_move_then_destroy(target, game._CHARON_NEW_COIN_POSITION)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class MakeLucky extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.make_lucky()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_make_lucky():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class DowngradeForLife extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		game.downgrade_coin(target)
		if target.is_monster_coin():
			Global.lives -= Global.HADES_MONSTER_COST[Global.active_coin_power_coin.get_value() - 1]
		elif target.is_owned_by_player():
			Global.heal_life(Global.HADES_SELF_GAIN[Global.active_coin_power_coin.get_value() - 1])
		else:
			assert(false, "Hades shouldn't get here...")
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.is_owned_by_player() and player_row.get_child_count() == 1 and target.get_denomination() == Global.Denomination.OBOL:
			return CanUseResult.new(false, "Can't destroy last coin...")
		return CanUseResult.new(true)

class Stone extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		if target.is_stone():
			target.clear_material()
		else:
			target.stone()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.is_stone() and not target.can_stone():
			return CanUseResult.new(false, "Can't (STONE) that...")
		return CanUseResult.new(true)

class BlankTails extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.blank()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.is_tails():
			return CanUseResult.new(false, "Can't use on (HEADS) coins...")
		if not target.can_blank():
			return CanUseResult.new(false, "Can't (BLANK) that...")
		if target.get_coin_family().has_tag(Global.CoinFamily.Tag.NEMESIS):
			return CanUseResult.new(false, "This can't (BLANK) the Nemesis...") 
		return CanUseResult.new(true)

class TurnTailsFreezeReducePenalty extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.freeze()
		if target.is_owned_by_player():
			target.change_life_penalty_for_round(-500000)
		if target.is_heads():
			target.turn()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_reduce_life_penalty() and not target.can_freeze() and target.is_tails():
			return CanUseResult.new(true, "No need...")
		return CanUseResult.new(true)

class IgniteChargeLucky extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.ignite()
		target.charge()
		target.make_lucky()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_ignite() and not target.can_charge() and not target.can_make_lucky():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class ConsecrateDoom extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.consecrate()
		target.doom()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.is_doomed() and target.is_consecrated():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class BuryHarvest extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.bury(3)
		target.set_coin_metadata(Coin.METADATA_TRIPTOLEMUS, Global.TRIPTOLEMUS_HARVEST[Global.active_coin_power_coin.get_denomination()])
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class BuryTurnOtherTails extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.bury(1)
		for c in Global.choose_one(target_row.get_multi_filtered_randomized([CoinRow.FILTER_CAN_TARGET, CoinRow.FILTER_TAILS])):
			c.turn()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class InfiniteTurnHunger extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var current_cost = Global.active_coin_power_coin.get_active_face_metadata(Coin.METADATA_ERYSICHTHON, 0)
		Global.lives -= current_cost
		Global.active_coin_power_coin.set_active_face_metadata(Coin.METADATA_ERYSICHTHON, current_cost + 1)
		target.turn()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_turn():
			return CanUseResult.new(false, "Can't turn that...")
		return CanUseResult.new(true)

class FlipAndTag extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.set_coin_metadata(Coin.METADATA_ERIS, true)
		for c in player_row.get_children() + enemy_row.get_children():
			if c.get_coin_metadata(Coin.METADATA_ERIS, false):
				if c.can_flip():
					c.play_power_used_effect(Global.active_coin_power_family)
					game.safe_flip(c, false)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_flip():
			return CanUseResult.new(false, "Can't flip stoned coin...")
		return CanUseResult.new(true)

class SwapReflipNeighbors extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		pass
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_flip():
			return CanUseResult.new(false, "Can't flip stoned coin...")
		return CanUseResult.new(true)

class IgniteThenBlessThenSacrifice extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target_row.swap_positions(Global.active_coin_power_coin, target)
		if left:
			left.play_power_used_effect(Global.active_coin_power_family)
			game.safe_flip(left, false)
		if right:
			right.play_power_used_effect(Global.active_coin_power_family)
			game.safe_flip(right, false)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.is_ignited() and not target.can_ignite():
			return CanUseResult.new(false, "Can't ignite that...")
		if target.is_ignited() and not target.is_blessed() and not target.can_bless():
			return CanUseResult.new(false, "Can't bless that...")
		if target.is_ignited() and target.is_blessed() and\
			target.is_owned_by_player() and player_row.get_child_count() == 1 and target.get_denomination() == Global.Denomination.OBOL:
			return CanUseResult.new(false, "Can't destroy that...")
		return CanUseResult.new(true)






class TEMPLATE extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		pass
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_flip():
			return CanUseResult.new(false, "Can't flip stoned coin...")
		return CanUseResult.new(true)
