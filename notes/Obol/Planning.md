**Charon's Obol v0.3 - Myths and Monsters**
- [ ] **Active Goals - Mar 9 Sprint - More Content**
	- [ ] **More Coins**
		- [ ] Week:
			- [ ] Work on implementing new power coins and their powers.
		- [ ] Add Coins and their Powers
			- [ ] Coin of the days
				- [ ] Perseus - Gorgon's Gaze Reflected - Turn a coin to or from stone.
				- [ ] Boreas - Northern Hail - Choose a coin. Swap positions with it, then reflip this coin's new neighbors.
				- [ ] Sarpedon - Purifying Pyre - Ignite a coin. If it was already ignited, Bless it. If it was already blessed, destroy it and fully recharge your patron token.
				- [ ] Dike - Fair & Balanced - Change each coin to its other side.
			- [ ] Nontrivial - Weekend
				- [ ] Nike - Victory Above All - Consecrate a coin. For the rest of the round, that coin will always land on heads. At the end of the round, destroy it (doom it).
					- [ ] Implement doom.
				- [ ] Triptolemus - Sow the Earth - Bury one of your coins for 3 payoffs. When it returns, gain souls and heal.
				- [ ] Antigone - Bury Thy Brother - Bury one of your coins for 1 payoff. Turn a random tails coin to heads.
					- [ ] Add Bury. Bury needs to change the graphic. Bury graphic should show a number of turns remaining. Additionally, bury tooltip should specify how many turns remain.
				- [ ] Prometheus - The First Flame - Light a fire. All coins land on heads +0.5% more often for each fire lit this game (max +25%).
					- [ ] Implement fire.
				- [ ] Erysichthon - Faustian Hunger - Infinite uses. Reflip a coin, then lose 1 life and permanently increase this amount by 1. When upgraded, the life loss is reset to 1.
					- [ ] Tails - Turn this to heads. (this is also cute since Daedalus could copy it or something wacky :D)
					- [ ] Need a way to represent infinite charges (can use a large negative magic number. don't draw a digit, but rather make a unique img for this and use that. when depleting charges, if infinite, don't)
				- [ ] Eris - For the Fairest - Flip a coin, plus each other coin this power has been used on this round. 3/4/5/6 uses.
				- [ ] Aeolus - The Winds Shall Obey - Reflip each coin to the left/right of this (alternates each use)
				- [ ] Proteus - Water Shifts Shapes - Transforms into a random power each toss. If the power is used, this face permanently becomes that power.
				- [ ] Plutus - Greed is Blind - Gain a coin with +6/-6 and flip it. After payoff, destroy it. 1/2/3/4 charges.
				- [ ] Midas - All that Glitters - Gain a golden Obol/Diobol/Triobol/Tetrobol! Golden coins do nothing, but can be used to pay for tolls or other abilities.
					- [ ] Create new coin sprite for this. Can share with Plutus.
			- [ ] Reworks
				- [ ] Artemis patron power - when you destroy a monster, gain 2 arrows.
				- [ ] Heph - instead of immediately upgrading, Prime a coin.
				- [ ] Obol of the Argonauts
					- [ ] "Jack of all trades" coin, rotates between different powers.
						- [ ] ??? - 
							- [ ] Iolcus - Bless
								- [ ] The Quest Begins
							- [ ] Propontis  - Destroy own coin and downgrade random monster.
								- [ ] The Tragedy of Cyzicus
							- [ ] Thrace - Blank
								- [ ] Phineaus's Counsel
							- [ ] Dia - Arrows
								- [ ] Stymphalian Quills
							- [ ] Aeetes - Golden Fleece
								- [ ] Jason's Prize
								- [ ] Coins and upgrades cost 1 less soul for each golden fleece you have. This should be a payoff. Needs special icon and appear on board.
							- [ ] Sirens - Freeze
								- [ ] Siren Song
							- [ ] Iolcus - Bless
								- [ ] The Quest Begins


**Charon's Obol Beta - Coalescence**
- [ ] **Content Wave 2 - 1 week**
	- [ ] **New Bosses**
	- [ ] **More Monsters**
- [ ] **Content Wave 3 - 1 week**
	- [ ] **More Characters**
- [ ] **QOL - 1 week**
	- [ ] Payoff coins with possibly changing amounts should have their text label flicker a bit.
	- [ ] Coins with a passive should have like, the cool rotating pixel thing around their edges.
		- [ ] This is hard to do with shader (doable but tricky) - I'll just create an animation in aesprite and overlay it.
	- [ ] Add a hotkey which, when held, shows the icons of your coins. (shift or control probably)
	- [ ] Add a button to disable tooltips. (tab probably, also visible on screen).
	- [ ] Settings menu
	- [ ] Can't accidentally mash through shop. Put a 1sec delay on entering shop and being allowed to press continue (don't show this visually, just ignore the click)
	- [ ] Tooltip improvements/fixes (directional tooltips - tooltips prefer going in a specific direction depending on row etc)
	- [ ] **Tutorial Tuning**
		- [ ] Don't show UPGRADE mouse cursor change during tutorial until it is unlocked.
		- [ ] Don't show upgrade prices or allow upgrades in the first shop.
		- [ ] The Shop Mat should be brought to front when introducing the shop.
		- [ ] We shouldn't show the first power coin until Charon introduces the shop a bit more.
		- [ ] Make sure prices are reasonable.
		- [ ] Mouse cursor replacements need scaling based on the size of the window. Right now they are constant size. This makes them very large on smaller monitors and smaller on large ones.
		- [ ] Patron token passives (Charon included) should do an additional animation or raise or jiggle or something when they trigger. I could see a slight rotation shake being effective for both this and for coin payoffs.
		- [ ] "Patrons have both an activated power" <- use POWER icon here instead of the word power
		- [ ] When entering the shop, add a delay before you can click to leave (0.5 second should be plenty). Prevent accidental rushing through shop.
		- [ ] During the round, once a player has enough souls, Charon interrupts (just once) to explain that you can click the enemy to destroy it.
		- [ ] Change POWER on patron token to a different color to imply it is different from other powers and does not recharge each toss like coins do.
		- [ ] Force default tutorial coinpool when playing the tutorial (don't use any unlocks)
- [ ] **Basic Sound - 4 weeks**

**Charon's Obol Release**
- [ ] **Revamped Unlock System - 2 weeks**
	- [ ] Achievement system for unlocks. Should appear on main menu.
- [ ] **Settings Menu & Controller Support - 1 week**
- [ ] **More Content - 6 weeks**
	- [ ] **Charon Extension**
		- [ ] Charon action ideas:
			- [ ] Bury valuable coin.
			- [ ] Ignite monsters.
			- [ ] Lucky monsters.
			- [ ] Bless monsters.
- [ ] **Polish - 2 weeks**
* [ ] **Coin Graphical Effects - 2 weeks**
	- [ ] **Improved Graphical effects for coins (ie lightning, fire, wind, etc - basic effects, reuse)**
	- [ ] **Enhanced Monster Effects (Projectile animations)**
		- [ ] Add projectiles for monster coins targetting coins in player's row.
			- [ ] projectilesystem creates projectiles (Sprite2D with particles in charge of moving), signal when it hits
			- [ ] Just need to await for it to finish
				- [ ] if there are multiple, it's slightly trickier. maybe we actually create a projectilesystem, which can manage multiple projectiles and signals when both are done? seems reasonable. it can keep a reference count
- [ ] **Gameplay Options - 1 week**
	- [ ] **Treasury of Atreus - 1 week** - multiple options for what coins form the coinpool.
	- [ ] Complete - everything
	- [ ] Classic - Olympians (the 13 original)
	- [ ] Classic+ - Classic with a few more additions, around ~25 coins.
	- [ ] Remix/Redux/Remake - Small sets of 25 coins, basically alternative Classic.
	- [ ] Finesse - Tricky coins, hard to use
	- [ ] Elements - Manipulation with lightning, freeze, ignite, wind coins.
	- [ ] Heroic - No gods, instead only heroic greek figures.
	- [ ] Worldly - nature themed coins, healing focus
	- [ ] Corrupted - Coins with downsides
	- [ ] Metamorphosis - Coins that trade, exchange, gain, destroy coins.
	- [ ] Preordained - Absolutely no coins that reflip, focus on lucky/bless etc
	- [ ] Fundamentals - Absolutely no coins with Statuses.
	- [ ] Oracle's Choice - randomized pool of 25 coins, changing daily.
	- [ ] Charon's Choice - randomized pool of 25 coins, changes each time you choose it.
	- [ ] **Scales of Themis - 1 week**
	- [ ] Shows overall 'heat' level of difficulty settings.
	- [ ] Offers further difficulty tuning, can be used at any difficulty once unlocked. Scales shown on main menu.
	- [ ] Tails chance
	- [ ] Shop prices
		- [ ] Affects both obol scaling and upgrades
	- [ ] Tollgate prices
		- [ ] flat increase based on round
	- [ ] Monster strength
	- [ ] Life penalties
		- [ ] flat increase/decrease
	- [ ] Strain
		- [ ] flat increase/decrease
	- [ ] **Custom Seed - 1 week**
		- [ ] Change RNG so that Trails/Boss/Charon, Shop, and coin RNG are all different.
- [ ] **Orphic Tablets - 1 week**
	- [ ] Option unlocked on main menu once unlocked.
	- [ ] New tablets unlocked in progression.
	- [ ] Unlocked upon tutorial completion, populated with initial tutorials rehashing tutorial.
	- [ ] Status - shows a list of all status icons and effects
	- [ ] **Coin Gallery**
		- [ ] Shows all coins unlocked and their upgrade states, in rows. Page-able list.
- [ ] **Additional Refactors**
	- [ ] Separate out Global.gd into multiple files.
		- [ ] VoyageInfo, Util, CoinInfo, PatronInfo, SaveLoad, EventBus
	- [ ] Cleanup game.gd so that functions are ordered better; try to reduce size.
	- [ ] Cleanup coin.gd in the same way.
	- [ ] Powers should have a lambda function they call. We may need to change how certain functions such as destroy_coin, downgrade_coin, and safe_flip function to make this feasible. (these should probably not exist in game.gd. Rather, they should be part of flip, destroy, and downgrade in coin. We may need to add signal emits to let game.gd react - ie coinrow may need to perform cleanup, track active flips, etc. Event bus is probably appropriate.)

https://en.wikipedia.org/wiki/Apega_of_Nabis
https://en.wikipedia.org/wiki/Macaria

---

**Potential Coins**




THIS WOULD BE GOOD AS A MONSTER
	- [ ] ??? - Merchant - Randomly transforms between the following 'powers'/'items', which cost souls to use
		- [ ] Freeze a coin.
		- [ ] Reflip a coin.
		- [ ] Make a coin Lucky.
		- [ ] Bless a coin.
		- [ ] Change a coin to its other face.
		- [ ] Clear negative statuses from a coin.
??? - Many charges - Change a random coin to its other side.


- [ ] Locked - Prevents the coin from flipping, payoff, or being activated for the rest of the round (bound in chains graphically).
- [ ] Ward - Blocks the next power applied to this coin, then deletes the ward.
- [ ] Reflip some heads coins.

- [ ] Tap a coin - whenever a power on that coin is used, lose life.
- [ ] Imprison a coin - locks up a coin (blank + doesn't flip); spend souls to unlock.
- [ ] Sap - Coin does not naturally recharge each toss.
