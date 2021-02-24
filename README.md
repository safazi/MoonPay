# MoonPay
This project has been archived.
I don't play minecraft anymore.

## Main Idea
MoonPay is a mock banking system written in Moonscript.
The goal is to provide a wireless money solution for ComputerCraft/OpenComputers

Each transaction should be recorded in a ledger, but eventually removed due to the space limitations of Minecraft computer mods.

## Database
The database will be a flatfile running a single queue for fetching and updating values.
This will be done with Promise.moon

## Serialization
For the flatfile, I will use JSON unless I figure out something more space efficient to use.
