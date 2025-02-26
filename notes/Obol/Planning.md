**Charon's Obol v0.3 - Myths and Monsters**
- [ ] **Active Goals - Mar 1 Sprint - More Content**
	- [ ] **More Coins**
		- [ ] Coins need a way to mark passives (used for Telemachus to prevent upgrading for example, this is associated with the COIN and not the POWER)
		- [ ] Week:
			- [ ] Work on implementing new power coins and their powers.
			- [ ] Need to add a way to represent passives. Coins need an optional string for their passive, which shows above the power in their tooltip. Defaults to "". This is mostly needed for destroy for reward, but we can also slap rules text like "Doesn't flip" here for 
		- [ ] Add Coins and their Powers
			- [ ] 8 Payoffs
				- [ ] Tantalus - Distant Fruit, Fading Water - Whenever this card is on heads, gain souls then immediately turn it to tails.
					- [ ] add code to allow for 
				- [x] Aeneas - Wasn't Built in a Day - Beneficial on both heads and tails, but lower payoff.
				- [ ] Orion - Hunting for Stars - Souls on heads; Arrows on tails (souls payoff is minimal)
					- [ ] Tails tooltip shows charges but it shoujldn't just make it work liek souls payoffs (arrow payoffs should be treated the same; just +ARROW... but stymphanian bird keeps what it is... so IFF the icon is the arrow icon, don't show the power part)
				- [x] Carpo - Limitless Harvest - 0/2/4/6 souls - Increases by 2 each payoff (resets when the round ends).
				- [ ] Telemachus - Following His Shadow - After 50 payoffs, transform into a random power coin, upgrade thrice, and consecrate permanently. Only available as Obol, cannot be upgraded.
					- [ ] in payoff, after gaining souls, check for transform via metadata
			- [ ] 21 Powers
				- [ ] Perseus - Gorgon's Gaze Reflected - Turn a coin to stone (never flips again, does not recharge) or unstone a coin. 
				- [ ] Hypnos - Bed of Poppies - Blank a tails coin.
				- [ ] Nike - Victory Above All - Consecrate a coin. For the rest of the round, that coin will always land on heads. At the end of the round, destroy it (doom it).
				- [ ] Triptolemus - Sow the Earth - Bury one of your coins for 3 payoffs. When it returns, gain souls and heal.
				- [ ] Antigone - Bury Thy Brother - Bury one of your coins for 1 payoff. Turn a random tails coin to heads.
				- [ ] Chione - Embracing Cold - Flip a coin to tails and freeze it. If it is one of your coins, reduce its tails penalty to 0 this round.
				- [ ] Hecate - The Key to Magick - Choose a coin. Ignite it, Bless it, and make it Lucky.
				- [ ] Prometheus - The First Flame - Light a fire. All coins land on heads +0.5% more often for each fire lit this game (max +25%). 
				- [ ] Phaethon - Smitten Upstart - Destroy this coin. Gain souls, arrows, life, and fully recharge patron. Upgrades each round.
				- [ ] Erysichthon - Faustian Hunger - Infinite uses. Doesn't flip (use a separate sprite entirely to indicate this; it isn't a coin) Reflip a coin, then lose 1 life and permanently increase this amount by 1. When upgraded, the life loss is reset to 1. If you didn't use this at least once this round, curse this coin.
				- [ ] Dolos - Beneath Prosopon - Choose a coin. This coin permanently becomes a copy of that coin.
				- [ ] Eris - For the Fairest - Flip a coin, plus each other coin this power has been used on this round. 3/4/5/6 uses.
				- [ ] Aeolus - The Winds Shall Obey - Reflip each coin to the left/right of this (alternates each use)
				- [ ] Boreas - Northern Hail - Choose a coin. Swap positions with it, then reflip this coin's new neighbors.
				- [ ] Daedalus - Automaton Builder - Choose two coins you control; merge them together (the coin becomes heads on two sides basically) and destroy this coin. (Handling - Each side of this coin is the Daedalus power, which is "permaently copy another coin's power to this face.")
				- [ ] Plutus - Greed is Blind - Gain a coin with +6/-6 and flip it. After payoff, destroy it. 1/2/3/4 charges.
				- [ ] Midas - All that Glitters - Gain a golden Obol/Diobol/Triobol/Tetrobol! Golden coins do nothing, but can be used to pay for tolls or other abilities
				- [ ] Dike - Fair & Balanced - Change each coin to its other side.
				- [ ] Jason - Roving Argonaut - Gain a golden fleece. All coins cost 1 less soul for each golden fleece you have.
				- [ ] Sarpedon - Purifying Pyre - Ignite a coin. If it was already ignited, Bless it. If it was already blessed, destroy it and fully recharge your patron token.
				- [ ] Proteus - Water Shifts Shapes - Transforms into a random power each toss. If the power is used, this face permanently becomes that power.
					- [ ] make icon

		- [ ] **Weekend - Coin Implementations**


- [ ] Charon action ideas:
	- [ ] Bury valuable coin.
	- [ ] Ignite monsters.
	- [ ] Lucky monsters. 
	- [ ] Bless monsters.

**Charon's Obol Beta - Coalescence**
- [ ] **Content Wave 2**
	- [ ] **New Bosses**
	- [ ] **More Monsters**
- [ ] **Content Wave 3**
	- [ ] **More Characters**
- [ ] **Coin Graphical Effects**
	- [ ] **Improved Graphical effects for coins (ie lightning, fire, wind, etc - basic effects, reuse)**
	- [ ] **Enhanced Monster Effects (Projectile animations)**
		- [ ] Add projectiles for monster coins targetting coins in player's row. 
			- [ ] projectilesystem creates projectiles (Sprite2D with particles in charge of moving), signal when it hits
			- [ ] Just need to await for it to finish
				- [ ] if there are multiple, it's slightly trickier. maybe we actually create a projectilesystem, which can manage multiple projectiles and signals when both are done? seems reasonable. it can keep a reference count
- [ ] **QOL**
	- [ ] Payoff coins with possibly changing amounts should have their text label flicker a bit. 
	- [ ] Coins with a passive should have like, the cool rotating pixel thing around their edges.
		- [ ] This is hard to do with shader (doable but tricky) - I'll just create an animation in aesprite and overlay it. 
	- [ ] Add a hotkey which, when held, shows the icons of your coins. (shift or control probably)
	- [ ] Add a button to disable tooltips. (tab probably, also visible on screen).
	- [ ] Settings menu
	- [ ] Can't accidentally mash through shop. Put a 1sec delay on entering shop and being allowed to press continue (don't show this visually, just ignore the click)
	- [ ] **Tutorial Tuning**
		- [ ] Don't show UPGRADE mouse cursor change during tutorial until it is unlocked.
		- [ ] The Shop Mat should be brought to front when introducing the shop.
		- [ ] Mouse cursor replacements need scaling based on the size of the window. Right now they are constant size. This makes them very large on smaller monitors and smaller on large ones. 
		- [ ] Patron token passives (Charon included) should do an additional animation or raise or jiggle or something when they trigger. I could see a slight rotation shake being effective for both this and for coin payoffs. 
		- [ ] "Patrons have both an activated power" <- use POWER icon here instead of the word power
		- [ ] When entering the shop, add a delay before you can click to leave (0.5 second should be plenty). Prevent accidental rushing through shop.
		- [ ] Improve wording for enemy coins. Instead of "they may be affected by powers (sic)"; mention you can USE coin powers on them.
			- [ ] During the round, once a player has enough souls, Charon interrupts (just once) to explain that you can click the enemy to destroy it.
		- [ ] Change POWER on patron token to a different color to imply it is different from other powers and does not recharge each toss like coins do.
		- [ ] Better wording for "doesn't flip coins... it simply turns them to their other side" ('isn't that what flip means'?) perhaps, add the word randomly
		- [ ] Make sure the Wait! when Zeusing a heads coin in tutorial does not trigger on monster coins (since that may be intended)
		- [ ] If you click a button, drag off and release, the button shouldn't activate (but it does).
- [ ] **Basic Sound
- [ ] **Orphic Tablets**
	- [ ] Option unlocked on main menu once unlocked.
	- [ ] New tablets unlocked in progression.
	- [ ] Unlocked upon tutorial completion, populated with initial tutorials rehashing tutorial.
	- [ ] Status - shows a list of all status icons and effects
	- [ ] **Coin Gallery**
		- [ ] Shows all coins unlocked and their upgrade states, in rows. Page-able list.
- [ ] **Revamped Unlock System**
	- [ ] Achievement system for unlocks. Should appear on main menu. 

**Charon's Obol Release**
- [ ] **Controller Support**
- [ ] **Coin Gallery**
- [ ] **More Content**
- [ ] **Polish**
- [ ] **Bugs**
- [ ] **Treasury of Atreus** - multiple options for what coins form the coinpool.
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
- [ ] **Scales of Themis**
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
- [ ] Add custom seed option in main menu eventually
	- [ ] Change RNG so that Trails/Boss/Charon, Shop, and coin RNG are all different.
- [ ] **Additional Refactors**
	- [ ] Separate out Global.gd into multiple files.
		- [ ] VoyageInfo, Util, CoinInfo, PatronInfo, SaveLoad, EventBus
	- [ ] Cleanup game.gd so that functions are ordered better; try to reduce size.
	- [ ] Cleanup coin.gd in the same way.
	- [ ] **Coin Power Refactor**
		- [ ] Each power should specify a TargetType enum. "OwnCoins" "Auto" "EnemyCoins" "AnyCoin" "PayoffGainSouls" "PayoffLoseLife. 
			- [ ] If "Auto", that's how we know not to prompt for a target and to immediately activate
			- [ ] The Payoff powers are used to determine if/how this coin resolves during payoff. Ie each lose life power would use PayoffLoseLife, but with a different charge count.
			- [ ] Each Soul payoff coin could use PayoffGainSouls and automatically update its charges as required.
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