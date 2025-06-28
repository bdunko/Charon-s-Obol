<%*
const start = tp.date.now("MM-DD");
const end = tp.date.now("MM-DD", 13);
const fileName = `Sprint ${start}`;
await tp.file.rename(fileName);
await tp.file.move("Sprints/" + fileName);
%>
## 🎯 Sprint Goal  
_A short statement of the focus or milestone for this sprint._

---
## 🧠 Dev Notes & Observations  
_Casual thoughts during the sprint—design decisions, feedback, blockers._

| Shortcut         | Action                      |
| ---------------- | --------------------------- |
| Ctrl + Shift + O | Quick Open (scripts/scenes) |
| Ctrl + L         | Go to Line                  |

---
## ⌚ Deep Work
| Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday |
| ------ | ------- | --------- | -------- | ------ | -------- | ------ |
|        |         |           |          |        |          |        |
|        |         |           |          |        |          |        |

---
## 🗂️ Sprint Task Lists
### To Do  
- [ ]  
### In Progress  
- [ ]  
### Done  
- [ ]  

---
## 📝 Quick To-Dos  
_Untracked or small tasks not managed in the structured lists._
- [ ]  
- [ ]  
- [ ]  

---
## 🏆 Wins & Highlights
_Recap of key achievements from this sprint to highlight._
- 

---
## 🔍 Sprint Review (<%- end %>)  
**What went well:**  
-  

**What didn’t go well:**  
-  

**What I’ll change next sprint:**  
-  
