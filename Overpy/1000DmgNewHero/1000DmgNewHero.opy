settings {
    "main": {
        "description": "1000 DMG NEW HERO v11.1.0\r\nChange hero every 1000 damage.\r\nCreated by Jokaes#2263\r\nJoin my discord.io/Jokaes\r\nCode: NX45F",
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

globalvar timeCounter 0
globalvar leaderboardArray 1
globalvar arenaMap1 2
globalvar arenaMap2 3
globalvar arenaMap3 4
globalvar arenaMap4 5


#Player variables

playervar damageDone 0
playervar heroList 1
playervar nextObjective 2
playervar heroIcon 3
playervar damageDisplay 5
playervar damageDisplayPos 6
playervar damageDisplayScale 7


#Subroutine names

subroutine gameModeDescriptionMessages 0


rule "Disable bulit-in game mode & start timer variables {Game in progress GLOBAL}":
    @Condition isGameInProgress() == true
    
    disableScoring()
    disableGamemodeCompletion()
    disableAnnouncer()
    disableMusic()
    disableInspector()
    pauseMatchTime()
    timeCounter = 0.001
    #Creates a HUD in the top with [svr load: {0} | svr avg: {1} | svr peak: {2}]
    hudSubheader([i for i in hostPlayer if "#Jokaes" == l"#{0}".format(hostPlayer)], "svr load: {0} | svr avg: {1} | svr peak: {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.TOP, -100, Color.LIME_GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


rule "Gamemode description, create objective, next hero HUDs {Game in progress PLAYER}":
    @Event eachPlayer
    @Condition isGameInProgress() == true
    
    async(gameModeDescriptionMessages, AsyncBehavior.NOOP)
    wait(4.5)
    setObjectiveDescription(eventPlayer, l"{0} {1} {2}".format(l"Deal", floor(eventPlayer.nextObjective - eventPlayer.damageDone), l"{0} -> {1}".format(l"Damage", heroIcon(eventPlayer.heroList[eventPlayer.nextObjective / 1000]))), HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(eventPlayer, l"{0}: {1}".format(l"Next Hero", l"{0} {1}".format(eventPlayer.nextObjective, eventPlayer.heroList[eventPlayer.nextObjective / 1000])), HudPosition.TOP, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


rule "Damage track":
    @Event playerDealtDamage
    @Condition victim != attacker
    
    eventPlayer.damageDone += eventDamage
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


/*
rule "Leaderboard {Reevaluation}":
    leaderboardArray = sorted(getAllPlayers(), lambda player: player.damageDone)
    wait(1)
    goto RULE_START
*/

/*
rule "Leaderboard {HUD}":
    hudSubtext([player for player in getAllPlayers() if leaderboardArray[0] != null], l"{0} : {1} : {2}".format(heroIcon(leaderboardArray[0].getCurrentHero()), leaderboardArray[0], round(leaderboardArray[0].damageDone)), HudPosition.RIGHT, 11, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if leaderboardArray[1] != null], l"{0} : {1} : {2}".format(heroIcon(leaderboardArray[1].getCurrentHero()), leaderboardArray[1], round(leaderboardArray[1].damageDone)), HudPosition.RIGHT, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if leaderboardArray[2] != null], l"{0} : {1} : {2}".format(heroIcon(leaderboardArray[2].getCurrentHero()), leaderboardArray[2], round(leaderboardArray[2].damageDone)), HudPosition.RIGHT, 9, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if leaderboardArray[3] != null], l"{0} : {1} : {2}".format(heroIcon(leaderboardArray[3].getCurrentHero()), leaderboardArray[3], round(leaderboardArray[3].damageDone)), HudPosition.RIGHT, 8, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if leaderboardArray[4] != null], l"{0} : {1} : {2}".format(heroIcon(leaderboardArray[4].getCurrentHero()), leaderboardArray[4], round(leaderboardArray[4].damageDone)), HudPosition.RIGHT, 7, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if leaderboardArray[5] != null], l"{0} : {1} : {2}".format(heroIcon(leaderboardArray[5].getCurrentHero()), leaderboardArray[5], round(leaderboardArray[5].damageDone)), HudPosition.RIGHT, 6, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if leaderboardArray[6] != null], l"{0} : {1} : {2}".format(heroIcon(leaderboardArray[6].getCurrentHero()), leaderboardArray[6], round(leaderboardArray[6].damageDone)), HudPosition.RIGHT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if leaderboardArray[7] != null], l"{0} : {1} : {2}".format(heroIcon(leaderboardArray[7].getCurrentHero()), leaderboardArray[7], round(leaderboardArray[7].damageDone)), HudPosition.RIGHT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if leaderboardArray[8] != null], l"{0} : {1} : {2}".format(heroIcon(leaderboardArray[8].getCurrentHero()), leaderboardArray[8], round(leaderboardArray[8].damageDone)), HudPosition.RIGHT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if leaderboardArray[9] != null], l"{0} : {1} : {2}".format(heroIcon(leaderboardArray[9].getCurrentHero()), leaderboardArray[9], round(leaderboardArray[9].damageDone)), HudPosition.RIGHT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if leaderboardArray[10] != null], l"{0} : {1} : {2}".format(heroIcon(leaderboardArray[10].getCurrentHero()), leaderboardArray[10], round(leaderboardArray[10].damageDone)), HudPosition.RIGHT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if leaderboardArray[11] != null], l"{0} : {1} : {2}".format(heroIcon(leaderboardArray[11].getCurrentHero()), leaderboardArray[11], round(leaderboardArray[11].damageDone)), HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
*/

rule "Leaderboard 11.1.0":
    @Event eachPlayer
    
    hudSubtext(getAllPlayers(), "{0} : {1} : {2}".format(heroIcon(eventPlayer.getCurrentHero()), eventPlayer, round(eventPlayer.damageDone)), HudPosition.RIGHT, eventPlayer.damageDone * -1 / 1000, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)


rule "Hero List - Infinite 8 DPS + 1 Tank (5th) + 1 Supp (10th)":
    @Event eachPlayer
    
    eventPlayer.heroList = getDamageHeroes()
    eventPlayer.heroList = random.shuffle(eventPlayer.heroList)
    eventPlayer.heroList = eventPlayer.heroList.slice(0, 9)
    eventPlayer.heroList[4] = random.choice(getTankHeroes())
    eventPlayer.heroList.append(random.choice(getSupportHeroes()))


rule "Preload Heroes":
    @Event eachPlayer
    
    eventPlayer.preloadHero(eventPlayer.heroList)


rule "INFINITO ∞":
    @Event eachPlayer
    @Condition getSupportHeroes().index(eventPlayer.getCurrentHero()) != -1
    @Condition eventPlayer.hasSpawned() == true
    
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


rule "Game Mode Description HUD - 1000 DMG = NEXT HERO aka ∞ Infinite Damage Gun Game v11.1.0":
    @Condition isGameInProgress() == true
    
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "1000 DMG = NEXT HERO aka ∞ Infinite Damage Gun Game v11.1.0", HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "Change {0} every {1}".format(l"Hero", l"{0} {1}".format(1000, l"Damage")), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "8 random DPS + 1 Tank (5th) + 1 Support (10th) in loop", HudPosition.LEFT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, 2.5, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "Created by Jokaes#2263", HudPosition.LEFT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "Updated code & more in jokaes.github.io", HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    async(gameModeDescriptionMessages, AsyncBehavior.NOOP)


rule "Game Mode Description for players who join - 1000 DMG = NEXT HERO aka ∞ Infinite Damage Gun Game v11.1.0":
    @Event playerJoined
    @Condition isGameInProgress() == true
    
    async(gameModeDescriptionMessages, AsyncBehavior.NOOP)


def gameModeDescriptionMessages():
    @Name "Game Mode Description messages - 1000 DMG = NEXT HERO aka ∞ Infinite Damage Gun Game v11.1.0"
    
    wait(3.5)
    smallMessage(eventPlayer, "1000 DMG = NEXT HERO aka ∞ Infinite Damage Gun Game v11.1.0")
    wait(3.5)
    smallMessage(eventPlayer, "Change {0} every {1}".format(l"Hero", l"{0} {1}".format(1000, l"Damage")))
    wait(3.5)
    smallMessage(eventPlayer, "8 random DPS + 1 Tank (5th) + 1 Support (10th) in loop")
    wait(3.5)
    smallMessage(eventPlayer, "Created by Jokaes#2263")


/*
rule "Score Debug (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    
    eventPlayer.damageDone += 100
    eventPlayer.setScore(eventPlayer.damageDone)
    eventPlayer.nextObjective = (floor(eventPlayer.damageDone / 1000) + 1) * 1000
    eventPlayer.startForcingHero(eventPlayer.heroList[eventPlayer.nextObjective / 1000 - 1])
    wait(0.25)
*/

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
    @Event eachPlayer
    @Condition isInSetup() == true
    
    createDummy(eventPlayer.heroList[0], Team.ALL, -1, vect(0, 0, 0), vect(0, 0, 0))
    if len(getAllPlayers()) < 12:
        goto RULE_START
*/

rule "Created by Jokaes#2263":


