settings {
    "main": {
        "description": "1000 DMG NEW HERO v13.0.0\r\nChange hero every 1000 damage.\r\nCreated by Jokaes#2263\r\nJoin my discord.io/Jokaes\r\nCode: NX45F",
        "modeName": "1000 DMG NEW HERO"
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
        "ffa": {
            "enabledMaps": [
                "havana",
                "workshopChamber",
                "workshopExpanse",
                "workshopIsland"
            ]
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "enableKillFeed": false,
            "enableRandomHeroes": true,
            "respawnTime%": 0
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

globalvar timeCounter
globalvar leaderboardArray
globalvar arenaMap1
globalvar arenaMap2
globalvar arenaMap3
globalvar arenaMap4
globalvar heroListType
globalvar victoryCondition
globalvar workshopSettingsStr


#Player variables

playervar damageDone
playervar heroList
playervar nextObjective
playervar heroIcon
playervar damageDisplay
playervar damageDisplayPos
playervar damageDisplayScale
playervar heroListInfinitoAppend
playervar subHeaderNextHeroStr
playervar showDescription


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
    workshopSettingsStr = ""
    if(victoryCondition[0]):
        workshopSettingsStr = "{0}{1}\n".format(workshopSettingsStr, "Victory @ {0}".format(victoryCondition[1]))
    switch (heroListType):
        default:
        case 0:
            workshopSettingsStr = "{0}{1}\n".format(workshopSettingsStr, "80% DPS, 10% SUPPORT, 10% TANKS")
            break
        case 1:
            workshopSettingsStr = "{0}{1}\n".format(workshopSettingsStr, "50% DPS, 25% SUPPORT, 25% TANKS")
            break
        case 2:
            workshopSettingsStr = "{0}{1}\n".format(workshopSettingsStr, "100% DPS")
            break
        case 3:
            workshopSettingsStr = "{0}{1}\n".format(workshopSettingsStr, "ALL HEROES")
            break

rule "Workshop Settings":
    heroListType = createWorkshopSetting(enum["80% DPS, 10% SUPPORT, 10% TANKS", "50% DPS, 25% SUPPORT, 25% TANKS", "100% DPS", "ALL HEROES"], "Settings", "Hero List [80% DPS, 10% SUPPORT, 10% TANKS]", 0, 0)
    victoryCondition = [null, null]
    victoryCondition[0] = createWorkshopSetting(bool, "Settings", "Victory condition [OFF]", false, 0)
    victoryCondition[1] = createWorkshopSetting(int[5000:20000], "Settings", "Victory necessary points [10000]", 10000, 0)

rule "Gamemode description, create objective, next hero HUDs {Game in progress PLAYER}":
    @Event eachPlayer
    @Condition isGameInProgress() == true
    
    async(gameModeDescriptionMessages, AsyncBehavior.NOOP)
    wait(4.5)
    setObjectiveDescription(eventPlayer, l"{0} {1} {2}".format(l"Deal", floor(eventPlayer.nextObjective - eventPlayer.damageDone), l"{0} -> {1}".format(l"Damage", heroIcon(eventPlayer.heroList[eventPlayer.nextObjective / 1000]))), HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.subHeaderNextHeroStr = l"{0}: {1}".format(l"Next Hero", l"{0} {1}".format(eventPlayer.nextObjective, eventPlayer.heroList[eventPlayer.nextObjective / 1000]))
    hudSubheader(eventPlayer, eventPlayer.subHeaderNextHeroStr, HudPosition.TOP, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


rule "Damage track":
    @Event playerDealtDamage
    @Condition victim != attacker
    
    eventPlayer.damageDone += eventDamage
    if(victoryCondition[0] == false and eventPlayer.damageDone < victoryCondition[1]):
        eventPlayer.subHeaderNextHeroStr = l"{0}: {1}".format(l"Next Hero", l"{0} {1}".format(eventPlayer.nextObjective, eventPlayer.heroList[eventPlayer.nextObjective / 1000]))
    #if eventPlayer.getScore() >= 9999:
    #        goto lbl_0
    #Updates the score only if is necesary
    if eventPlayer.getScore() < 9999:
        lbl_0:
        eventPlayer.setScore(eventPlayer.damageDone)
    eventPlayer.nextObjective = (floor(eventPlayer.damageDone / 1000) + 1) * 1000
    destroyInWorldText(eventPlayer.damageDisplay)
    eventPlayer.damageDisplayPos = victim.getEyePosition()
    eventPlayer.damageDisplayScale = 0.7 + eventDamage / 20
    #Creates a WHITE damage display if event wasn't critical else creates a RED one
    if not eventWasCriticalHit:
        #if eventWasCriticalHit:
        #            goto lbl_1
        createInWorldText(eventPlayer, round(eventDamage), eventPlayer.damageDisplayPos, eventPlayer.damageDisplayScale, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
        lbl_1:
    else:
        #if not eventWasCriticalHit:
        #            goto lbl_2
        createInWorldText(eventPlayer, round(eventDamage), eventPlayer.damageDisplayPos, eventPlayer.damageDisplayScale, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED, SpecVisibility.DEFAULT)
        lbl_2:
    eventPlayer.damageDisplay = getLastCreatedText()

rule "Leaderboard 12.0.0":
    @Event eachPlayer
    
    hudSubtext(getAllPlayers(), "{0} : {1} : {2}".format(heroIcon(eventPlayer.getCurrentHero()), eventPlayer, round(eventPlayer.damageDone)), HudPosition.RIGHT, eventPlayer.damageDone * -1 / 1000, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)

rule "Pre-Victory":
    @Event eachPlayer
    @Condition victoryCondition[0] == true
    @Condition eventPlayer.nextObjective >= victoryCondition[1]

    setObjectiveDescription(eventPlayer, l"{0} {1} {2}".format(l"Deal", floor(eventPlayer.nextObjective - eventPlayer.damageDone), l"{0} -> {1}".format(l"Damage", "WIN")), HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.subHeaderNextHeroStr = l"{0}: {1}".format(l"Victory", l"{0} {1}".format(eventPlayer.nextObjective, ""))

rule "Victory":
    @Event eachPlayer
    @Condition victoryCondition[0] == true
    @Condition eventPlayer.damageDone >= victoryCondition[1]

    declarePlayerVictory(eventPlayer)

rule "80% DPS, 10% SUPPORT, 10% TANKS":
    @Event eachPlayer
    @Condition heroListType == 0
    
    eventPlayer.heroList = []
    eventPlayer.heroList.append(random.shuffle(getDamageHeroes()))
    eventPlayer.heroList = eventPlayer.heroList.slice(0, 16)
    eventPlayer.heroList.append(random.shuffle(getTankHeroes()))
    eventPlayer.heroList = eventPlayer.heroList.slice(0, 18)
    eventPlayer.heroList.append(random.shuffle(getSupportHeroes()))
    eventPlayer.heroList = eventPlayer.heroList.slice(0, 20)
    eventPlayer.heroList = random.shuffle(eventPlayer.heroList)
    
rule "50% DPS, 25% SUPPORT, 25% TANKS":
    @Event eachPlayer
    @Condition heroListType == 1
    
    eventPlayer.heroList = []
    eventPlayer.heroList.append(random.shuffle(getDamageHeroes()))
    eventPlayer.heroList = eventPlayer.heroList.slice(0, 14)
    eventPlayer.heroList.append(random.shuffle(getTankHeroes()))
    eventPlayer.heroList = eventPlayer.heroList.slice(0, 21)
    eventPlayer.heroList.append(random.shuffle(getSupportHeroes()))
    eventPlayer.heroList = eventPlayer.heroList.slice(0, 28)
    eventPlayer.heroList = random.shuffle(eventPlayer.heroList)

rule "100% DPS":
    @Event eachPlayer
    @Condition heroListType == 2
    
    eventPlayer.heroList = []
    eventPlayer.heroList.append(random.shuffle(getDamageHeroes()))
    eventPlayer.heroList = random.shuffle(eventPlayer.heroList)

rule "ALL HEROES":
    @Event eachPlayer
    @Condition heroListType == 3
    
    eventPlayer.heroList = []
    eventPlayer.heroList.append(random.shuffle(getAllHeroes()))
    eventPlayer.heroList = random.shuffle(eventPlayer.heroList)

rule "Preload Heroes":
    @Event eachPlayer
    
    eventPlayer.preloadHero(eventPlayer.heroList)

rule "INFINITO ∞":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.nextObjective % (len(eventPlayer.heroList)*1000) == 0
    @Condition len(eventPlayer.heroList) != 0
    @Condition isGameInProgress()
    
    switch (heroListType):
        default:
        case 0:
            eventPlayer.heroListInfinitoAppend = []
            eventPlayer.heroListInfinitoAppend.append(random.shuffle(getDamageHeroes()))
            eventPlayer.heroListInfinitoAppend = eventPlayer.heroListInfinitoAppend.slice(0, 16)
            eventPlayer.heroListInfinitoAppend.append(random.shuffle(getTankHeroes()))
            eventPlayer.heroListInfinitoAppend = eventPlayer.heroListInfinitoAppend.slice(0, 18)
            eventPlayer.heroListInfinitoAppend.append(random.shuffle(getSupportHeroes()))
            eventPlayer.heroListInfinitoAppend = eventPlayer.heroListInfinitoAppend.slice(0, 20)
            eventPlayer.heroListInfinitoAppend = random.shuffle(eventPlayer.heroListInfinitoAppend)
            eventPlayer.heroList.append(eventPlayer.heroListInfinitoAppend)
            break
        case 1:
            eventPlayer.heroListInfinitoAppend = []
            eventPlayer.heroListInfinitoAppend.append(random.shuffle(getDamageHeroes()))
            eventPlayer.heroListInfinitoAppend = eventPlayer.heroListInfinitoAppend.slice(0, 14)
            eventPlayer.heroListInfinitoAppend.append(random.shuffle(getTankHeroes()))
            eventPlayer.heroListInfinitoAppend = eventPlayer.heroListInfinitoAppend.slice(0, 21)
            eventPlayer.heroListInfinitoAppend.append(random.shuffle(getSupportHeroes()))
            eventPlayer.heroListInfinitoAppend = eventPlayer.heroListInfinitoAppend.slice(0, 28)
            eventPlayer.heroListInfinitoAppend = random.shuffle(eventPlayer.heroListInfinitoAppend)
            eventPlayer.heroList.append(eventPlayer.heroListInfinitoAppend)
            break
        case 2:
            eventPlayer.heroListInfinitoAppend.append(random.shuffle(getDamageHeroes()))
            eventPlayer.heroListInfinitoAppend = random.shuffle(eventPlayer.heroListInfinitoAppend)
            eventPlayer.heroList.append(eventPlayer.heroListInfinitoAppend)
            break
        case 3:
            eventPlayer.heroListInfinitoAppend.append(random.shuffle(getAllHeroes()))
            eventPlayer.heroListInfinitoAppend = random.shuffle(eventPlayer.heroListInfinitoAppend)
            eventPlayer.heroList.append(eventPlayer.heroListInfinitoAppend)
            break

rule "In Setup OR In Game in progress -> Starting Hero -> HeroList[0]":
    @Event eachPlayer
    @Condition (isInSetup() or isGameInProgress()) == true
    
    eventPlayer.startForcingHero(eventPlayer.heroList[0])
    eventPlayer.nextObjective = 1000


rule "Start forcing next hero":
    @Event eachPlayer
    @Condition eventPlayer.getCurrentHero() != eventPlayer.heroList[eventPlayer.nextObjective / 1000 - 1]
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.damageDone > 0
    
    eventPlayer.nextObjective = (floor(eventPlayer.damageDone / 1000) + 1) * 1000
    eventPlayer.startForcingHero(eventPlayer.heroList[eventPlayer.nextObjective / 1000 - 1])
    smallMessage(eventPlayer, l"{0}: {1}".format(l"{0} {1}".format(l"You", l"Hero"), heroIcon(eventPlayer.heroList[eventPlayer.nextObjective / 1000 - 1])))
    createInWorldText(getAllPlayers(), heroIcon(eventPlayer.heroList[eventPlayer.nextObjective / 1000 - 1]), eventPlayer, 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    eventPlayer.heroIcon = getLastCreatedText()
    wait(1.375)
    destroyInWorldText(eventPlayer.heroIcon)


rule "Time Counter - Add minute":
    @Condition isGameInProgress() == true
    
    setMatchTime(timeCounter)
    wait(60)
    timeCounter += 1
    goto RULE_START


rule "Global init -Created by Beemoo":
    @Condition getCurrentMap() == Map.HAVANA
    
    arenaMap1 = false
    arenaMap2 = vect(215, 35, -40)
    arenaMap3 = []
    arenaMap3.append(vect(227.5, 27.5, -57))
    arenaMap3.append(vect(227.5, 27.5, -40.5))
    arenaMap3.append(vect(227.5, 27.5, -25.5))
    arenaMap3.append(vect(218, 27.5, -16.5))
    arenaMap3.append(vect(204.83, 27.5, -16.5))
    arenaMap3.append(vect(191.17, 27.5, -20.78))
    arenaMap3.append(vect(181.6, 27.5, -30.1))
    arenaMap3.append(vect(171.19, 28.21, -42))
    arenaMap3.append(vect(171.19, 28.21, -55))
    arenaMap3.append(vect(185, 27.5, -64.6))
    arenaMap3.append(vect(197.6, 27.5, -64.59))
    arenaMap3.append(vect(210.2, 27.5, -64.59))
    arenaMap3.append(vect(222.6, 27.5, -64.59))
    arenaMap4 = len(arenaMap3) - 1
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, vect(184, -71.8, -46), 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    if not arenaMap1:
        goto lbl_0
    createEffect(getAllPlayers(), Effect.ORB, Color.PURPLE, arenaMap2, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    lbl_0:


rule "Effect create loop -Created by Beemoo":
    @Condition arenaMap1 == true
    @Condition arenaMap4 > 0
    @Condition getCurrentMap() == Map.HAVANA
    
    wait(0.25)
    createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, arenaMap3[arenaMap4], 1.2, EffectReeval.VISIBILITY)
    arenaMap4 -= 1
    if RULE_CONDITION:
        goto RULE_START


rule "No entry pillars (knock, tele) -Created by Beemoo":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 1.25 for player in arenaMap3]) == true
    @Condition getCurrentMap() == Map.HAVANA
    
    wait(0.5)
    if not RULE_CONDITION:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), arenaMap2[0] + vect(0, 10, 0)), 12, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.setStatusEffect(null, Status.STUNNED, 1)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
    smallMessage(eventPlayer, l"{0} {1}".format(l"No", l"{0}!".format(l"Hiding")))
    wait(0.75)
    if not RULE_CONDITION:
        return
    eventPlayer.teleport(arenaMap2[0] + vect(random.randint(-8, 8), 0, random.randint(-19, 19)))


rule "No entry floor (OOB) -Created by Beemoo":
    @Event eachPlayer
    @Condition (eventPlayer.getPosition().y < 26.5 and eventPlayer.getPosition().y > 25) == true
    @Condition getCurrentMap() == Map.HAVANA
    
    eventPlayer.setStatusEffect(null, Status.BURNING, 0.5)
    damage(eventPlayer, eventPlayer, 25)
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), arenaMap2[0] + vect(0, 10, 0)), 12, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.5)
    if RULE_CONDITION:
        goto RULE_START


rule "No entry OOB (spawn tele) -Created by Beemoo":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned() == true
    @Condition getCurrentMap() == Map.HAVANA
    @Condition (eventPlayer.getPosition().x < 171 or eventPlayer.getPosition().x > 229 or eventPlayer.getPosition().z < -66 or eventPlayer.getPosition().z > -15) == true
    
    eventPlayer.teleport(arenaMap2 + vect(random.randint(-8, 8), 0, random.randint(-19, 19)))

rule "Toggle showDescription":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    wait(0.3, Wait.ABORT_WHEN_FALSE)
    if(eventPlayer.showDescription == true):
        eventPlayer.showDescription = false
    else:
        eventPlayer.showDescription = true

rule "Game Mode Description HUD - 1000 DMG NEW HERO v13.0.0":
    @Condition isGameInProgress() == true
    
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "1000 DMG NEW HERO v13.0.0", HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "Change {0} every {1}".format(l"Hero", l"{0} {1}".format(1000, l"Damage")), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, 2.5, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "Created by Jokaes#2263", HudPosition.LEFT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "Join my discord.io/Jokaes", HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if player.showDescription == false], "Hold {0} to show the workshop settings".format(buttonString(Button.INTERACT)), HudPosition.LEFT, 6, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if player.showDescription == true], workshopSettingsStr, HudPosition.LEFT, 6, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    async(gameModeDescriptionMessages, AsyncBehavior.NOOP)


rule "Game Mode Description for players who join - 1000 DMG NEW HERO v13.0.0":
    @Event playerJoined
    @Condition isGameInProgress() == true
    
    async(gameModeDescriptionMessages, AsyncBehavior.NOOP)


def gameModeDescriptionMessages():
    @Name "Game Mode Description messages - 1000 DMG NEW HERO v13.0.0"
    
    wait(3.5)
    smallMessage(eventPlayer, "1000 DMG NEW HERO v13.0.0")
    wait(3.5)
    smallMessage(eventPlayer, "Change {0} every {1}".format(l"Hero", l"{0} {1}".format(1000, l"Damage")))
    wait(3.5)
    smallMessage(eventPlayer, "Created by Jokaes#2263")



rule "Score Debug (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    
    eventPlayer.damageDone += 100
    eventPlayer.setScore(eventPlayer.damageDone)
    eventPlayer.nextObjective = (floor(eventPlayer.damageDone / 1000) + 1) * 1000
    eventPlayer.startForcingHero(eventPlayer.heroList[eventPlayer.nextObjective / 1000 - 1])
    wait(0.25)



rule "Dummy Summon (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isCommunicating(Comms.HELLO) == true
    
    createDummy(eventPlayer.heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(eventPlayer.heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(eventPlayer.heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(eventPlayer.heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(eventPlayer.heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(eventPlayer.heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))



rule "Dummy Aim Bot (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true
    
    eventPlayer.startFacing(directionTowards(eventPlayer, getClosestPlayer(eventPlayer, getOppositeTeam(eventPlayer.getTeam()))), 10000, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
    eventPlayer.heroList.remove(Hero.HANZO)
    eventPlayer.heroList.remove(Hero.ASHE)


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
    @Event eachPlayer
    @Condition isInSetup() == true
    
    createDummy(eventPlayer.heroList[0], Team.ALL, -1, vect(0, 0, 0), vect(0, 0, 0))
    if len(getAllPlayers()) < 12:
        goto RULE_START
*/

rule "Created by Jokaes#2263":


