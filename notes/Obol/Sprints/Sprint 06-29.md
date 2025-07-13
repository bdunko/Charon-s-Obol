
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
| 7✔     | 10✔     | 10✔<br>   | ✔        | 12✔    | 11✔      | 4✔     |

---
## 🗂️ Sprint Task Lists
### To Do  

### In Progress  
- [x] Add coin shake effect (move sprite left/right slightly)
	- [x] When projectile hits, have the target coin shake.
	- [x] When a monster attempts to activate with no target, shake.
- [x] Add projectiles to monster powers.
- [x] Add can_use to monster powers.
- [x] When monsters are in play, Charon's hands should move up a bit. 
- [x] Fix visual appearance of projectiles. Improve handling of speed... add a minimum and maximum duration perhaps? 
	- [x] Possibly need to await the payoff coin moving up before triggering payoff (or just cheat and increase the height of the delay hop projectiles. Additionally, might consider reducing the amount they go up slightly, it's a bit much and eats up a lot of space? Projectile visiblity isn't amazing; maybe need to consider using a different color than purple in the default case.
- [ ] Add projectiles to trial powers where relevant.
	- [x] Misfortune
	- [ ] Vivisepulture (at start)
	- [ ] Vengeance
	- [ ] Torture
	- [ ] Petrification
	- [ ] Silence
	- [ ] Tribulations
- [ ] Add projectiles to Malice activations.
- [ ] Hide monster appease costs during payoff sequence (blocks projectiles a bit and uninteractable during this time)
- [ ] Flip position of pile and label for pile (label goes on top)
- [ ] **Charon Improvements**
	- [ ] When Charon goes to slam, make him raise his hands slightly first. (I think he already does this)
	- [ ] Improve the feedback for payment of life at toss's start. Have Charon's hand move over to grab the fragments, then slam down to flip the coins, or something like that. Even adding a slight delay might help. This slam should have a more basic effect than the malice slam, but can otherwise be similar.
- [ ] **Improved Graphical effects for coins**
	- [ ] Play slight particle effect for any power use (burst of colored pixels, color changes per coin).
	- [ ] Activating a coin - burst of particles; 
	- [ ] Use a power - we already show an icon, experiment with also doing a particle effect. Also perhaps shake.
	- [ ] Shadow - add a static sprite underneath the coin. This might look good enough with how flips work. If not, we can try animating it too. 
	- [ ] When purchasing a coin from the shop, play flip animation as it moves into player row.
	- [x] Flash on upgrade (in shop too).
	- [x] Shake when this coin's power is used.
	- [x] Move up when power is activated. Move down when power is deactivated.
- [ ] **Coin Flip Animation**
	- [x] Coins can hang slightly higher at the peak of their toss (minor hang time); also probably should not be using a linear trans (if they currently are...).
	- [ ] Effect when a coin is tossed or lands(?)
- [ ] **Arrows of Night**
	- [ ] Make arrows follow mouse or something (move to center and rotate to follow mouse patron token?); even better if they actually shoot when used
	- [ ] Arrows are placed on table from Charon like other things.
	- [ ] Add back the slight randomness to arrow pile, it was better. 
- [ ] **Screen Shake**
	- [ ] Screen shake on Charon slam.
	- [ ] Screen shake during death.
	- [ ] Camera zoom in/out slightly during death.
- [ ] Souls spent to defeat monsters should move to them somehow (turn into particles and move to the coin or whatever)
	- [ ] Souls visibly shatter (disintegrate); then we launch an invisible projectile with particle trail towards the monster coin as it disintegrates.

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
- [x] Handle multiple projectiles at a time. 
- [x] Add animation to circular projectile.
- [x] Decrease projectile speed a bit.
- [x] Make particle smaller
- [x] Make movement linear again...
- [x] Remove delta labels.
- [x] Make projectile recolorable. Define appropriate recolor options in Projectile itself. We can do a style enum sort of thing.
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
