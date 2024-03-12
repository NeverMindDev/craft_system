Usage:

in the config.kraft follow the example:

	{
    	jobid = 0,
        job = "",
        label = "",
        needitem = "",
        additem = "",
	addmoney = 0,
        price = 0,
        maxcraft = 0,
        maxstack = 0,
        krafttime = 0,
        coord = vec3(0, 0, 0),
        colorr = 255,
        colorg = 255,
        colorb = 255
    	},

	{
    	jobid = 1,
        job = "",
        label = "",
        needitem = "",
        additem = "",
	addmoney = 0,
        price = 0,
        maxcraft = 0,
        maxstack = 0,
        krafttime = 0,
        coord = vec3(0, 0, 0),
        colorr = 255,
        colorg = 255,
        colorb = 255
    	},


where

jobid		== always need to be a number, its the id for everything, always add + 1 for the previously;;	
job		== the job name who can craft there;;	
label		== the item label;;	
needitem 	== the item that would be needed when you crafting;;	
additem		== the item you will "get" after the craft, what people can buy from the npc;;	
addmoney	== the amount of money that will be given for the player at each crafts;;	
price		== price for each of that item;;	
maxcraft	== the maximum amount that you can craft in one time;;	
maxstack	== the maximum amount that can go in the storage;;	
krafttime	== the time you will need to craft one item 1 = 1 second , 2 = 2 second, and so on (no need to write 1000 or 2000!!);;	
coord		== where you can craft the items -- x, y, z;;	
colorr		== marker color red  0-255;;	
colorg		== marker color green 0-255;;	
colorb		== marker color blue  0-255;;	


in the config.npc

	["job"] = {coord = vec3(0, 0, 0),h = 0,model = '', gender = '', maxbuy = 0},
where

in the first bracket you will need to write the job name, it's connected to the krafts -- so if you write in the config.krafts job="admin" then you gona need to write ["admin"]
coord		== the npc koordinates -- x, y, z;;	
h		== heading for the npc;;	
model		== model for the npc -- see more: https://docs.fivem.net/docs/game-references/ped-models/  ;;	
gender		== depends for the model can be 'male'  or  'female';;	
maxbuy		== the maximum amount, player can be buy one at a time;;	

Explanation:
	There are 2 key in this whole thing:
First: jobid , it cannot be the same, otherwise its not going to work -- it's a simple key, so you can add multiple items for one job

Second: in the Config.Krafts the job in the Config.npc the bracket ["job"] -- it's a key for that you can only buy the items that are in the right jobs
