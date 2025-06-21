
---
## ⌚ Deep Work
| Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday |
| ------ | ------- | --------- | -------- | ------ | -------- | ------ |
|        | ✔       | ✔         |          |        |          |        |
|        |         |           |          |        |          |        |

---
## 🎯 Sprint Goal  
Finish the sound design of the god selection screen. Begin polishing epic, starting with the most high priority items - death effect, improved payoff effects, and life loss vignette. Complete Building Blocks 2.

---
## 🧠 Dev Notes & Observations  
- Investigate how to continue musical education after completing Building Blocks 2. Check access to Foundations again. Reflect on this a bit.

---
## 🗂️ Sprint Task Lists
### To Do  
- [ ] Add a life-loss vignette effect. It should be a red tint around the screen edge, in a circular pattern. Whenever you lose life, flash the vignette - more dramatic the lower on life you are.
- [ ] When you are very low on life, the vignette should stay visible (but slight), with a pulsing effect. 
- [ ] Spike - think about ways to improve the feedback for payment of life at toss's start. Maybe having Charon's hand move over to grab the fragments, then slam down to flip the coins, or something like that. Even adding a slight delay might help. 
- [ ] Refactor - make it possible for a single sound effect to contain multiple audio files. When playing this sound effect, fire off both.
- [ ] Building Blocks 2 - Chords - Inversions
- [ ] Building Blocks 2 - Chords - Inversions 2
- [ ] Building Blocks 2 - All Together 4
### In Progress  
- [ ] Create a custom label class 'TransformingLabel' which has fancier graphical effects for switching between values. I want to aim for an effect like wood burning - flash the new value in purple, as the previous value fades out. The new value fades into the standard black color.
- [ ] Add rising and flashing text labels to payoff animation. The labels should show the amount of souls/life earned/lost.
- [ ] During payoff, add a label including a sum of life lost/souls earned under those piles. This label should update as payoffs occur.
### Done  
- [x] Extend and improve Thunderstorm sound.
- [x] Building Blocks 2 - Bass - 7's & The Octave 
- [x] Building Blocks 2 - Chords 7's & The Octave
- [x] Building Blocks 2 - Melody - 7's & The Octave
- [x] Building Blocks 2 - All Together 3
- [x] Building Blocks 2 - Drums - Removing Backbeats
- [x] Building Blocks 2 - Bass, Chords, and Melody - Removing Backbeats
- [x] Re-export Divine, Voice, and Transition audio effects and trim silence in Audacity again, ensuring that sounds are not being abruptly cut off. Increase the silence tolerance and threshold, most likely.
- [x] Figure out sound when hovering a patron statue.
- [x] Create a shorter sound for PatronStatueClicked. - decided not necessary
- [x] Add Death Sequence.
- [x] Review sound balancing of patron selection screen.

---
## 📝 Quick To-Dos  
_Untracked or small tasks not managed in the structured lists._
- [x] Maybe I should start using Forest again. It's a good way to time deep work.
- [ ] 33 Strategies of War - Robert Greene
- [ ] Mastery - Robert Greene
- [ ] Look into Super Audio Cart for sound sources. 
- [ ] Might be nice to have a way to layer sound effects more natively in my sfx system - instead of having to tell it to play two sounds, have some way to have a single effect contain multiple 'sounds'. Probably can do this by making Effect.new not take anything in ctor, then chain something like ".sound(....)" in a builder pattern.
- [ ] Start looking into AP test prep - build up some study guides and question banks, annotated exam solutions, etc.

---
## 🏆 Wins & Highlights
_Recap of key achievements from this sprint to highlight._
- Started organizing notes as sprints.
- Completed Patron Selection screen sounds.

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
