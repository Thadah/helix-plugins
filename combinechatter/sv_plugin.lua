local PLUGIN = PLUGIN

PLUGIN.Conversations = {}

util.AddNetworkString("ixChatterConversationLength")
util.AddNetworkString("ixChatterPlayConversation")

function PLUGIN:Tick()
	for k, v in pairs(player.GetAll()) do
		if (v:IsCombine()) then
			if (v:Alive() and ix.config.Get("combineChatterEnabled", true)) then
				if (CurTime() > (v.nextChatter or 0)) then
					v.nextChatter = math.random(ix.config.Get("combineChatterMinTime", 20), ix.config.Get("combineChatterMaxTime", 30))
					PLUGIN:PlayConversation(v)
				end
			end
		end
	end
end

net.Receive("ixChatterConversationLength", function(len, client)
	local length = net.ReadFloat()
	timer.Simple(length, function()
		if not IsValid(client) then return end
		client.conversationPlaying = false
	end)
	client.nextChatter = CurTime() + length + math.random(15, 30)
end)

function PLUGIN:AddConversation(...)
	local files = {...}

	for k, v in pairs(files) do
		if (type(v) != "string") then
			ErrorNoHalt("[CombineChatter] Invalid argument to 'AddConversation'!\n")
			return
		end
	end

	for i = #files, 1, -1 do
		local previous = files[i + 1]
		local next = files[i - 1]
		if (!previous) then continue end

		if (files[i]:find("metropolice") and previous:find("radiovoice")) then
			table.insert(files, i + 1, "dispatchon")
			table.insert(files, i + 1, "offsound")
		elseif (files[i]:find("radiovoice") and previous:find("metropolice")) then
			table.insert(files, i + 1, "onsound")
			table.insert(files, i + 1, "dispatchoff")
		end
	end

	if (files[#files]:find("radiovoice")) then
		table.insert(files, "dispatchoff")
	elseif (files[#files]:find("metropolice")) then
		table.insert(files, "offsound")
	end

	if files[1]:find("metropolice") then
		table.insert(files, 1, "onsound")
	elseif files[1]:find("radiovoice") then
		table.insert(files, 1, "dispatchon")
	end

	table.insert(self.Conversations, files)
end

function PLUGIN:PlayConversation(client)
	if (client.conversationPlaying) then return end
	local rnum = math.random(1, #self.Conversations)

	while (rnum == client.lastConvo) do
		rnum = math.random(1, #self.Conversations)
	end

	local random = self.Conversations[rnum]

	net.Start("ixChatterConversationLength")
		net.WriteTable(random)
	net.Send(client)
	net.Start("ixChatterPlayConversation")
		net.WriteTable({client, random})
	net.Send(client)
	client.conversationPlaying = true
	client.lastConvo = rnum
end

PLUGIN:AddConversation("npc/metropolice/vo/anyonepickup647e.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/reporton.wav", "npc/overwatch/radiovoice/patrol.wav", "npc/metropolice/vo/clearandcode100.wav")
PLUGIN:AddConversation("npc/metropolice/vo/stillgetting647e.wav", "npc/overwatch/radiovoice/investigate.wav", "npc/metropolice/vo/rodgerthat.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/reporton.wav", "npc/overwatch/radiovoice/upi.wav", "npc/metropolice/vo/novisualonupi.wav")
PLUGIN:AddConversation("npc/metropolice/vo/standardloyaltycheck.wav")
PLUGIN:AddConversation("npc/metropolice/vo/pickingupnoncorplexindy.wav")
PLUGIN:AddConversation("npc/metropolice/vo/loyaltycheckfailure.wav", "npc/overwatch/radiovoice/administer.wav", "npc/overwatch/radiovoice/terminalprosecution.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/remindermemoryreplacement.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/reminder100credits.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/recalibratesocioscan.wav", "npc/metropolice/vo/copy.wav")
PLUGIN:AddConversation("npc/metropolice/vo/unitis10-65.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/confirmupialert.wav", "npc/metropolice/vo/ten2.wav")
PLUGIN:AddConversation("npc/metropolice/vo/wearesociostablethislocation.wav")
PLUGIN:AddConversation("npc/metropolice/vo/unitisonduty10-8.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/teamsreportstatus.wav", "npc/metropolice/vo/control100percent.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/airwatchcopiesnoactivity.wav", "npc/overwatch/radiovoice/workforceintake.wav", "npc/overwatch/radiovoice/zero.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/disturbingunity415.wav", "npc/overwatch/radiovoice/inprogress.wav", "npc/overwatch/radiovoice/respond.wav", "npc/metropolice/vo/rodgerthat.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/airwatchreportspossiblemiscount.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/teamsreportstatus.wav", "npc/metropolice/vo/blockisholdingcohesive.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/engagingteamisnoncohesive.wav", "npc/overwatch/radiovoice/reinforcementteamscode3.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/leadersreportratios.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/politistablizationmarginal.wav", "npc/metropolice/vo/ten4.wav", "npc/metropolice/vo/unitis10-65.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/attention.wav", "npc/overwatch/radiovoice/sociocide.wav", "npc/overwatch/radiovoice/inprogress.wav", "npc/overwatch/radiovoice/residentialblock.wav", "npc/overwatch/radiovoice/seven.wav", "npc/overwatch/radiovoice/respond.wav")
PLUGIN:AddConversation("npc/overwatch/radiovoice/threattoproperty51b.wav", "npc/overwatch/radiovoice/inprogress.wav", "npc/overwatch/radiovoice/terminalrestrictionzone.wav", "npc/overwatch/radiovoice/four.wav", "npc/overwatch/radiovoice/allteamsrespondcode3.wav")
PLUGIN:AddConversation("npc/metropolice/vo/cpweneedtoestablishaperimeterat.wav", "npc/metropolice/vo/wasteriver.wav", "npc/metropolice/vo/six.wav", "npc/overwatch/radiovoice/apply.wav")
PLUGIN:AddConversation("npc/metropolice/vo/malcompliant10107my1020.wav")
PLUGIN:AddConversation("npc/metropolice/vo/ptatlocationreport.wav", "offsound", "onsound", "npc/metropolice/vo/searchingforsuspect.wav")
PLUGIN:AddConversation("npc/metropolice/vo/ten97suspectisgoa.wav", "npc/overwatch/radiovoice/cauterize.wav", "npc/overwatch/radiovoice/allunitsapplyforwardpressure.wav")
PLUGIN:AddConversation("npc/metropolice/vo/matchonapblikeness.wav", "npc/overwatch/radiovoice/allteamsrespondcode3.wav")