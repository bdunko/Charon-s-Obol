Lift Estimates
* Very Low - Trivial, code already supports this, could add this in an hour or two.
* Low - Pretty easy, requires some small tweaks but nothing major, might take half a day.
* Medium - A bit trickier, has some new mechanics or UI. A day or two.
* Heavy - Requires a lot of effort. Several days, possibly up to a week.


---


The Lady
* Tutorial
* Rating - Essential

The Eleusinian
* Base Game
* Rating - Essential

The Urchin
* Concept - What if the shop was available during the round?
* The shop is alway available (most likely it occupies ~2 coins worth of space in the monster row, so incidentally only 4 monsters can spawn at a time in this mode). The shop stocks only a single coin at a time. The coin in stock changes each toss. You MAY purchase a coin AFTER the toss (and thus immediately use its power for that toss).
* Lift - Medium.
* Rating - 3

The Recruiter
* Concept - What if coins were drafted instead of purchased?
* After each round, instead of the shop, you are offered a ‘draft pick’ of 1 of 3 coins (or skip). The coins are free. You are offered several ‘draft picks’ between each round (2 early, 3 in the middle, 4-5 later in the game). You may also freely destroy your existing coins at any time during these picks (ie, if you see a coin you want but are already at the coin limit, you can destroy a coin you already have). When you destroy one of your coins in this way, each coin currently on offer is upgraded by 1 denomination (but only once per ‘draft pick’ probably for balance purposes so you can’t make a bunch of early Tetrobols).
* Since we are not spending souls in the shop in this game mode, they need a different purpose - each round has a soul quota which must be met, or you immediately lose (think Balattro). 
* Lift - Medium
* Rating - 4


________________


The Conscriptor (similar to Recruiter)
* Concept - What if coins were drafted instead of purchased, but also, you perform a full draft EVERY round?
* Same as Recruiter, except ALL of your coins (except a Indestruct-Obol - permanent indestructible starting coin) are destroyed between rounds. You get more ‘draft picks’ each round to compensate. Basically, you are rebuilding a row via ‘draft picks’ each round.
* Lift - Medium. Very Low after doing Recruiter.
* Rating - 4


The Gladiator
* Concept - What if the game functioned more like a traditional roguelike, where the coins serve as a mechanism to facilitate combat?
* Monsters are more numerous and stronger. Monsters have life instead of a soul cost. This game mode uses a unique set of weapon coins themed after ancient Greek weaponry. These function identically to power coins and may be used to attack monsters (ie: Power - Deal 4 damage; you click the coin to activate, then click a monster to deal the damage). Rounds do not end until all monsters are defeated. 
* You receive a base amount of souls when you destroy a monster. Additionally, when the round ends, all remaining life is converted into souls. The shop otherwise functions like normal.
* No trials.
* Lift - Heavy.
* Rating - 5


The Conqueror
* Concept - What if coins always land on heads, but we massively power up the rest of the game to compensate? Essentially - what if we didn’t have coin flips?
* Your coins land on heads 99% of the time. 
* Every (or many) round is a trial. Monsters also spawn during trials. Monsters must be defeated to advance the round. Each round has a soul quota. Tollgates are more expensive. The Nemesis is mightier.
* Lift - Low.
* Rating - 4


________________


The Engineer
* Concept - What if your final row was predetermined, and your primary decision point is the ‘build order’?
* You start with 1 standard Obol and 9 No-bols (no obols, basically ‘denomination 0 coins’ that are an outline of a coin but do not actually exist/flip yet) of randomly chosen types. The randomization may include some ‘smart selection’ to ensure you always have coins of specific types. The shop does not stock any coins. You may spend souls to upgrade a No-bol into an Obol. The amount of souls increases each time. You may then spend souls to upgrade those Obols into Diobols etc like normal.
* No tollgates (since this would mess up the row).
* Coins which relate to gaining or destroying coins will be removed from the coinpool (no Hades/Dionysus for obvious reasons). 
* Lift - Medium.
* Rating - 3


The Optimist
* Concept - What if you only have a single life?
* You start with 50 Arrow and zero life. Life does not replenish between rounds. There is no Ante. Since there is no Ante, another timer is necessary - therefore, you must always perform exactly 7 tosses per round (10 in the Nemesis round).  
* Healing coins and ignite coins/monsters are removed from the coinpool. Also possibly no coins that give additional arrows (so your starting 30 is all you can get).
* Lift - Low.
* Rating - 5


The Archon
* Concept - What if instead of being different types of coins, power and payoff coins were combined into one?
* Only power coins are available, and instead of losing life on tails, you instead gain souls. Your starting coin is a power coin based on your patron. (Coins which do not have a life penalty on tails, such as Daedalus, simply maintain their current functionality. From a code standpoint, I’m basically just replacing any “lose life” power with a “gain souls” power, and removing all payoff coins from the pool.)
* Lift - Low.
* Rating - 4


The Merchant
* Concept - What if you could sell coins back to the shop?
* You can sell coins back to the shop for a significant amount of their value (at least 50%, possibly more). You cannot upgrade coins in the shop. Whenever you purchase a coin from the shop, the shop rerolls its stock (there is no normal reroll button). 
* Lift - Very Low. 
* Rating - 4


________________


The Child
* Concept - What if the game was shorter?
* The voyage is only 5 rounds long. The third round is a trial followed by a tollgate. The fifth round is a nemesis. You start with ~4 coins based on your patron selection (essentially a ‘quickstart’, skipping the first round or two of normal buildup). All shop prices are halved (both purchases and upgrades). 
* Lift - Very Low.
* Rating - 5


The Eupatridae
* Concept - What if powers didn’t recharge naturally?
* Power coins are double sided (both sides are the power; ie you have 3 charges of Zeus on heads and 3 separate charges of Zeus on tails). Power coins do not recharge naturally in any way. When a coin is upgraded, it is fully recharged. You may upgrade Tetrobols to recharge them (but they stay as Tetrobols). Upgrading coins is cheaper.
* Lift - Medium.
* Rating - 2
The Homoioi
* Concept - What if powers didn’t recharge at all?
* Powers never recharge. When the last charge of a coin is used, the coin is destroyed. Power coins are MUCH cheaper. 
* (maybe) Power coins in the shop may randomly have more charges than normal for their denomination.
* Lift - Low.
* Rating - 4
The Emperor
* Concept - What if powers didn’t recharge until the end of the round?
* Power coins recharge at the end of each round instead of each toss. Power coins have thrice as many maximum charges. 
* Lift - Low
* Rating - 5




The Wanderer
* Concept - What if there was an endless mode?
* The game continuously loops between a normal round, a shop, and a tollgate. The tollgate’s price increases each time. After the 10th tollgate, you may choose to keep playing or go to the victory screen. The main menu tracks your high score.
* Lift - Medium.
* Rating - 4


________________


The Heretic
* Concept - What if you had access to powers in a form besides coins? (AKA - what if your only source of powers was patron tokens?)
* No power coins are available. Instead, you start the game with ~5 random gemstones (out of a selection of ~10 options), displayed near your patron token. These work similarly to the patron token - each has an associated power (such as ‘choose a coin, turn it and its neighbors over’ - I imagine most of these to be ‘overpowered’ powers compared to power coins), and you may click one, then click a coin to use that power. Like patron tokens, they do not recharge until the end of the round and each may be used only once per toss. 
* The gemstones are automatically upgraded over time (at the start of certain rounds).
* Lift - Heavy
* Rating - 5
The Blasphemer
* Concept - The Heretic, but gemstones are single use and replaced after being used.
* The same thing as Heretic, except after a gemstone is used, it is destroyed. After each payoff, you receive new random gemstones until you have ~5 again.
* Lift - Low, after Heretic.
* Rating - 4


The Ephemeral
* Concept - What if all coins were temporary?
* At the end of each round, all of your coins are destroyed (except for one Indestruct-Obol) and you receive a full refund for their soul cost. Shop rerolls reset their cost each round.
* Lift - Low.
* Rating - 5


The Challenger
* Concept - What if the we focused entirely on trials?
* The voyage starts with 2 standard rounds. After that, each round is a trial. Each trial stacks with the previous trial (ie, if the 3rd round is the Trial of Misfortune, the 4th round will be both the Trial of Misfortune AND another trial). Soul payoffs (and soul quotas for the trials) are tripled. You win after clearing the 6th trial.
* Lift - Low.
* Rating - 4


The Epilektoi
* Concept - What if you had fewer coin slots?
* You only have 5 coin slots total. Coins may be infinitely upgraded beyond Tetrobol (ie, Tetrobol+1, Tetrobol+2, Tetrobol+3) - which increases their charges further. Payoff coins are cheaper to upgrade.
* Lift - Medium.
* Rating - 3


________________


The Twins
* Concept - What if you had multiple rows?
* You have two separate rows of coins. Between each toss, the rows alternate. In the shop, you may click a button to switch between the rows, and coins you purchase go into the active row. You start with a special indestructible power coin in each row with: “Swap this coin with a coin in the other row.” (the UI for this would be, you click the coin to activate it, then it shows the other row, then you click a coin in that row to swap). This is the only way to swap coins between rows.
* Lift - Heavy.
* Rating - 1


The Physician
* Concept - What if we placed an additional emphasis on life management?
* Life does not regenerate between rounds. You start with 500 life. When you exit the shop, all unspent souls are converted into life at a 1-1 ratio. Healing is doubled. 
* Lift - Very Low.
* Rating - 4


The Champion
* Concept - Boss rush!
* The voyage consists of exactly 3 rounds, and all are Nemesis fights. Before the first round, you receive ~500 souls (number to be determined) and a shop to prepare. There are no further shops between rounds.
* Lift - Low.
* Rating - 5


The Devoted
* Concept - What if we place additional emphasis on your patron?
* You start with 3 permanent power Obols based on your patron (each patron has a pool of possible coins, 4-5 based on their theme). All other types of coins and upgrades to other types of coins cost 1.5x as much.
* Lift - Low.
* Rating - 3


The Mageiros
* Concept - What if your only power was your patron token?
* Only payoff coins are available. The only power you have access to is your patron token. Patron powers may be used more than once per toss. You may upgrade your patron token in the shop, increasing the number of charges it has each round. 
* This mode will use a custom pool of additional patrons, since many of the existing ones are not suitable for this use. The patron statue art will probably be more generic/less detailed to compensate (but still unique for each power).
* Lift - Medium.
* Rating - 4


________________


The Alchemist
* Concept - What if souls and life were a single shared resource?
* Souls and life are replaced with a single pool of ‘red souls’ (let’s just call them ‘shards’). All payoffs/powers which would give or take life or souls instead give shards. Ante costs shards and increases faster. You start the game with ~10-20ish shards, and shards do not naturally replenish at the start of each round like life does.
* Lift - Medium.
* Rating - 3


The Poet
* Concept - What if the monster row contained helpful coins instead of monsters?
* There are no monsters. Instead, the monster row contains ~4-6 random power coins. These coins flip and can be used the same way as power coins you control. Power coins cannot be purchased from the shop. 
* Since this mode cannot support monsters and trials would be very difficult to plan ahead for, the only obstacle are tollgates, but they are more numerous.
* Lift - Low
* Rating - 3
The Rhapsode
* Concept - What if the Poet could keep some of those power coins?
* The same as the Poet, except the row contains fewer coins (~3). At the end of the round, the last one you used moves into your row (you keep it, permanently). 
* Unlike the Poet, this mode has Trials and a Nemesis like normally (it is more possible to plan for them since you get to keep some coins).
* Lift - Very Low, after Poet
* Rating - 3


The Storyteller
* Concept - What if the game offered a set of score-attack challenges?
* The game consists of only a single round, where your goal is to get as many souls as possible. The coins in your row are pre-selected by the game developer to provide interesting synergies, challenges, and complexities. Additionally, specific monsters (including nemesis) or trials may be active. 
* You would be able to select from a variety of possible challenges from the main menu (before starting the run). Each tracks a separate highscore.
* Lift - Heavy.
* Rating - 5


The Charioteer
* Concept - What if the game had a real-time element?
* Your life saps away in real time (1 life per second). There is no ante.
* Lift - Low.
* Rating - 4


________________


The Demiurge
* Concept - What if there were only power coins?
* There are no payoff coins. Instead, you get 5 souls for each of your coins that end on heads. You start with 3 random power coins. The only denomination of coins available in the shop are Obols, and they are free. You get 3 (and no more than 3) free rerolls in each shop. You may destroy coins you already own while in the shop to make space. Each round has a soul quota which you must reach, or you lose.
* The idea behind combining “no payoffs” and “only Obols” is that “only Obols” means your powers are relatively weak, but you do not have the ‘useless’ payoff coins which do not help you manipulate your coins. So it ‘roughly’ evens out. Naturally, if the only coins are Obols, this means there is not much to spend your souls on in the shop, which means that rather than treating souls as a currency, we may instead treat it as a ‘minimum requirement’ for progress, hence the soul quotas. Trials and Nemesis still work like normal. Tollgates will have their requirements decreased to accommodate (and can help force some coin churn).
* Lift - Medium.
* Rating - 3


The Mendicant
* Concept - What if there was minimal ante?
* The ante is always exactly 3. Powers do not recharge each toss, and instead recharge at the end of the round.
* The original prototype of this game had no ante at all. It was quickly discovered that you could easily go infinite here by simply never having coins land on tails. At the time, I was undecided on whether powers should recharge each toss or not, but allowing them to recharge each toss was much more fun. It was far too easy to go infinite, and so I introduced the scaling ante to force the round to eventually end. With a small-but-necessary ante of 3 and no power recharges, we can replicate a similar experience to that original prototype, where the majority of your life loss comes from tails results rather than ante, and there is a greater emphasis on charge conservation.
* Lift - Low.
* Rating - 4


The Gardener
* Concept - What if coins naturally ‘grew’ over time, instead of being upgraded by the player?
* When the round ends, each of your coins are upgraded once. If a coin would be upgraded in this way while it is already a Tetrobol, it ‘wilts’ and is destroyed instead. The shop stocks only Obols (and their prices are increased to compensate). When you leave the shop, your remaining souls are converted to life at a 1-1 ratio. You cannot upgrade coins in the shop.
* Lift - Low.
* Rating - 4


________________


The Lovers
* Concept - What if power coins were double sided?
* All power coins are double sided. Their tails side is a randomly chosen god power of the opposite gender (ex: Obol of Aphrodite and Zeus). Coin powers only recharge by 1 each toss (each side recharges by 1). 
* The reduced recharge is to compensate for the fact that you have twice as many powers, and also power coins are generally much stronger since they never land on a penalty.
* Lift - Low.
* Rating - 4


The Artist
* Concept - What if coin powers were algorithmically generated?
* All power coins have randomly generated powers on heads, and normal life penalties on tails. 
* The randomly generated powers essentially are randomly chosen combinations of existing effects. For example “Reflip a coin and Freeze it”. “Make a coin Lucky and Bury it for 2 payoffs”. Basically, they are relatively simple combinations, but randomly generated each time from a ~large pool of ‘parts’. 
* Lift - Heavy
* Rating - 2


The Heir
* Concept - How influential is a boosted start?
* You start with 100 souls and at a shop. Your life is halved in all rounds. 
* Lift - Low.
* Rating - 2


The Withering
* Concept - What if coins gradually degraded?
* The shop only stocks Tetrobols. At the end of each round, all of your coins are downgraded once (reminder that Obols are destroyed when downgraded). Shop prices are adjusted to compensate.
* Lift - Low.
* Rating - 4


The Phrygian
* Concept - How could we make infinite use powers fair?
* All coins have infinite uses. When you deactivate a coin power, that coin is destroyed and you gain souls based on its value.
* As monsters are quite weak in this mode (you can get a bunch of souls at the start of the round by self-destructing your coins), the Nemesis is not a suitable final challenge. A trial will be used instead.
* Lift - Medium.
* Rating - 3


________________


The Architect
* Concept - What if there were no souls and no shop?
* You start with exactly the following three coins:
   * Dionysus - Gains coins. 
   * Hermes - Exchanges coins.
   * Hephaestus - Upgrades coins.
* Payoff coins are removed from the coinpool. Because there are no souls, monsters do not spawn and there is no nemesis. There are additional tollgates and trials to compensate. 
* Lift - Low.
* Rating - 3


The Archer
* Concept - What if powers had a separate, shared resource instead of individual charges?
* Powers cost arrows to use instead of charges. You start with an additional coin which generates arrows on payoff on both sides (with heads giving more than tails).  
* Lift - Low.
* Rating - 4


The Adherent
* Concept - What if only a single type of power coin was available?
* Only a single type of power coin is available. This coin is randomly chosen based on your patron choice (each patron will have a pool of 3-5 suitable coins for a monotype run). You start with one copy of this coin. The shop still stocks all types of payoff coins, like normal.
* Lift - Low.
* Rating - 5


The Heliast
* Concept - What if the game’s probabilities rebalanced themselves dynamically?
* During payoff, the global chance of coins landing on heads increases by 2% for each coin on head and decreases by 1% for each coin on tails. 
* This is tracked via the same ‘flame’ indicator used by Prometheus.
* Lift - Low.
* Rating - 2


The Hoplite
* Concept - What if coins were looted from monsters?
* The shop offers no coins. You get a coin whenever a monster is destroyed; the denomination of the coin received is based on the strength of the monster (plus some slight random chance). Monsters respawn infinitely. You can sell coins back to the shop for additional life. 
* (maybe) If you gain a coin from a monster when the row is full, the leftmost coin is destroyed and the rightmost coin is upgraded. 
* Lift - Medium.
* Rating - 2


________________


The Sylvan
* Concept - What if monsters were friendly... sort of.
* Monsters spawn with a god power on heads side and a random monster power on their tails side (some may be excluded if they would not make sense without both sides being dedicated to the monster). You can activate the power as if you owned it while the coin is on heads. Monsters cannot be destroyed by spending souls. Power coins are available in the shop, but more expensive (likely 2x as much). 
* Since the Nemesis does not make as much sense in this mode, it will likely be replaced by a trial. These special monsters still spawn during the trial to ‘assist’. 
* Lift - Medium.
* Rating - 3


The Anointed
* Concept - What if the game was cast as a duel between gods, with greater emphasis on your god power?
* You start with an additional power coin favored by your god (chosen from that god’s pool of 3-5 coins). Whenever you use a power coin favored by your god, your patron token gains 1 charge. Favored coins use a unique coin shape to indicate that they are favored. Charon gets angry 3x as fast. 
* Lift - Medium.
* Rating - 2


The Fool
* Concept - What if you couldn’t see what you buy?
* You cannot see the power of your coins until you’ve used them once. All coins in the shop cost the same amount of souls. You don’t know the denomination of the coin until you use it (but the denominations available in the shop gradually increase over the course of the run like normal).
* Lift - Medium.
* Rating - 3


The Banker
Concept - What if you could keep souls between rounds?
* You do not lose souls between rounds. Tollgates cost both souls AND coins (if you do not have enough of either, you lose). Instead of a nemesis, there is a large tollgate at the end. The main menu tracks how many souls you ended with (as a highscore). 
* Lift - Low
* Rating - 3


The Reductionist
* Concept - What if there was only one denomination?
* All coins are Diobols. There are fewer rounds and the game does not scale up as quickly.
* Lift - Low.
* Rating - 1


________________


The Gambler
* Concept - What if the game was higher-risk higher-reward?
* There is an additional payoff phase that resolves immediately after the toss. So each toss is: toss, payoff, use your powers, payoff again. 
* Note that this increases the value of statuses like Lucky and Bless, since it increases the probability that your coin will naturally land on heads for the first payoff (which occurs before you can use reflip powers).
* Lift - Low.
* Rating - 2


The Philosopher
* Concept - What if, outside of the initial toss, there was no luck?
* Except for the very first toss each round, when flipped, coins always land on their opposite face. All life penalties are reduced to 1 (since avoiding tails is impossible).
* Lift - Low.
* Rating - 2


The Collector
* Concept - What if the game used a bag building mechanism (this is something from board games)?
* You start the game with a bag on the right side of the table. Whenever you obtain a coin, it is placed in the bag. During each toss, half of the coins in your bag (to a minimum of 1 and maximum of 10) are drawn from the bag and tossed. They are returned to the bag after payoff.
* Coins cannot be removed from the bag unless they are destroyed.
* If a coin is inflicted with a status, that status remains until the end of the round, then clears itself like normal.
* Coins cannot be upgraded at the shop. (because they are in a bag); so the only thing you can do in a shop is buy more coins. Note that since it is very hard to remove coins, you don’t want to flood the bag with too many lower denominations, maintaining a good balance between coins in the bag is critical.
* You can view the contents of the bag at any time. 
* After the Nemesis round, there is a final tollgate where you must have a certain value worth of coins beyond the normal possible limit (ie, normally you cannot have more than 10 Tetrobls = 40 coin value, but the bag has infinite space, so asking for ~50 value is possible). There are no tollgates except the final one (because the interface work to choose specific coins to give away from the bag would be too much work). Everything else operates like normal.
* Lift - Heavy
* Rating - 4












________________


---
ignore this template i’m copy pasting, thanks


The C
* Concept - W
* W
* Lift - W