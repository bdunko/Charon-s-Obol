
---
## ⌚ Deep Work
| Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday |
| ------ | ------- | --------- | -------- | ------ | -------- | ------ |
|        | ✔       | ✔         | ✔<br>    | ✔<br>  | ✔<br>    | ✔<br>  |
| ✔<br>  | ✔<br>   | ✔<br>     | ✔<br>    | ✔<br>  |          |        |

---
## 🎯 Sprint Goal  
Finish the sound design of the god selection screen. Begin polishing epic, starting with the most high priority items - death effect, improved payoff effects, and life loss vignette. Complete Building Blocks 2.

---
## 🧠 Dev Notes & Observations  
- Investigate how to continue musical education after completing Building Blocks 2. Check access to Foundations again. Reflect on this a bit.

| Shortcut           | Action                                        |
|--------------------|------------------------------------------------|
| Ctrl + Shift + O   | Quick Open (scripts/scenes)                    |
| Ctrl + L           | Go to Line                                     |

---
## 🗂️ Sprint Task Lists
### To Do  
- [ ] Improve the feedback for payment of life at toss's start. Maybe having Charon's hand move over to grab the fragments, then slam down to flip the coins, or something like that. Even adding a slight delay might help. This slam should have a more basic effect than the malice slam. 
- [ ] Add a floating label effect for the lift loss when Charon takes life for ante.
- [ ] When Charon goes to slam, make him raise his hands slightly first. 
- [ ] Refactor - make it possible for a single sound effect to contain multiple audio files (layers). When playing this sound effect, fire off both. Switch to using this for the layered transition.
### In Progress  
- [ ] For the label; When losing souls, flash red. When healing life, flash green. (ie, flash specific colors on label instead of always the same). 
- [ ] Add a life-loss vignette effect. It should be a red tint around the screen edge, in a circular pattern. Whenever you lose life, flash the vignette - more dramatic the lower on life you are. Only start applying when life is below half.
- [ ] When you are very low on life, the vignette should stay visible (but slight), with a pulsing effect. 
### Done  
- [x] Extend and improve Thunderstorm sound.
- [x] Building Blocks 2 - Bass - 7's & The Octave 
- [x] Building Blocks 2 - Chords 7's & The Octave
- [x] Building Blocks 2 - Melody - 7's & The Octave
- [x] Building Blocks 2 - All Together 3
- [x] Building Blocks 2 - Drums - Removing Backbeats
- [x] Building Blocks 2 - Bass, Chords, and Melody - Removing Backbeats
- [x] Building Blocks 2 - Chords - Inversions
- [x] Building Blocks 2 - Chords - Inversions 2
- [x] Building Blocks 2 - All Together 4
- [x] Building Blocks 2 - No Labels 2
- [x] Re-export Divine, Voice, and Transition audio effects and trim silence in Audacity again, ensuring that sounds are not being abruptly cut off. Increase the silence tolerance and threshold, most likely.
- [x] Figure out sound when hovering a patron statue.
- [x] Create a shorter sound for PatronStatueClicked. - decided not necessary
- [x] Add Death Sequence.
- [x] Review sound balancing of patron selection screen.
- [x] Create a custom label class 'AnimatedLabel' which has fancier graphical effects for switching between values. I want to aim for an effect like wood burning - flash the new value in purple, as the previous value fades out. The new value fades into the standard black color.
- [x] Change life and souls labels to use AnimatedLabel
- [x] Add LabelSpawner as a global autoload singleton. This class is responsible for spawning one-shot label effects. 
- [x] Add rising and flashing text labels to payoff animation. The labels should show the amount of souls/life earned/lost.
- [x] Make floating label work with Phaethon.
- [x] Update patron token powers (Demeter/Hades/Dionysus) to also use floating labels properly (gain souls/life etc).
- [x] Update patron token passives to use floating labels. Add a ptr to patron token in Global so we can create the label for Demeter in heal_life. 
- [x] Whenever life/souls change, add a label including a sum of life lost/souls earned under those piles. This label should update as payoffs occur.
- [x] Add floating label at start of round for life regen. I guess it can just appear in the middle of the board, as "Take a deep breath" happens.

---
## 📝 Quick To-Dos  
_Untracked or small tasks not managed in the structured lists._
- [x] Maybe I should start using Forest again. It's a good way to time deep work.
- [ ] 33 Strategies of War - Robert Greene
- [ ] Mastery - Robert Greene
- [x] Look into Super Audio Cart for sound sources. 
- [ ] Install Super Audio Cart
- [ ] Download MP3 for inspiration songs.
- [ ] Might be nice to have a way to layer sound effects more natively in my sfx system - instead of having to tell it to play two sounds, have some way to have a single effect contain multiple 'sounds'. Probably can do this by making Effect.new not take anything in ctor, then chain something like ".sound(....)" in a builder pattern.
- [ ] Start looking into AP test prep - build up some study guides and question banks, annotated exam solutions, etc.

---
## 🏆 Wins & Highlights
_Recap of key achievements from this sprint to highlight._
- Started organizing notes as sprints.
- Completed Patron Selection screen sounds.
- Learned how to fix shader so it works with label colors.
- Floating label effect.
- Animated label effect/Label Spawner.
- Delta label effect. (lots of labels apparently)

---
## 🔍 Sprint Review (06-30)  
**What went well:**  
-  

**What didn’t go well:**  
-  Need to think about a better organization/way to handle the sound effects in Ableton; split existing content into multiple projects. It takes too long to export and is too annoying.
	- Split into projects:
		- Water UI
		- PatronSelect
			- Divine, Voices, Writing, Transitions
		- Ambiances
		- Coingame

**What I’ll change next sprint:**  
-  


| Shortcut           | Action                                        |
|--------------------|------------------------------------------------|
| Ctrl + Shift + O   | Quick Open (scripts/scenes)                    |
| Ctrl + L           | Go to Line                                     |