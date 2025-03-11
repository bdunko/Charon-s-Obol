**Charon's Obol v0.3 - Myths and Monsters**
- [ ] **Active Goals - Mar 23 Sprint - More Content (Bosses, Monsters, Trials, Characters)**
	- [ ] Cleanup
		- [ ] Proteus - Use unique coin sprite to indicate that it is transforming/not locked. 
			- [ ] also consider adding a note (Affected by Proteus) to the power's tooltip for that face if the metadata is set.
		- [ ] Heph - instead of immediately upgrading, Prime a coin.
			- [ ] S primed dprimed primed
			- [ ] remove (HEPHAESTUS_OPTIONS)
		- [ ] Tuesday - Minor refactor
			- [ ] We should really remove Global.active_coin_power_family and just get it from the coin when needed.
		- [ ] **New Bosses (1 week)**
			- [ ] 4 new bosses.
				- [ ] Minotaur - Endurance
				- [ ] Echidna & Typhoon - Spawn and buff monsters
				- [ ] Cerberus - Damage race
					- [ ] Left
						- [ ] Permanently ignite one of Cerberus's heads
						- [ ] Ignite 2 of your coins.
					- [ ] Middle
						- [ ] Increase ignite damage by 2 for the rest of this round.
						- [ ] Increase penalty damage by 3 for the rest of this round.
					- [ ] Right
						- [ ] Take 10 damage.
						- [ ] Desecrate your cheapest coin (it always lands on tails for the rest of the round).
				- [ ] Scylla and Charybdis - Negation
		- [ ] **More Monsters (3 days)**
			- [ ] 16 total standard monster types (10 additional)
			- [ ] 8 elite monster types. (4 additional)
		- [ ] **New Trials (2 days)**
			- [ ] 10 trials per tier.
		- [ ] **More Characters (2-3 days)**
			- [ ] 4 new characters.
				- [ ] The Merchant
				- [ ] The Archon
				- [ ] The Gardener
				- [ ] The Child
			- [ ] Coin exclusion list per character to block bad interactions.


- [ ] Coin of the days
	- [ ] Perseus - Gorgon's Gaze Reflected - Turn a coin to or from stone.
	- [ ] Sarpedon - Purifying Pyre - Ignite a coin. If it was already ignited, Bless it. If it was already blessed, destroy it and downgrade a random monster twice.
	- [ ] Nike - Victory Above All - Consecrate a coin. For the rest of the round, that coin will always land on heads. At the end of the round, destroy it (doom it).
	- [ ] Aeolus - The Winds Shall Obey - Reflip each coin to the left/right of this (alternates each use)
	- [ ] Plutus - Greed is Blind - Gain an Ephemeral coin with +6/-6 and flip it. 
	- [ ] Midas - All that Glitters - Gain a golden Obol/Diobol/Triobol/Tetrobol! Golden coins do nothing, but can be used to pay for tolls or other abilities.



**Charon's Obol Beta - Coalescence**
- [ ] **Beta QOL - 1 week**
	- [ ] Coins with a passive should have like, the cool rotating pixel thing around their edges.
		- [ ] This is hard to do with shader (doable but tricky) - I'll just create an animation in aesprite and overlay it.
	- [ ] Add a hotkey which, when held, shows the icons of your coins. (shift or control probably)
	- [ ] Add a button to disable tooltips. (tab probably, also visible on screen).
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

**Maybe**
- [ ] **Tooltip Shrinking - 1 week**
	- [ ] Reduce the size of the tooltips by increasing base game size.

**Charon's Obol Release**
- [ ] **Sound - 8 weeks**
- [ ] **Revamped Unlock System - 2 weeks**
	- [ ] Achievement system for unlocks. Should appear on main menu.
- [ ] **Orphic Tablets - 1 week**
	- [ ] Option unlocked on main menu once unlocked.
	- [ ] New tablets unlocked in progression.
	- [ ] Unlocked upon tutorial completion, populated with initial tutorials rehashing tutorial.
	- [ ] Status - shows a list of all status icons and effects
	- [ ] **Coin Gallery**
		- [ ] Shows all coins unlocked and their upgrade states, in rows. Page-able list.
- [ ] **Settings Menu & Controller Support - 2 weeks**
	- [ ] Add settings menu.
	- [ ] Add support for controllers.
- [ ] **More Content - 8 weeks**
	- [ ] **20 Characters**
	- [ ] **100 Coins**
	- [ ] **Charon Extension**
		- [ ] Charon action ideas:
			- [ ] Bury valuable coin.
			- [ ] Ignite monsters.
			- [ ] Lucky monsters.
			- [ ] Bless monsters.
* [ ] **Coin Graphical Effects - 2 weeks**
	- [ ] **Improved Graphical effects for coins (ie lightning, fire, wind, etc - basic effects, reuse)**
	- [ ] **Enhanced Monster Effects (Projectile animations)**
		- [ ] Add projectiles for monster coins targetting coins in player's row.
			- [ ] projectilesystem creates projectiles (Sprite2D with particles in charge of moving), signal when it hits
			- [ ] Just need to await for it to finish
				- [ ] if there are multiple, it's slightly trickier. maybe we actually create a projectilesystem, which can manage multiple projectiles and signals when both are done? seems reasonable. it can keep a reference count
- [ ] **Gameplay Options - 1 week**
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
- [ ] **Polish & Balance - 4 weeks**




**Post Launch Dreams**
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
- [ ] **Custom Seed**
	- [ ] Change RNG so that Trails/Boss/Charon, Shop, and coin RNG are all different.