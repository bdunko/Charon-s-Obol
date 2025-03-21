**Charon's Obol v0.3 - Myths and Monsters**
- [ ] **Active Goals - Mar 23 Sprint - More Content (Bosses, Monsters, Trials, Characters)**
	- [ ] **More Monsters (Thursday/Friday/Saturday)**
		- [x] Add power families.
		- [ ] Add coin families. **Thursday**
		- [x] Add powertypes. **Thursday**
		- [ ] Create icons. **Friday**
		- [ ] Implement powertypes. **Saturday**
			- [ ] Hamadyrad - transform when another monster is destroyed
			- [ ] Reliquary - increase cost and decrease cost
		- [ ] Standard
			- [x] Hellhound - Ignite self/damage
			- [x] Kobalos - Unlucky/damage
			- [x] Arae - Curse/no damage
			- [x] Harpy - Blank/damage
			- [ ] Trojan Horse - Destroy this and spawn two smaller monsters (Obol spawns Obol, but don't allow this to spawn as Obol if possible) / no damage
			- [ ] Eidolon - Make each enemy coin Unlucky + Damage
			- [ ] Hyperborean - Freeze random + Lose Souls
			- [ ] Gadfly - Gain Thorns / small damage. increase this damage slightly.
				- [ ] scale the obol to diobol for higher denoms
				- [ ] damage scaling should be handled uniquely
			- [ ] Strix - Increase tails penalty (by a substantial amount, more than damage)+ Damage
			- [ ] Lamia - bury a coin for 2 payoffs / lose souls
			- [ ] Erymanthian Boar - 2x damage/Bury this coin for 2 payoffs.
			- [ ] Spartoi - upgrade this/damage
		- [ ] Elite - happy with these
			- [x] Chimera - Ignite/2x damage
			- [x] Siren - Freeze tails/curse
			- [x] Basilisk - Half life/no damage
			- [ ] Gorgon - Stone/Unlucky
			- [ ] Keres - Increase penalty of all coins + Desecrate
			- [ ] Teumessian fox - Cannot be appeased. 3 Blank + 1 Blank
			- [ ] Manticore - Curse self + Downgrade (Venomous Tail)
			- [ ] Furies - Curse 2 + Unlucky 2
			- [ ] Sphynx - Rightmost possible coin becomes Doomed / gain thorns (the gimmick here is that you can gain thorns then let it become doomed to avoid negatives; to solve the riddle so to speak)
			- [ ] Cyclopes - Downgrade+Prime + Bury a coin for 5 payoffs
		- [ ] Encounter
			- [x] Centaur - Lucky/Unlucky
			- [x] Stymphalian Birds - +Arrow/2x Damage
			- [ ] Colchian Dragon - Gain Souls + damage
			- [ ] Phoenix - When this coin is destroyed: spawn a Phoenix (cheap to destroy). Heal + Ignite self.
			- [ ] Oread - Lucky / Bury a random coin for 3 payoffs
			- [ ] Empusa - Transform a coin into another coin of the same type and denomination / lose souls
			- [ ] Hamadryad - Bless / Heal. Becomes upset when a monster is destroyed and transforms into...
				- [ ] Meliae - Curse / damage
			- [ ] Satyr - Gain random Obol / Blank
			- [ ] Chest - If destroyed, gain a random Obol/Diobol/...; Heads +Souls/Tails -Souls
				- [ ] needs a custom appease price to be approximately the price of the given coin
			- [ ] Aeternae - extremely rare, garbled text, destroys itself after the first payoff. Just used for a fun easter egg/achievement.
	- [ ] **Boss Adjustments - Sunday**
		- [ ] Minotaur - no strain (check for labyrinth passive, if so, turn strain off)
		- [ ] Minotaur - no downgrade/destroy flag.
		- [ ] Charbydis - round down (makes middle coin better/more fair)
		- [ ] Typhon - enrage (transform) when Echidna is destroyed.
		- [ ] Cerb - improve description
		- [ ] Move the no tollgate flag to be a coin flag instead of a list.
			- [ ] same for no upgrade
	- [ ] **New Trials (Sunday)**
		- [ ] 10 trials per tier.





- [ ] Coin of the days
	- [ ] Nike - Victory Above All - Consecrate a coin. For the rest of the round, that coin will always land on heads. At the end of the round, destroy it (doom it).
	- [ ] Dike
	- [ ] Cerberus
	- [ ] Echidna



**Charon's Obol Beta - Coalescence**
- [ ] **More Characters (2-3 days)**
	- [ ] 4 new characters.
		- [ ] The Merchant
		- [ ] The Archon
		- [ ] The Gardener
		- [ ] The Child
	- [ ] Coin exclusion list per character to block bad interactions.
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
- [ ] **Tartarus Bonus Boss - 1 week**




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