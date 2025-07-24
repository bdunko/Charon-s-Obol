
## 🎯 Sprint Goal  
_A short statement of the focus or milestone for this sprint._

---
## 🧠 Dev Notes & Observations  
_Casual thoughts during the sprint—design decisions, feedback, blockers._

| Shortcut         | Action                      |
| ---------------- | --------------------------- |
| Ctrl + Shift + O | Quick Open (scripts/scenes) |
| Ctrl + L         | Go to Line                  |

```
		var targets = []
		
		var callback = func(target):
			downgrade_coin(target)
			target.play_power_used_effect(Global.TRIAL_POWER_FAMILY_TORTURE)

		await ProjectileManager.fire_projectiles(Global.find_passive_coin(Global.TRIAL_POWER_FAMILY_TORTURE), targets, callback)


```

Maybe consider adding an additional difficulty tweak to the second difficulty level - remove the 'buffer' round at the very start of the game. This tightens things up considerably. Alternatively this could be part of a different difficulty tier...
- [ ] Diff 2 - Charon slams - idea is to introduce more randomness and less 'steady state'.
- [ ] Diff 3 - Trials boost - make trials a more common loss condition, make them REALLY important to pay attention to.
- [ ] Diff 4 - Tollgate boost + shop increase - force more optimal overall play; make tollgates a larger threat to plan for.
- [ ] Diff 5 - monster + nemesis powerup - make monsters a more credible threat, in particular, make strategies focused on killing all monsters less optimal; I'd prefer if you have to triage.

---
## ⌚ Deep Work (and Start Times) ✔

| Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday |
| ------ | ------- | --------- | -------- | ------ | -------- | ------ |
| 8✔     | 12✔     | ✔         | ✔        | ✔      | ✔        | ✔      |
| ✔      | ✔       | ✔         |          |        |          |        |

---
## 🗂️ Sprint Task Lists
### To Do  
- [ ] **Music Study**
	- [ ] Bring into DAW and focused listening/reproduction.
	- [ ] SMTII - Shop
	- [ ] SMTIVA - F8
- [ ] **Arrows of Night**
	- [ ] Make arrows follow mouse (move to center and rotate to follow mouse patron token?); even better if they actually shoot when used
	- [ ] Arrows are placed on table from Charon like other things.
	- [ ] Add back the slight randomness to arrow pile, it was better. 
- [ ] **Game Sounds**
	- [ ] **Essentials**
		- [ ] Power Activated/Deactivated - Water UI
		- [ ] Hover Map (use standard button sound) - Water UI
		- [ ] Coin
			- [ ] Buy Coin (refactor)
			- [ ] Coin Toss (refactor)
			- [ ] Coin Land (refactor) 
			- [ ] Coin Turn (refactor)
			- [ ] Destroy Coin
			- [ ] Downgrade Coin
		- [ ] Lose Souls (based off of Earn Souls)
		- [ ] Earn Souls 
		- [ ] Shoot Arrow
		- [ ] Heal Life (based off of Lose Life?)
			- [ ] play mild green vignette for heal
		- [ ] Lose Life
		- [ ] IgniteTakeDamage

- [ ] **Transient Sounds**
	- [ ] **Death Scene**
		- [ ] Death scene ambiance.
		- [ ] Death scene fade out
	- [ ] **Victory**
		- [ ] Victory fade out - try using the divine ambiances again for this.

### In Progress  
- [ ] **Building Blocks Best Hits - No Hints**
	- [x] BB1 - Chords 7: Arpeggiation
	- [x] BB2 - Melody 3: Grace Notes
	- [x] BB1 - Drums, Bass, and Chords 2
	- [x] BB1 - Drums, Bass, and Chords 3
	- [x] BB1 - Drums, Bass, and Chords 4
	- [x] BB1 - No Labels 1
	- [x] BB2 - All Together 1
	- [x] BB2 - All Together 2
	- [x] BB2 - All Together 3
	- [ ] BB2 - All Together 4
	- [ ] BB2 - No Labels 2
- [ ] **Improved Graphical effects for coins**
	- [x]  Lag when a large number of life or souls are moving due to particles. Fix this by limiting the number that can be emitting at a time (possibly a static variable?)
	- [x] Play slight particle effect for any power use (burst of colored pixels, color changes per coin).
		- [x] Make the color change per power used.
		- [x] Don't trigger on payoffs, just on power used.
	- [x] Activating a coin - burst of particles; can use a similar effect, maybe make it emit from the coin shape itself. Maybe play the effect in reverse, towards the mouse? could be cool.
	- [ ] When purchasing a coin from the shop, play flip animation as it moves into player row.
	- [ ] Dust particles when buying coin from shop do not operate properly. 
	- [ ] Coin flip shadow - experiment with simple shadow.

### Done  
- [x] Blessed tooltip shows (HEADS) - replacement not being performed. Ensure status tooltips being shown on status bar have proper placeholder replacement.
- [x] Add projectiles to Malice activations.
- [x] Add ProjectileShooter node.
- [x] Refactor coin to use ProjectileShooter node.
- [x] Update Dialogue such that we can show dialogue, then make it advancable at a later point and await it.
- [x] **Charon Improvements**
	- [x] When Charon goes to slam, make him raise his hands slightly first.
	- [x] Improve the feedback for payment of life at toss's start. Have Charon's hand move over to grab the fragments as the retraction happens
- [x] **Coin Flip Animation**
	- [x] Coins can hang slightly higher at the peak of their toss (minor hang time); also probably should not be using a linear trans (if they currently are...).
	- [x] Effect when a coin is tossed or lands(?)
	- [x] Play dust effect when the row is expanded, but not during the middle of tosses (needs special handling. We might be able to get away with always playing the dust effect, but pass a bool to expand if during flip to disable. Because during flip we only play the effect after the coins land.)
- [ ] **Improved Graphical Effects for Coins**
	- [x] Fix dust particles sometimes not showing, if they are still active when they would restart.
	- [x] Flash on upgrade (in shop too).
	- [x] Shake when this coin's power is used.
	- [x] Move up when power is activated. Move down when power is deactivated.


---
## 📝 Quick To-Dos  
_Untracked or small tasks not managed in the structured lists._
- [x] Update laptop with Charon's Obol for work travel.
- [x] 33 Strategies of War - Robert Greene
- [ ] Mastery - Robert Greene
- [ ] Run MemTest86 - need a flash drive.
- [ ] Find an easier website maker - look into Squarespace

---
## 🏆 Wins & Highlights
_Recap of key achievements from this sprint to highlight._
- 

---
## 🔍 Sprint Review (07-27)  
**What went well:**  
-  

**What didn’t go well:**  
-  

**What I’ll change next sprint:**  
-  
