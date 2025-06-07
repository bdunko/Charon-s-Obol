
**Audio Export Process**
From Ableton - Export each individual track. Length should be size of longest track.
We now need to trim away the silence at the end of each .wav file.
In Audacity, File -> Import Audio. Multi-select all .wav files.
Select all of them. Effect -> Special -> Truncate Silence.
Change the Truncate to length to a short value (0.1s) and apply.
Now we need to export the modified files.
Export Audio. Tick Multiple Files. Tick Overwrite existing files. Press export.

**Timeline**
- [ ] **Soundtest** - by August 15
- [ ] **Revamped Unlock System** - by Sept 1
- [ ] **Settings Menu & Controller Support** - by Sept 15
- [ ] **Orphic Tablets** - by Sept 22
- [ ] **Treasure of Atreus** - by Oct 1
- [ ] **Tartarus Bonus Boss** - by Oct 15
- [ ] **More Coins** - by Nov 15
- [ ] **More Characters & Balance** - by Jan 1
- [ ] **Playtesting & Polish** - by Feb 1
- [ ] **Release** - by Mar 3


**Charon's Obol Soundtest**
Week 1
- [ ] **Main Menu Sounds**
	- [ ] Explore distinct theming for UI effects - watery
	- [ ] **Revisions**
		- [ ] Difficulty Skull sound effect should be different from buttons. Also different from each skull - more spooky/lower pitched on higher difficulties. 
			- [ ] can just have a base noise and 5 versions pitched down.
		- [ ] The Start button sound should be louder. But the sound itself is fine. But maybe it should be watery?
		- [ ] More dramatic swoosh sound for changing characters, not enough impact.
			- [ ] Don't need a click for the arrows then, just do a swoosh
	- [ ] **Additions**
		- [ ] Hover major button
		- [ ] Hover minor button (difficulty skull/selector arrows)
- [x] **Building Blocks - Section 5**
- [ ] **Building Blocks - Section 6**
	- [x] Bass - The 6's
	- [x] Chords - The 6's
	- [x] Melody - The 6's
	- [ ] All Together 2

Week 2
- [ ] **Patron Selection Sounds**
	- [ ] **Revisions**
		- [ ] Thunderstorm loop for patron selection screen is too short, loops too soon.
	- [ ] **Addition**
		- [ ] Sound needed for selecting a patron.
		- [ ] Sound for advancing god speech.
		- [ ] Transition sound for zooming into cave.
	- [ ] Possible effect - low pass the storm after selection?
- [ ] **Victory Sounds**
	- [ ] todo
- [ ] **Transitions**
	- [ ] Death
	- [ ] Victory to main menu
	- [ ] Main menu to god selection
	- [ ] God selection zoom to cave
	- [ ] Game fade to victory screen
- [ ] **Building Blocks - Section 7**
	- [ ] Drums - 16th Shuffle
	- [ ] Bass, Chords, and Melody - 16th Shuffle
	- [ ] Chords - 4-Bar Chord Progression
	- [ ] Melody - 4 Bars

Week 3/4
- [ ] **Improved Graphical effects for coins (ie lightning, fire, wind, etc - basic effects, reuse)**
	- [ ] Play slight particle effect for any power use (burst of colored pixels, color changes per coin).
- [ ] **Enhanced Monster Effects (Projectile animations)**
	- [ ] Add projectiles for monster coins targetting coins in player's row.
		- [ ] projectilesystem creates projectiles (Sprite2D with particles in charge of moving), signal when it hits
		- [ ] Just need to await for it to finish
			- [ ] if there are multiple, it's slightly trickier. maybe we actually create a projectilesystem, which can manage multiple projectiles and signals when both are done? seems reasonable. it can keep a reference count
		- [ ] To make a curved path projectile, x and y simply need to follow different functions over the same time interval; aka use two tweens (one for x and one for y) with different trans. One linear and one expo (or other) will achieve this effect.
- [ ] **Death effect**
	- [ ] Death sequence.
	- [ ] Crazy blue effect, fade to blue.
- [ ] **Improved Payoff**
	- [ ] Rising souls/life effect with flashing number...
	- [ ] In text under label, show sum of life lost/gained each payoff.
	- [ ] Labels should have a 'transforming/burning of wood' effect - new numbers flash purple for a second as old fades.
- [ ] **Life loss vignette effect**
	- [ ] Red tint around screen edge, more dramatic lower on life you are. Flashes whenever you lose life.
- [ ] **Game Phase Labels**
- [ ] **Building Blocks - Section 8**
	- [ ] Bass - 7's & The Octave
	- [ ] Chords - 7's & The Octave
	- [ ] Melody - 7's & The Octave
	- [ ] All Together 3
- [ ] **Building Blocks - Section 9**
	- [ ] Drums - Removing Backbeats
	- [ ] Bass, Chords, and Melody - Removing Backbeats
	- [ ] Chords - Inversions
	- [ ] Chords - Inversions 2
	- [ ] All Together 4
- [ ] **Building Blocks Cheatsheet**
	- [ ] Go through all the creates again in order, do them in Ableton, take notes on the video portions

Week 5/6/7
- [ ] **Game Sounds**
	- [ ] I think we forgot to add the power selected/unselected sounds at all.
	- [ ] **Revisions**
		- [ ] Heavy water loop is too short and the restart is too obvious.
		- [ ] Don't use the same sound for all button presses; example:
			- [ ] Board - no sound needed because map open covers it.
			- [ ] Begin First Round - no sound needed because map close covers it.
			- [ ] Accept - probably don't need because all payoffs have their own sounds.
			- [ ] Toss - Don't need because 'row retract' should cover it.
		- [ ] Coin landing sound definitely doesn't work.
		- [ ] Coin toss sound, not sure.
		- [ ] In the shop - we don't want charon's hand making a sound every time it moves.
		- [ ] Buy coin sound needs a change.
		- [ ] Monster payoff sound isn't quite it.
		- [ ] Not sure about flip sound/landing sound stacking... 
		- [ ] The turn sound should just be a metallic something...
	- [ ] Additions
		- [ ] Hover map
		- [ ] Charon talk sound
		- [ ] Heartbeat (add the effect so this looks less weird, and see if it works)
		- [ ] Need a water whoosh sound during boat movement on map.
		- [ ] Status applied (specific)
			- [ ] Ignite
			- [ ] Freeze
			- [ ] Bless/Lucky/Consecrate
			- [ ] Unlucky/Curse/Desecrate
			- [ ] Charge
			- [ ] Stone
			- [ ] Blank
			- [ ] Bury
			- [ ] Fleeting
			- [ ] Doomed
		- [ ] Power activated (specific)
			- [ ] make a bunch of different powers used options and assign to coins individually
		- [ ] Payoff activated (specific, mostly for monsters)
			- [ ] different options attached to fitting monsters
			- [ ] also the arrow sound
		- [ ] IgniteTakeDamage
		- [ ] DowngradeCoin
		- [ ] DestroyCoin
		- [ ] HealLife
		- [ ] LoseSouls
		- [ ] ShootArrow
		- [ ] Recharge
		- [ ] Last Chance Flip
			- [ ] Extra special toss sound
			- [ ] Death result
			- [ ] Life result
			- [ ] Dark storm
- [ ] **Charon Speech** - chip speech
	- [ ] Death - "Your soul is mine!"
	- [ ] Intro - "I am Charon, shephard of the dead."
	- [ ] Last chance flip - "You must flip!"
	- [ ] Victory - "I wish you luck..."


Week 8/9/10/11
- [ ] **Songs**
	- [ ] Main menu
	- [ ] Normal round
	- [ ] Trail round
	- [ ] Nemesis round
	- [ ] Tollgate round
	- [ ] Shop - SMT2 shop




**Charon's Obol Release**
- [ ] **Revamped Unlock System - 2 weeks**
	- [ ] Achievement system for unlocks. Should appear on main menu.
- [ ] **Orphic Tablets - 1 week**
	- [ ] Option unlocked on main menu once unlocked.
	- [ ] New tablets unlocked in progression.
	- [ ] Unlocked upon tutorial completion, populated with initial tutorials rehashing tutorial.
	- [ ] Status - shows a list of all status icons and effects
	- [ ] **Coin Gallery**
		- [ ] Shows all coins unlocked and their upgrade states, in rows. Page-able list.
- [ ] **More Content - 8 weeks**
	- [ ] **20 Characters**
	- [ ] **100 Coins**
	- [ ] **Charon Extension**
		- [ ] Charon action ideas:
			- [ ] Bury valuable coin.
			- [ ] Ignite monsters.
			- [ ] Lucky monsters.
			- [ ] Bless monsters.
- [ ] **Treasury of Atreus** - 1 week - multiple options for what coins form the coinpool.
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
- [ ] **Tartarus Bonus Boss - 2 weeks**
- [ ] **Settings Menu & Controller Support - 2 weeks**
	- [ ] Add settings menu.
		- [ ] Turn off effects
		- [ ] Settings should be saved to a separate save file.
	- [ ] Add support for controllers.
- [ ] **Polish - 4 weeks**
- [ ] **Balance**
	- [ ] Fundamental rule - payoffs which are not showing do not happen. Payoffs which are showing always happen. Ex: Blank payoffs don't happen; Frozen payoffs do happen.
		- [ ] Stone breaks this rule. 
			- [x] Choice 1 - Stone coins are also blank.
				- [ ] Stone is more threatening.
				- [ ] Perseus is kinda bad.
				- [ ] Larger distinction between Freeze and Stone.
			- [x] Choice 2 - Stone coins still payoff.
				- [ ] This makes Medusa less threatening as she can hit your payoff coins on heads.
				- [ ] Perseus becomes a more potent coin.
				- [ ] Freeze and Stone become pretty similar? Freeze is essentially a one-time Stone.
			- [ ] Choice 3 - Just make Payoff sides of Stoned coins blank but not power sides. 
				- [ ] This is functionally just a visual change.
				- [ ] I like this.

