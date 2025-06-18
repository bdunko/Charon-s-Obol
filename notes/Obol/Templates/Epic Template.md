<%*
const epicTitle = await tp.system.prompt("Epic Title");
const fileName = `Epic – ${epicTitle}`;
await tp.file.rename(fileName);
await tp.file.move("Epics/" + fileName);
%>
## 🎯 Objective  
What is the user need, opportunity, or goal this epic addresses?

## 🔍 Notes & Design Decisions  
Context, architecture thoughts, design links, or tradeoffs

## ✅ Done Criteria  
What must be true to consider this epic complete?

---
