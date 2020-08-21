# DFHack script: Fair Needs 

Version: 0.9 BETA
Download: https://github.com/skeldark/scripts/tree/master

We know the Need system is quite bugged at the moment and it gets worse with the age of your fortress.

In my opinion the Problem is, that dwarfs show no interest in fulfilling their needs them self.
Its the players job to create the environment but its the dwarfs job to use this environment depending on his needs.
E.g. Talk to a friend if you need to talk to a friend and don't listen to poetry that you feel 0 need for.

So i created some DFHack-scripts to fix/improve the Need and Stress System.
I did try to come up with not cheating solutions!
Meaning i don't just change the Need-Values (well in most cases)

1) Religion (need-religion.lua)  (Static Script)
Dwarfs can collect way to many religions and pray in order of the index not in order of need.
This leads to endless pray-loops where the dwarf never reaches the last religions and is always unhappy.
To fix this i remove all Religions expect the first 3 (together with the deity links). 
This is the max amount of Religion a dwarf can have at worldgen.
So he still needs to Pray to all his gods but its possible that he does so.

2) EatGoodMeal (need-goodmeal.lua) (Static Script)
We all know the problem with this one. Its way way to specific and you have no chance of finding the right meal for each dwarf.
Even if you do, there is a big chance he will actually never eat it.
To fix this i alter the Preference of each Dwarf and add a Food-Category instead of a specific food-item.
(i did not think it would work either but to my surprise it does!)
Its still quite a challenge, to create food from every Category, to make all happy.
But at least you have a fighting chance now!
If you like an extra Challenge enable the Seed-Category in the Script.

3) Acquire Item (need-acquire.lua) (Semi-Static Script)
There is a workaround to fill this need. You let all your dwarf carry Trinkets between 3 Stockpiles in an endless loop so that they take an item eventually.
I never liked this Goblin like behaviour.
Instead my script assigns every Dwarf in need a Trinket.
You still have to produce this Trinkets and the Dwarf still goes and collects his Trinket but he does it himself!

4) Be with Friends / Be with Family (need-fuf.lua) (Static Script)
I tried... But the Problem is so deep in the System i can not find an easy solution.
Dwarfs just don't socialise enough and with the right persons. Even if you try to force them, its not enough to satisfy this needs.
So here i just set the Need to 0. If you have a better idea let me know!
 
5) Wander (need-wander.lua) (Labor-Script)
Enables/Disables Pick/Gather Labor for anyone who needs to Wander.
SETUP:
	-An active gather Zone with plants/fruits to gather (best underground)	
	-Dwarfs with "Alchemy Labor" are ignored

6) Help Somebody (need-help.lua)  (Labor-Script)
Enables/Disables a Animal Care for anyone who needs to  Help Somebody
SETUP:
	-Gazeing Animals in Cages 
	-Dwarfs with "Alchemy Labor" are ignored

6) Craft Item (need-craft.lua)(Labor-Script)
Enables/Disables a chosen Craft for anyone who needs to Craft Something.
SETUP:
	-Few Workshops for this Craft ( default stonecraft)
	-This Workshops only accept lower skill workers (over manager)
	-This Workshops have repeated Craft Tasks queued
	-Dwarfs with "Alchemy Labor" are ignored
	
	
8) Training (need-training.lua) (Squad-Script)
Assigns/Frees Dwarfs that needs to Train to Training-Squads
SETUP: 
	-Minimum 1 squad with the name "CIVGYM"
	-An assigned squad-leader that is good in teaching
	-All other Places unassigned
	-An assigned Barracks for this squads (best underground)
	-Activate Training orders for this Squads ( Military/Alarms)
	-Dwarfs with "Alchemy Labor" are ignored

9) Need Value (need-value.lua) 
Outputs the average-need-value of your dwarfs.

X) Autostarter ( need-all.lua )
A script that runs the above scripts on timers.
Just use  "need-all -start" and "need-all -stop" if you think they had enough.
You could run it nonstop but i think its best if you use while on break/party to make the dwarfs happy.

Hope someone finds it useful :)

Thanks to:
Everyone who wrote a DFHack script because i think i "borrowed" code from most of them :)
lethosor, who helped me with my many questions about DFHack and so preventing me from giving up.

TLDR:
1. Download scripts
2. put files into DFHACK/script folder
3. type "need-all -help" into the DFHACK-Console 
4. read what you need to Setup and do it ;)
5. type "need-all -start" into the DFHACK-Console
-=> watch the dwarfs get happy over time

