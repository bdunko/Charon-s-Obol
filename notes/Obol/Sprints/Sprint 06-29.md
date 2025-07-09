
## 🎯 Sprint Goal  
Finish polishing epic, completing major polishing improvements for the foreseeable future by end of sprint. Set everything up to begin making music next week - prepare all inspiration tracks, create Building Blocks notes, have all plugins ready/organized in Ableton.

---
## 🧠 Dev Notes & Observations  
_Casual thoughts during the sprint—design decisions, feedback, blockers._

| Shortcut         | Action                      |
| ---------------- | --------------------------- |
| Ctrl + Shift + O | Quick Open (scripts/scenes) |
| Ctrl + L         | Go to Line                  |

Checking vignette effect requires making the 'editor' space match the game window size, since it is a screen space shader - 
![[Pasted image 20250701230351.png]]

![[Pasted image 20250704010001.png]]

---


## ⌚ Deep Work (and Start Times) ✔

| Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday |
| ------ | ------- | --------- | -------- | ------ | -------- | ------ |
| 8✔ 10✔ | 7✔      | 10✔       | 7✔12✔    | ✔      | 1am✔     | 10✔    |
| 7✔     |         |           |          |        |          |        |

---
## 🗂️ Sprint Task Lists
### To Do  
- [ ] **Charon Improvements**
	- [ ] When Charon goes to slam, make him raise his hands slightly first. 
	- [ ] Improve the feedback for payment of life at toss's start. Have Charon's hand move over to grab the fragments, then slam down to flip the coins, or something like that. Even adding a slight delay might help. This slam should have a more basic effect than the malice slam, but can otherwise be similar.
- [ ] **Improved Graphical effects for coins**
	- [ ] Play slight particle effect for any power use (burst of colored pixels, color changes per coin).
	- [ ] Activating a coin - burst of particles; let's also make the coin rise up slightly while activated like it used to (that was kinda cool)
	- [ ] Deactivate a coin - move it back down
	- [ ] Use a power - we already show an icon, experiment with also doing a particle effect.
- [ ] **Coin Flip Animation**
	- [ ] Coins can hang slightly higher at the peak of their toss (minor hang time); also probably should not be using a linear trans (if they currently are...).
	- [ ] Effect when a coin is tossed or lands(?)
- [ ] **Arrows of Night**
	- [ ] Make arrows follow mouse or something (move to center and rotate to follow mouse patron token?); even better if they actually shoot when used
	- [ ] Arrows are placed on table from Charon like other things.
	- [ ] Add back the slight randomness to arrow pile, it was better. 
- [ ] **Screen Shake**
	- [ ] Screen shake on Charon slam.
	- [ ] Screen shake during death.
	- [ ] Camera zoom in/out slightly during death.

### In Progress  
- [ ] **Enhanced Monster Effects (Projectile animations)**
	- [ ] Add projectiles for monster coins targetting coins in player's row.
		- [ ] projectilesystem creates projectiles (Sprite2D with particles in charge of moving), signal when it hits
		- [ ] Just need to await for it to finish
			- [ ] if there are multiple, it's slightly trickier. maybe we actually create a projectilesystem, which can manage multiple projectiles and signals when both are done? seems reasonable. it can keep a reference count
		- [ ] To make a curved path projectile, x and y simply need to follow different functions over the same time interval; aka use two tweens (one for x and one for y) with different trans. One linear and one expo (or other) will achieve this effect.
	- [ ] Just make a single projectile (animated); recolor depending on status being applied.
	- [ ] Souls spent to defeat monsters should move to them somehow (turn into particles and move to the coin or whatever)
	- [ ] When a monster attempts to activate with no target, it should just shake slightly.

### Done  
- [ ] **Building Blocks Revisit**
	- [x] Shifted Snare
	- [x] Chord Changes
	- [x] Multi-Chord Bars
	- [x] Bass Expression
	- [x] Tom-Centric Grooves
	- [x] Half-Time
	- [x] All Track Anticipation
	- [x] 16th Shuffle
	- [x] 4-Bar Chord Progression
	- [x] Removing Backbeats
- [x] Monday Sprint Planning - polish epic.
- [x] Ableton prep - Make a group containing all plugins I'll be using. M1, common/standard ableton effects, drums.
- [x] Download reference tracks
- [x] Add obol flip vignette (purple pulsate slow/mid).
- [x] Add death vignette (blue pulsate fast)
- [x] Improve vignette shader appearance - see ChatGPT conversation. https://chatgpt.com/c/6861fe0a-3854-8013-be5f-4e63eea6ccc0
- [x]  Improve Vignette appearance.
- [x] Switch to tweening the opacity (transparency uniform) instead of the radius. We prede
- [x] **Vignette**
	- [x] Add ambient pulse using a sin wave to the contrast (see ChatGPT).
- [x] Check on HeavyWater loop... didn't sound clean.
- [x] Disintegrate temp labels from spawner
- [x] **Life/Soul Labels**
	- [x] Need to fade in the life and soul labels a bit earlier I think, otherwise it looks a bit weird with the initial +100 popup... idk.
	- [x] Apply disintegrate effect instead of fading in/out for the delta labels.
- [x] Pile of life/souls should be in a circular pile instead of square.
- [x] The status/power used effect (the icons) that appears on coins could probably afford to last slightly longer. I think the fade could be faster - stay fully visible longer, fade quicker.
- [x] Trail for lives & souls
- [x] River on the left/right should scroll during voyage.
- [x] Staggered movement of life/souls - adjust so that if >30, we use a diff timing so it doesn't take forever.
- [x] When we raise the ante (river changes color), also change the color of the board and highlight on charon's land, life, and souls. helps sell the color effect

---
## 📝 Quick To-Dos  
_Untracked or small tasks not managed in the structured lists._
- [ ] 33 Strategies of War - Robert Greene
- [ ] Mastery - Robert Greene
- [ ] Ear Training
- [x] Simple sounds VST investigate

---
## 🏆 Wins & Highlights
_Recap of key achievements from this sprint to highlight._
- Learned more about seamless audio looping, and added a Quite Notes section.
- Switched to using Git LFS for audio tracking.

---
## 🔍 Sprint Review (07-12)  
**What went well:**  
-  

**What didn’t go well:**  
-  

**What I’ll change next sprint:**  
-  
