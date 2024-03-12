Config.Krafts = {  
    {
        jobid = 1,
        job = "craft0",
        label = "Meth",
        needitem = "meth",
        additem = "meth",
        addmoney = 123,
        price = 2000,
        maxcraft = 10,
        maxstack = 300,
        krafttime = 1,
        coord = vec3(233.77877807617, -900.97540283203, 30.692018508911),
        colorr = 255,
        colorg = 255,
        colorb = 0
    },
    {
        jobid = 2,
        job = "craft0",
        label = "Armor",
        needitem = "iron",
        additem = "armour",
        addmoney = 222,
        price = 1000,
        maxcraft = 20,
        maxstack = 300,
        krafttime = 2,
        coord = vec3(232.48948669434, -902.11505126953, 30.692024230957),
        colorr = 0,
        colorg = 255,
        colorb = 0
    },
    --[[{
        jobid = 2,
        job = "craft1",
        label = "Cursed Armor",
        needitem = "water",
        additem = "armour",
        addmoney = 222,
        price = 3000,
        maxcraft = 20,
        maxstack = 300,
        krafttime = 2,
        coord = vec3(232.48948669434, -902.11505126953, 30.692024230957),
        colorr = 0,
        colorg = 255,
        colorb = 0
    },]]
}

Config.NPC = {   
    ["craft0"] = {
        coord = vec3(231.72987365723, -903.94323730469, 30.692016601562),
        h = 53.85,
        model = 's_m_m_highsec_01',
        gender = 'male',
        maxbuy = 10
    },
    --["craft1"] = {coord = vec3(225.94323730469, -912.34252929688, 30.692016601562),h = 53.85,model = `s_m_m_highsec_01`, gender = 'male', maxbuy = 20},
}