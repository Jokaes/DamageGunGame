settings {
    "main": {
        "description": "1000 DMG/HEAL = NEW HERO TEAMS v12.1.0\r\nChange hero every 1000 damage/heal.\r\nCreated by Jokaes#2263\r\nJoin discord.io/Jokaes\r\nCode: 14WGT",
        "modeName": "1000 DMG HEAL TEAMS"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "mapRotation": "afterGame",
        "enableMatchVoiceChat": true,
        "spectatorSlots": 6,
        "returnToLobby": "never",
        "useExperimentalUpdate": true
    },
    "gamemodes": {
        "tdm": {
            "enabledMaps": [
                "workshopChamber"
            ]
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "enableKillFeed": false,
            "enableRandomHeroes": true,
            "respawnTime%": 0,
            "scoreToWin": 200
        }
    },
    "heroes": {
        "allTeams": {
            "ashe": {
                "enableUlt": false
            },
            "symmetra": {
                "enableAbility1": false
            },
            "torbjorn": {
                "enableAbility1": false
            },
            "general": {
                "ultGen%": 200
            }
        }
    }
}

#Global variables

globalvar timeCounter 0
globalvar classicHeroList 1
globalvar teamsHeroList 2
globalvar damageHealDoneTeam1 6
globalvar damageHealDoneTeam2 7


#Player variables

playervar damageHealDone 0
playervar heroList 1
playervar nextObjective 2
playervar heroIcon 3
playervar damageHealDisplay 5
playervar damageHealDisplayPos 6
playervar damagehealDisplayScale 7
playervar heroesDone 8
playervar heroListInfinitoAppend 9


#Subroutine names

subroutine gameModeDescriptionMessages 0


rule "Disable bulit-in game mode & start timer variables {Game in progress GLOBAL}":
    @Condition isGameInProgress() == true
    
    disableScoring()
    disableGamemodeCompletion()
    disableAnnouncer()
    disableMusic()
    #disableInspector()
    pauseMatchTime()
    timeCounter = 0.001
    #Creates a HUD in the top with [svr load: {0} | svr avg: {1} | svr peak: {2}]
    hudSubheader([i for i in hostPlayer if "#Jokaes" == l"#{0}".format(hostPlayer)], "svr load: {0} | svr avg: {1} | svr peak: {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.TOP, -100, Color.LIME_GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


rule "Gamemode description, create objective, NEW HERO HUDs {Game in progress PLAYER}":
    @Event eachPlayer
    @Condition isGameInProgress() == true
    
    async(gameModeDescriptionMessages, AsyncBehavior.NOOP)
    wait(4.5)
    setObjectiveDescription(eventPlayer, "{0} {1} -> {2}".format(floor(eventPlayer.nextObjective - eventPlayer.damageHealDone), l"{0} / {1}".format(l"Damage", l"Heal"), heroIcon(eventPlayer.heroList[eventPlayer.nextObjective / 1000])), HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(eventPlayer, l"{0}: {1}".format(l"Next Hero", l"{0} {1}".format(eventPlayer.nextObjective, eventPlayer.heroList[eventPlayer.nextObjective / 1000])), HudPosition.TOP, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


rule "Damage track TEAM DEATHMATCH":
    @Event playerDealtDamage
    @Condition victim != attacker
    @Condition getCurrentGamemode() == Gamemode.TDM
    
    eventPlayer.damageHealDone += eventDamage
    eventPlayer.nextObjective = (floor(eventPlayer.damageHealDone / 1000) + 1) * 1000
    destroyInWorldText(eventPlayer.damageHealDisplay)
    eventPlayer.damageHealDisplayPos = victim.getEyePosition()
    eventPlayer.damagehealDisplayScale = 0.7 + eventDamage / 20
    #Creates a WHITE damage display if event wasn't critical else creates a RED one
    if not eventWasCriticalHit:
        createInWorldText(eventPlayer, round(eventDamage), eventPlayer.damageHealDisplayPos, eventPlayer.damagehealDisplayScale, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    else:
        createInWorldText(eventPlayer, round(eventDamage), eventPlayer.damageHealDisplayPos, eventPlayer.damagehealDisplayScale, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED, SpecVisibility.DEFAULT)
    eventPlayer.damageHealDisplay = getLastCreatedText()
    if eventPlayer.getTeam() == Color.TEAM_1:
        damageHealDoneTeam1 += eventDamage
    else:
        damageHealDoneTeam2 += eventDamage


rule "Heal track TEAM DEATHMATCH":
    @Event playerDealtHealing
    @Condition getCurrentGamemode() == Gamemode.TDM
    
    eventPlayer.damageHealDone += eventHealing
    eventPlayer.nextObjective = (floor(eventPlayer.damageHealDone / 1000) + 1) * 1000
    destroyInWorldText(eventPlayer.damageHealDisplay)
    eventPlayer.damageHealDisplayPos = healee.getEyePosition()
    eventPlayer.damagehealDisplayScale = 0.7 + eventDamage / 20
    #Creates a YELLOW heal display
    createInWorldText(eventPlayer, round(eventHealing), eventPlayer.damageHealDisplayPos, eventPlayer.damagehealDisplayScale, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    eventPlayer.damageHealDisplay = getLastCreatedText()
    if eventPlayer.getTeam() == Color.TEAM_1:
        damageHealDoneTeam1 += eventDamage
    else:
        damageHealDoneTeam2 += eventDamage


rule "Leaderboard TEAM DEATHMATCH {Each player}":
    @Event eachPlayer
    @Condition isGameInProgress() == true
    @Condition getCurrentGamemode() == Gamemode.TDM
    
    hudSubtext(getPlayers(eventPlayer.getTeam()), "{0} : {1} : {2}".format(heroIcon(eventPlayer.getCurrentHero()), eventPlayer, round(eventPlayer.damageHealDone)), HudPosition.RIGHT, eventPlayer.damageHealDone * -0.001, Color.BLUE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)
    hudSubtext(getPlayers(getOppositeTeam(eventPlayer.getTeam())), "{0} : {1} : {2}".format(heroIcon(eventPlayer.getCurrentHero()), eventPlayer, round(eventPlayer.damageHealDone)), HudPosition.RIGHT, eventPlayer.damageHealDone * -0.001, Color.RED, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)


rule "Leaderboard TEAM DEATHMATCH {Global}":
    @Condition isGameInProgress() == true
    @Condition getCurrentGamemode() == Gamemode.TDM
    
    hudSubtext(getAllPlayers(), "team of {0}: {1}".format(sorted(getPlayers(Color.TEAM_1), lambda player: player.damageHealDone).last(), round(damageHealDoneTeam1)), HudPosition.RIGHT, -999 + damageHealDoneTeam2 / 1000, Color.PURPLE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "team of {0}: {1}".format(sorted(getPlayers(Color.TEAM_2), lambda player: player.damageHealDone).last(), round(damageHealDoneTeam2)), HudPosition.RIGHT, -999 + damageHealDoneTeam1 / 1000, Color.PURPLE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)


rule "Hero List - Infinite 14 DPS + 7 Tank + 7 Supp {Random order}":
    @Event eachPlayer
    
    eventPlayer.heroList = []
    eventPlayer.heroList.append(random.shuffle(getDamageHeroes()))
    eventPlayer.heroList = eventPlayer.heroList.slice(0, 14)
    eventPlayer.heroList.append(random.shuffle(getTankHeroes()))
    eventPlayer.heroList = eventPlayer.heroList.slice(0, 21)
    eventPlayer.heroList.append(random.shuffle(getSupportHeroes()))
    eventPlayer.heroList = eventPlayer.heroList.slice(0, 28)
    eventPlayer.heroList = random.shuffle(eventPlayer.heroList)
    teamsHeroList = true


/*
rule "Hero List - Infinite 8 DPS + 1 Tank (5th) + 1 Supp (10th)":
    @Event eachPlayer
    
    eventPlayer.heroList = getDamageHeroes()
    eventPlayer.heroList = random.shuffle(eventPlayer.heroList)
    eventPlayer.heroList = eventPlayer.heroList.slice(0, 9)
    eventPlayer.heroList[4] = random.choice(getTankHeroes())
    eventPlayer.heroList.append(random.choice(getSupportHeroes()))
    classicHeroList = true
*/

rule "Preload Heroes":
    @Event eachPlayer
    
    eventPlayer.preloadHero(eventPlayer.heroList)


rule "INFINITO ∞":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.nextObjective % 27000 == 0
    
    if teamsHeroList == true:
        eventPlayer.heroListInfinitoAppend = []
        eventPlayer.heroListInfinitoAppend.append(getDamageHeroes())
        eventPlayer.heroListInfinitoAppend = eventPlayer.heroList.slice(0, 14)
        eventPlayer.heroListInfinitoAppend.append(getTankHeroes())
        eventPlayer.heroListInfinitoAppend = eventPlayer.heroList.slice(0, 21)
        eventPlayer.heroListInfinitoAppend.append(getSupportHeroes())
        eventPlayer.heroListInfinitoAppend = eventPlayer.heroList.slice(0, 28)
        eventPlayer.heroListInfinitoAppend = random.shuffle(eventPlayer.heroList)
        eventPlayer.heroList.append(eventPlayer.heroListInfinitoAppend)
    if classicHeroList == true:
        eventPlayer.heroList.append(random.choice(getDamageHeroes()))
        wait(0.25)
        eventPlayer.heroList.append(random.choice(getDamageHeroes()))
        wait(0.25)
        eventPlayer.heroList.append(random.choice(getDamageHeroes()))
        wait(0.25)
        eventPlayer.heroList.append(random.choice(getDamageHeroes()))
        wait(0.25)
        eventPlayer.heroList.append(random.choice(getTankHeroes()))
        wait(0.25)
        eventPlayer.heroList.append(random.choice(getDamageHeroes()))
        wait(0.25)
        eventPlayer.heroList.append(random.choice(getDamageHeroes()))
        wait(0.25)
        eventPlayer.heroList.append(random.choice(getDamageHeroes()))
        wait(0.25)
        eventPlayer.heroList.append(random.choice(getDamageHeroes()))
        wait(0.25)
        eventPlayer.heroList.append(random.choice(getSupportHeroes()))


rule "In Setup OR In Game in progress -> Starting Hero -> HeroList[0]":
    @Event eachPlayer
    @Condition (isInSetup() or isGameInProgress()) == true
    
    eventPlayer.startForcingHero(eventPlayer.heroList[0])
    eventPlayer.nextObjective = 1000


rule "Start forcing NEW HERO TEAM DEATHMATCH":
    @Event eachPlayer
    @Condition eventPlayer.getCurrentHero() != eventPlayer.heroList[eventPlayer.nextObjective / 1000 - 1]
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.damageHealDone > 0
    @Condition getCurrentGamemode() == Gamemode.TDM
    
    eventPlayer.nextObjective = (floor(eventPlayer.damageHealDone / 1000) + 1) * 1000
    eventPlayer.startForcingHero(eventPlayer.heroList[eventPlayer.nextObjective / 1000 - 1])
    smallMessage(eventPlayer, l"{0}: {1}".format(l"{0} {1}".format(l"You", l"Hero"), heroIcon(eventPlayer.heroList[eventPlayer.nextObjective / 1000 - 1])))
    createInWorldText(getAllPlayers(), heroIcon(eventPlayer.heroList[eventPlayer.nextObjective / 1000 - 1]), eventPlayer, 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    eventPlayer.heroIcon = getLastCreatedText()
    if eventPlayer.getTeam() == Color.TEAM_1:
        addToTeamScore(Color.TEAM_1, 1)
    else:
        addToTeamScore(Color.TEAM_2, 1)
    eventPlayer.heroesDone += 1
    wait(1.375)
    destroyInWorldText(eventPlayer.heroIcon)


rule "Time Counter - Add minute":
    @Condition isGameInProgress() == true
    
    setMatchTime(timeCounter)
    wait(60)
    timeCounter += 1
    goto RULE_START


rule "Player leaves":
    @Event playerLeft
    
    wait(1)
    setTeamScore(Color.TEAM_1, getPlayersInSlot(0, Color.TEAM_1).heroesDone + getPlayersInSlot(1, Color.TEAM_1).heroesDone + getPlayersInSlot(2, Color.TEAM_1).heroesDone + getPlayersInSlot(3, Color.TEAM_1).heroesDone + getPlayersInSlot(4, Color.TEAM_1).heroesDone + getPlayersInSlot(5, Color.TEAM_1).heroesDone)
    setTeamScore(Color.TEAM_2, getPlayersInSlot(0, Color.TEAM_2).heroesDone + getPlayersInSlot(1, Color.TEAM_2).heroesDone + getPlayersInSlot(2, Color.TEAM_2).heroesDone + getPlayersInSlot(3, Color.TEAM_2).heroesDone + getPlayersInSlot(4, Color.TEAM_2).heroesDone + getPlayersInSlot(5, Color.TEAM_2).heroesDone)
    damageHealDoneTeam1 = getPlayersInSlot(0, Color.TEAM_1).damageHealDone + getPlayersInSlot(1, Color.TEAM_1).damageHealDone + getPlayersInSlot(2, Color.TEAM_1).damageHealDone + getPlayersInSlot(3, Color.TEAM_1).damageHealDone + getPlayersInSlot(4, Color.TEAM_1).damageHealDone + getPlayersInSlot(5, Color.TEAM_1).damageHealDone
    damageHealDoneTeam2 = getPlayersInSlot(0, Color.TEAM_2).damageHealDone + getPlayersInSlot(1, Color.TEAM_2).damageHealDone + getPlayersInSlot(2, Color.TEAM_2).damageHealDone + getPlayersInSlot(3, Color.TEAM_2).damageHealDone + getPlayersInSlot(4, Color.TEAM_2).damageHealDone + getPlayersInSlot(5, Color.TEAM_2).damageHealDone


rule "Game Mode Description HUD - 1000 DMG/HEAL = NEW HERO TEAMS v12.1.0":
    @Condition isGameInProgress() == true
    
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "1000 DMG/HEAL = NEW HERO TEAMS v12.1.0", HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "Change {0} every {1}".format(l"Hero", l"{0} {1}".format(1000, l"Damage")), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    if teamsHeroList == true:
        hudSubtext(getAllPlayers(), "14 random DPS + 7 Tank + 7 Supp {Random order}", HudPosition.LEFT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    if classicHeroList == true:
        hudSubtext(getAllPlayers(), "8 random DPS + 1 Tank (5th) + 1 Support (10th) in loop", HudPosition.LEFT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, 2.5, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "Created by Jokaes#2263", HudPosition.LEFT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "Updated code & more in jokaes.github.io", HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    async(gameModeDescriptionMessages, AsyncBehavior.NOOP)


rule "Game Mode Description for players who join - 1000 DMG/HEAL = NEW HERO TEAMS v12.1.0":
    @Event playerJoined
    @Condition isGameInProgress() == true
    
    async(gameModeDescriptionMessages, AsyncBehavior.NOOP)


def gameModeDescriptionMessages():
    @Name "Game Mode Description messages - 1000 DMG/HEAL = NEW HERO TEAMS v12.1.0"
    
    wait(3.5)
    smallMessage(eventPlayer, "1000 DMG/HEAL = NEW HERO TEAMS v12.1.0")
    wait(3.5)
    smallMessage(eventPlayer, "Change {0} every {1}".format(l"Hero", l"{0} {1}".format(1000, l"Damage")))
    wait(3.5)
    if teamsHeroList == true:
        smallMessage(eventPlayer, "14 random DPS + 7 Tank + 7 Supp {Random order}")
    if classicHeroList == true:
        smallMessage(eventPlayer, "8 random DPS + 1 Tank (5th) + 1 Support (10th) in loop")
    wait(3.5)
    smallMessage(eventPlayer, "Created by Jokaes#2263")


rule "Score Debug (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    
    eventPlayer.damageHealDone += 100
    eventPlayer.setScore(eventPlayer.damageHealDone)
    eventPlayer.nextObjective = (floor(eventPlayer.damageHealDone / 1000) + 1) * 1000
    eventPlayer.startForcingHero(eventPlayer.heroList[eventPlayer.nextObjective / 1000 - 1])
    wait(0.25)


/*
rule "Dummy Summon (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isCommunicating(Comms.HELLO) == true
    
    createDummy(eventPlayer.heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(eventPlayer.heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(eventPlayer.heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(eventPlayer.heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(eventPlayer.heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(eventPlayer.heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
*/

/*
rule "Dummy Aim Bot (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true
    
    eventPlayer.startFacing(directionTowards(eventPlayer, getClosestPlayer(eventPlayer, getOppositeTeam(eventPlayer.getTeam()))), 10000, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
    eventPlayer.heroList.remove(Hero.HANZO)
    eventPlayer.heroList.remove(Hero.ASHE)
*/

/*
rule "Dummy Ult (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.getUltCharge() == 100
    
    eventPlayer.forceButtonPress(Button.ULTIMATE)
*/

/*
rule "Dummy Walking (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true
    
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer, sorted([player for player in getAllPlayers() if player.isAlive()], lambda i: distance(eventPlayer, i))[1]), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
*/

/*
rule "Lobby with Dummies (TEST)":
    @Condition isInSetup() == true
    
    createDummy(Hero.BRIGITTE, Color.TEAM_1, -1, vect(0, 0, 0), vect(0, 0, 0))
    createDummy(Hero.BRIGITTE, Color.TEAM_2, -1, vect(0, 0, 0), vect(0, 0, 0))
    if getNumberOfPlayers(Color.TEAM_1) < 6 or getNumberOfPlayers(Color.TEAM_2) < 6:
        goto RULE_START
*/

/*
rule "Destroy the bots (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    
    destroyAllDummies()
*/

rule "Created by Jokaes#2263":


