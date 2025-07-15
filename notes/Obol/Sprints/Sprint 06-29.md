
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
### Done  
- [x] **Building Blocks Revisit**
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
- [x] Add coin shake effect (move sprite left/right slightly)
	- [x] When projectile hits, have the target coin shake.
	- [x] When a monster attempts to activate with no target, shake.
- [x] Add projectiles to monster powers.
- [x] Add can_use to monster powers.
- [x] When monsters are in play, Charon's hands should move up a bit. 
- [x] Fix visual appearance of projectiles. Improve handling of speed... add a minimum and maximum duration perhaps? 
	- [x] Possibly need to await the payoff coin moving up before triggering payoff (or just cheat and increase the height of the delay hop projectiles. Additionally, might consider reducing the amount they go up slightly, it's a bit much and eats up a lot of space? Projectile visiblity isn't amazing; maybe need to consider using a different color than purple in the default case.
- [x] Add projectiles to trial powers where relevant.
	- [x] Misfortune
	- [x] Vivisepulture (at start)
	- [x] Vengeance
	- [x] Torture
	- [x] Petrification
	- [x] Silence
- [x] Hide monster appease costs during payoff sequence (blocks projectiles a bit and uninteractable during this time)

---
## 📝 Quick To-Dos  
_Untracked or small tasks not managed in the structured lists._
- [x] Simple sounds VST investigate

---
## 🏆 Wins & Highlights
_Recap of key achievements from this sprint to highlight._
- Learned more about seamless audio looping, and added a Quite Notes section.
- Switched to using Git LFS for audio tracking.

---
## 🔍 Sprint Review (07-12)  
**What went well:**  
* Increased integration with AI assisted programming.
* Lots of nice new visual improvements.

**What didn’t go well:**  
-  Underestimated integration time for polish features.

**What I’ll change next sprint:**  
- Add most critical leftover polish work to next sprint. 
- Cut unnecessary polish work/move to backlog.
- Delay composition work until next sprint.
- Revisit Building Blocks for practice/to maintain musical focus until next sprint.
	- Maybe take the time to attempt some study of specific inspiration tracks?


```
var targets = Global.choose_x(_COIN_ROW.get_multi_filtered_randomized([CoinRow.FILTER_NOT_UNLUCKY, CoinRow.FILTER_CAN_TARGET]), Global.MISFORTUNE_QUANTITY)
var callback = func(target):
	target.make_unlucky()
	target.play_power_used_effect(Global.TRIAL_POWER_FAMILY_MISFORTUNE)
Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_MISFORTUNE)
		await ProjectileManager.fire_projectiles(Global.find_passive_coin(Global.TRIAL_POWER_FAMILY_MISFORTUNE), targets, callback)

```
