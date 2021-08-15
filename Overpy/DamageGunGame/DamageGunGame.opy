settings {
    "main": {
        "description": "Damage Gun Game. v9.0.0\r\nDeal damage to swap to the next hero, complete the list to win. \r\nTotally customizable in workshop settings!\r\nCreated by Jokaes#2263 -Original FFA by DarwinStreams\r\nJoin my discord.io/Jokaes\r\nCode: SSWAT",
        "modeName": "Damage Gun Game"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "mapRotation": "afterGame",
        "enableMatchVoiceChat": true,
        "spectatorSlots": 12,
        "returnToLobby": "never",
        "useExperimentalUpdate": true
    },
    "gamemodes": {
        "ffa": {
            "enabledMaps": [
                "blackForest",
                "castillo",
                "chateauGuillard",
                "ecopointAntarctica",
                "necropolis",
                "petra"
            ]
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "enableKillFeed": false,
            "enableRandomHeroes": true
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
            }
        }
    }
}

#Global variables

globalvar heroList 0
globalvar timeCounter 1
globalvar gameIsAlmostDone 2
globalvar randomSectionOfMap 4
globalvar arenaMap1 5
globalvar arenaMap2 6
globalvar arenaMap3 7
globalvar arenaMap4 8
globalvar damageNecessaryForNextHero 9
globalvar numberOfDpsHeroes 10
globalvar numberOfTankHeroes 11
globalvar numberOfSupportHeroes 12
globalvar tankHeroesInTheMiddleOfTheList 13
globalvar supportHeroesAtTheEndOfTheList 14
globalvar heroListIt 15
globalvar tempHeroList 16
globalvar tempHeroListSupport 17
globalvar tempHeroListTanks 18
globalvar heroListIt2 19


#Player variables

playervar damageDone 0
playervar damageDisplayPos 1
playervar damageDisplayScale 2
playervar damageDisplayText 3
playervar nextObjective 4
playervar killYourselfPunishment 5
playervar heroIcon 6
playervar heroSwapEffect 7


/*
rule "Damage Gun Game v9.0.0":
*/

rule "Disable bulit-in game mode & start timer variables {Game in progress GLOBAL}":
    @Condition isGameInProgress() == true
    
    disableScoring()
    disableGamemodeCompletion()
    disableAnnouncer()
    disableMusic()
    pauseMatchTime()
    timeCounter = 0.001
    gameIsAlmostDone = false
    #hudSubheader([i for i in hostPlayer if "#Jokaes" == l"#{0}".format(hostPlayer)], "svr load: {0} | svr avg: {1} | svr peak: {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.TOP, -100, Color.LIME_GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([player for player in getAllPlayers() if getPeakServerLoad() < 85], "svr load: {0} | svr avg: {1} | svr peak: {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.TOP, -100, Color.LIME_GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([player for player in getAllPlayers() if getPeakServerLoad() >= 85 and getPeakServerLoad() <= 170], "svr load: {0} | svr avg: {1} | svr peak: {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.TOP, -100, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader([player for player in getAllPlayers() if getPeakServerLoad() > 170], "svr load: {0} | svr avg: {1} | svr peak: {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), HudPosition.TOP, -100, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


rule "Damage track & display":
    @Event playerDealtDamage
    @Condition victim != attacker
    @Condition round(eventDamage) >= 1 == true
    
    eventPlayer.damageDone += eventDamage
    eventPlayer.setScore(eventPlayer.damageDone)
    eventPlayer.nextObjective = (floor(eventPlayer.damageDone / damageNecessaryForNextHero) + 1) * damageNecessaryForNextHero
    destroyInWorldText(eventPlayer.damageDisplayText)
    wait()
    eventPlayer.damageDisplayPos = victim.getEyePosition()
    eventPlayer.damageDisplayScale = eventDamage / 50
    if eventPlayer.damageDisplayScale >= 1:
        goto lbl_0
    eventPlayer.damageDisplayScale = 1
    lbl_0:
    if eventWasCriticalHit:
        goto lbl_1
    createInWorldText(eventPlayer, round(eventDamage), eventPlayer.damageDisplayPos, eventPlayer.damageDisplayScale, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    lbl_1:
    if not eventWasCriticalHit:
        goto lbl_2
    createInWorldText(eventPlayer, round(eventDamage), eventPlayer.damageDisplayPos, eventPlayer.damageDisplayScale, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED, SpecVisibility.DEFAULT)
    lbl_2:
    eventPlayer.damageDisplayText = getLastCreatedText()


rule "Take away score if kill yourself {Punishment}":
    @Event playerDied
    @Condition attacker == eventPlayer
    
    eventPlayer.killYourselfPunishment = true
    smallMessage(eventPlayer, l"{0} {1} {2}".format(l"You Lose", round(eventDamage), "{0} (SUICIDE)".format(l"Points")))
    eventPlayer.damageDone -= eventDamage
    eventPlayer.setScore(eventPlayer.damageDone)
    eventPlayer.nextObjective = (floor(eventPlayer.damageDone / damageNecessaryForNextHero) + 1) * damageNecessaryForNextHero
    wait(0.032)
    eventPlayer.killYourselfPunishment = false


rule "Take away score if damage yourself {Punishment}":
    @Event playerDealtDamage
    @Condition attacker == victim
    
    wait()
    if eventPlayer.killYourselfPunishment == true:
        return
    if eventDamage <= 0.5:
        goto lbl_0
    smallMessage(eventPlayer, l"{0} {1} {2}".format(l"You Lose", round(eventDamage), "{0} (SELF-DAMAGE)".format(l"Points")))
    lbl_0:
    eventPlayer.damageDone -= eventDamage
    eventPlayer.setScore(eventPlayer.damageDone)
    eventPlayer.nextObjective = (floor(eventPlayer.damageDone / damageNecessaryForNextHero) + 1) * damageNecessaryForNextHero


rule "Victory":
    @Event eachPlayer
    @Condition eventPlayer.damageDone >= damageNecessaryForNextHero * len(heroList)
    
    bigMessage(getAllPlayers(), "GG. Thanks for playing {0}".format(iconString(Icon.HAPPY)))
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.WHITE, eventPlayer, 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.YELLOW, eventPlayer, 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.GREEN, eventPlayer, 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.PURPLE, eventPlayer, 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.RED, eventPlayer, 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.BLUE, eventPlayer, 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createInWorldText(getAllPlayers(), "{0} {0}!".format(l"Winner"), eventPlayer, 2, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    getAllPlayers().setGravity(0.1)
    declarePlayerVictory(eventPlayer)


rule "In assembling {Skip}":
    @Condition isAssemblingHeroes() == true
    
    setMatchTime(0)


rule "In setup {Reset damageDone}":
    @Event eachPlayer
    @Condition isInSetup() == true
    
    eventPlayer.damageDone = 0


rule "Workshop Settings":
    damageNecessaryForNextHero = createWorkshopSetting(int[250:1000], "Heroes Settings", "\zDamage necessary for next hero [1000]", 1000, 0)
    numberOfDpsHeroes = createWorkshopSetting(int[0:10], "Heroes Settings", "\zNum\zber of Damage heroes [4]", 4, 0)
    numberOfTankHeroes = createWorkshopSetting(int[0:8], "Heroes Settings", "\zNum\z\zber of Tank heroes [1]", 1, 0)
    numberOfSupportHeroes = createWorkshopSetting(int[0:7], "Heroes Settings", "\zNum\z\z\zber of Support heroes [1]", 1, 0)
    tankHeroesInTheMiddleOfTheList = createWorkshopSetting(bool, "Heroes Settings", "\z\z\z\z\zTan\z\z\z\z\zks in the middle of the list [ON]", true, 0)
    supportHeroesAtTheEndOfTheList = createWorkshopSetting(bool, "Heroes Settings", "\z\zSup\z\z\z\z\zports at the end of the list [ON]", true, 0)


rule "Hero List Generation":
    heroList = []
    tempHeroList = getDamageHeroes()
    tempHeroList = random.shuffle(tempHeroList)
    for heroListIt in range(numberOfDpsHeroes):
        heroList.append(tempHeroList[heroListIt])
    tempHeroListSupport = getSupportHeroes()
    tempHeroListSupport = random.shuffle(tempHeroListSupport)
    tempHeroListSupport = tempHeroListSupport.slice(0, numberOfSupportHeroes)
    tempHeroListTanks = getTankHeroes()
    tempHeroListTanks = random.shuffle(tempHeroListTanks)
    tempHeroListTanks = tempHeroListTanks.slice(0, numberOfTankHeroes)
    heroList.append(tempHeroListSupport)
    if not supportHeroesAtTheEndOfTheList:
        heroList = random.shuffle(heroList)
    if not tankHeroesInTheMiddleOfTheList:
        if not supportHeroesAtTheEndOfTheList:
            heroList.append(tempHeroListTanks)
            heroList = random.shuffle(heroList)
        else:
            tempHeroList = heroList
            heroList = []
            heroList = tempHeroList.slice(0, numberOfDpsHeroes)
            heroList.append(tempHeroListTanks)
            heroList = random.shuffle(heroList)
            heroList.append(tempHeroListSupport)
    else:
        tempHeroList = heroList
        heroList = []
        for heroListIt in range(len(getTankHeroes()) + len(getDamageHeroes()) + len(getSupportHeroes())):
            if heroListIt == ceil((len(tempHeroList) - 1) / 2):
                for heroListIt2 in range(numberOfTankHeroes):
                    heroList.append(tempHeroListTanks[heroListIt2])
            heroList.append(tempHeroList[heroListIt])
    tempHeroList = heroList
    heroList = []
    for heroListIt in range(len(getTankHeroes()) + len(getDamageHeroes()) + len(getSupportHeroes())):
        if tempHeroList[heroListIt] == null:
            break
        heroList.append(tempHeroList[heroListIt])


rule "Preload Heroes":
    @Event eachPlayer
    
    eventPlayer.preloadHero(heroList)


rule "In Setup -> Starting Hero -> HeroList[0]":
    @Event eachPlayer
    @Condition isInSetup() == true
    
    eventPlayer.startForcingHero(heroList[0])
    eventPlayer.nextObjective = damageNecessaryForNextHero


rule "In Game in progress -> Starting Hero -> HeroList[0]":
    @Event eachPlayer
    @Condition isGameInProgress() == true
    
    eventPlayer.startForcingHero(heroList[0])
    eventPlayer.nextObjective = damageNecessaryForNextHero


rule "Start forcing next hero":
    @Event eachPlayer
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.getCurrentHero() != heroList[eventPlayer.nextObjective / damageNecessaryForNextHero - 1]
    @Condition eventPlayer.damageDone > 0
    
    eventPlayer.nextObjective = (floor(eventPlayer.damageDone / damageNecessaryForNextHero) + 1) * damageNecessaryForNextHero
    eventPlayer.startForcingHero(heroList[eventPlayer.nextObjective / damageNecessaryForNextHero - 1])
    smallMessage(eventPlayer, l"{0}: {1}".format(l"{0} {1}".format(l"You", l"Hero"), heroIcon(heroList[eventPlayer.nextObjective / damageNecessaryForNextHero - 1])))
    createInWorldText(getAllPlayers(), heroIcon(heroList[eventPlayer.nextObjective / damageNecessaryForNextHero - 1]), eventPlayer, 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    eventPlayer.heroIcon = getLastCreatedText()
    wait(0.125)
    playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.PURPLE, eventPlayer, 1)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.PURPLE, eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.heroSwapEffect = getLastCreatedEntity()
    wait(1.25)
    destroyInWorldText(eventPlayer.heroIcon)
    destroyEffect(eventPlayer.heroSwapEffect)


rule "in da hood TEXT":
    @Condition isGameInProgress() == true
    
    if heroList[0] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[0]], l"{0} -> {1}".format(1, l"{0} {1}".format(heroIcon(heroList[0]), len(getPlayersOnHero(heroList[0], Team.ALL)))), HudPosition.RIGHT, 1, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[0]], l"{0} -> {1}".format(1, l"{0} {1}".format(heroIcon(heroList[0]), len(getPlayersOnHero(heroList[0], Team.ALL)))), HudPosition.RIGHT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[1] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[1]], l"{0} -> {1}".format(2, l"{0} {1}".format(heroIcon(heroList[1]), len(getPlayersOnHero(heroList[1], Team.ALL)))), HudPosition.RIGHT, 2, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[1]], l"{0} -> {1}".format(2, l"{0} {1}".format(heroIcon(heroList[1]), len(getPlayersOnHero(heroList[1], Team.ALL)))), HudPosition.RIGHT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[2] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[2]], l"{0} -> {1}".format(3, l"{0} {1}".format(heroIcon(heroList[2]), len(getPlayersOnHero(heroList[2], Team.ALL)))), HudPosition.RIGHT, 3, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[2]], l"{0} -> {1}".format(3, l"{0} {1}".format(heroIcon(heroList[2]), len(getPlayersOnHero(heroList[2], Team.ALL)))), HudPosition.RIGHT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[3] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[3]], l"{0} -> {1}".format(4, l"{0} {1}".format(heroIcon(heroList[3]), len(getPlayersOnHero(heroList[3], Team.ALL)))), HudPosition.RIGHT, 4, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[3]], l"{0} -> {1}".format(4, l"{0} {1}".format(heroIcon(heroList[3]), len(getPlayersOnHero(heroList[3], Team.ALL)))), HudPosition.RIGHT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[4] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[4]], l"{0} -> {1}".format(5, l"{0} {1}".format(heroIcon(heroList[4]), len(getPlayersOnHero(heroList[4], Team.ALL)))), HudPosition.RIGHT, 5, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[4]], l"{0} -> {1}".format(5, l"{0} {1}".format(heroIcon(heroList[4]), len(getPlayersOnHero(heroList[4], Team.ALL)))), HudPosition.RIGHT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[5] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[5]], l"{0} -> {1}".format(6, l"{0} {1}".format(heroIcon(heroList[5]), len(getPlayersOnHero(heroList[5], Team.ALL)))), HudPosition.RIGHT, 6, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[5]], l"{0} -> {1}".format(6, l"{0} {1}".format(heroIcon(heroList[5]), len(getPlayersOnHero(heroList[5], Team.ALL)))), HudPosition.RIGHT, 6, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[6] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[6]], l"{0} -> {1}".format(7, l"{0} {1}".format(heroIcon(heroList[6]), len(getPlayersOnHero(heroList[6], Team.ALL)))), HudPosition.RIGHT, 7, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[6]], l"{0} -> {1}".format(7, l"{0} {1}".format(heroIcon(heroList[6]), len(getPlayersOnHero(heroList[6], Team.ALL)))), HudPosition.RIGHT, 7, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[7] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[7]], l"{0} -> {1}".format(8, l"{0} {1}".format(heroIcon(heroList[7]), len(getPlayersOnHero(heroList[7], Team.ALL)))), HudPosition.RIGHT, 8, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[7]], l"{0} -> {1}".format(8, l"{0} {1}".format(heroIcon(heroList[7]), len(getPlayersOnHero(heroList[7], Team.ALL)))), HudPosition.RIGHT, 8, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[8] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[8]], l"{0} -> {1}".format(9, l"{0} {1}".format(heroIcon(heroList[8]), len(getPlayersOnHero(heroList[8], Team.ALL)))), HudPosition.RIGHT, 9, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[8]], l"{0} -> {1}".format(9, l"{0} {1}".format(heroIcon(heroList[8]), len(getPlayersOnHero(heroList[8], Team.ALL)))), HudPosition.RIGHT, 9, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[9] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[9]], l"{0} -> {1}".format(10, l"{0} {1}".format(heroIcon(heroList[9]), len(getPlayersOnHero(heroList[9], Team.ALL)))), HudPosition.RIGHT, 10, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[9]], l"{0} -> {1}".format(10, l"{0} {1}".format(heroIcon(heroList[9]), len(getPlayersOnHero(heroList[9], Team.ALL)))), HudPosition.RIGHT, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[10] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[10]], l"{0} -> {1}".format(11, l"{0} {1}".format(heroIcon(heroList[10]), len(getPlayersOnHero(heroList[10], Team.ALL)))), HudPosition.RIGHT, 11, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[10]], l"{0} -> {1}".format(11, l"{0} {1}".format(heroIcon(heroList[10]), len(getPlayersOnHero(heroList[10], Team.ALL)))), HudPosition.RIGHT, 11, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[11] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[11]], l"{0} -> {1}".format(12, l"{0} {1}".format(heroIcon(heroList[11]), len(getPlayersOnHero(heroList[11], Team.ALL)))), HudPosition.RIGHT, 12, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[11]], l"{0} -> {1}".format(12, l"{0} {1}".format(heroIcon(heroList[11]), len(getPlayersOnHero(heroList[11], Team.ALL)))), HudPosition.RIGHT, 12, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[12] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[12]], l"{0} -> {1}".format(13, l"{0} {1}".format(heroIcon(heroList[12]), len(getPlayersOnHero(heroList[12], Team.ALL)))), HudPosition.RIGHT, 13, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[12]], l"{0} -> {1}".format(13, l"{0} {1}".format(heroIcon(heroList[12]), len(getPlayersOnHero(heroList[12], Team.ALL)))), HudPosition.RIGHT, 13, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[13] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[13]], l"{0} -> {1}".format(14, l"{0} {1}".format(heroIcon(heroList[13]), len(getPlayersOnHero(heroList[13], Team.ALL)))), HudPosition.RIGHT, 14, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[13]], l"{0} -> {1}".format(14, l"{0} {1}".format(heroIcon(heroList[13]), len(getPlayersOnHero(heroList[13], Team.ALL)))), HudPosition.RIGHT, 14, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[14] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[14]], l"{0} -> {1}".format(15, l"{0} {1}".format(heroIcon(heroList[14]), len(getPlayersOnHero(heroList[14], Team.ALL)))), HudPosition.RIGHT, 15, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[14]], l"{0} -> {1}".format(15, l"{0} {1}".format(heroIcon(heroList[14]), len(getPlayersOnHero(heroList[14], Team.ALL)))), HudPosition.RIGHT, 15, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[15] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[15]], l"{0} -> {1}".format(16, l"{0} {1}".format(heroIcon(heroList[15]), len(getPlayersOnHero(heroList[15], Team.ALL)))), HudPosition.RIGHT, 16, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[15]], l"{0} -> {1}".format(16, l"{0} {1}".format(heroIcon(heroList[15]), len(getPlayersOnHero(heroList[15], Team.ALL)))), HudPosition.RIGHT, 16, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[16] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[16]], l"{0} -> {1}".format(17, l"{0} {1}".format(heroIcon(heroList[16]), len(getPlayersOnHero(heroList[16], Team.ALL)))), HudPosition.RIGHT, 17, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[16]], l"{0} -> {1}".format(17, l"{0} {1}".format(heroIcon(heroList[16]), len(getPlayersOnHero(heroList[16], Team.ALL)))), HudPosition.RIGHT, 17, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[17] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[17]], l"{0} -> {1}".format(18, l"{0} {1}".format(heroIcon(heroList[17]), len(getPlayersOnHero(heroList[17], Team.ALL)))), HudPosition.RIGHT, 18, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[17]], l"{0} -> {1}".format(18, l"{0} {1}".format(heroIcon(heroList[17]), len(getPlayersOnHero(heroList[17], Team.ALL)))), HudPosition.RIGHT, 18, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[18] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[18]], l"{0} -> {1}".format(19, l"{0} {1}".format(heroIcon(heroList[18]), len(getPlayersOnHero(heroList[18], Team.ALL)))), HudPosition.RIGHT, 19, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[18]], l"{0} -> {1}".format(19, l"{0} {1}".format(heroIcon(heroList[18]), len(getPlayersOnHero(heroList[18], Team.ALL)))), HudPosition.RIGHT, 19, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[19] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[19]], l"{0} -> {1}".format(20, l"{0} {1}".format(heroIcon(heroList[19]), len(getPlayersOnHero(heroList[19], Team.ALL)))), HudPosition.RIGHT, 20, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[19]], l"{0} -> {1}".format(20, l"{0} {1}".format(heroIcon(heroList[19]), len(getPlayersOnHero(heroList[19], Team.ALL)))), HudPosition.RIGHT, 20, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[20] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[20]], l"{0} -> {1}".format(21, l"{0} {1}".format(heroIcon(heroList[20]), len(getPlayersOnHero(heroList[20], Team.ALL)))), HudPosition.RIGHT, 21, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[20]], l"{0} -> {1}".format(21, l"{0} {1}".format(heroIcon(heroList[20]), len(getPlayersOnHero(heroList[20], Team.ALL)))), HudPosition.RIGHT, 21, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[21] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[21]], l"{0} -> {1}".format(22, l"{0} {1}".format(heroIcon(heroList[21]), len(getPlayersOnHero(heroList[21], Team.ALL)))), HudPosition.RIGHT, 22, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[21]], l"{0} -> {1}".format(22, l"{0} {1}".format(heroIcon(heroList[21]), len(getPlayersOnHero(heroList[21], Team.ALL)))), HudPosition.RIGHT, 22, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[22] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[22]], l"{0} -> {1}".format(23, l"{0} {1}".format(heroIcon(heroList[22]), len(getPlayersOnHero(heroList[22], Team.ALL)))), HudPosition.RIGHT, 23, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[22]], l"{0} -> {1}".format(23, l"{0} {1}".format(heroIcon(heroList[22]), len(getPlayersOnHero(heroList[22], Team.ALL)))), HudPosition.RIGHT, 23, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[23] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[23]], l"{0} -> {1}".format(24, l"{0} {1}".format(heroIcon(heroList[23]), len(getPlayersOnHero(heroList[23], Team.ALL)))), HudPosition.RIGHT, 24, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[23]], l"{0} -> {1}".format(24, l"{0} {1}".format(heroIcon(heroList[23]), len(getPlayersOnHero(heroList[23], Team.ALL)))), HudPosition.RIGHT, 24, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[24] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[24]], l"{0} -> {1}".format(25, l"{0} {1}".format(heroIcon(heroList[24]), len(getPlayersOnHero(heroList[24], Team.ALL)))), HudPosition.RIGHT, 25, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[24]], l"{0} -> {1}".format(25, l"{0} {1}".format(heroIcon(heroList[24]), len(getPlayersOnHero(heroList[24], Team.ALL)))), HudPosition.RIGHT, 25, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[25] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[25]], l"{0} -> {1}".format(26, l"{0} {1}".format(heroIcon(heroList[25]), len(getPlayersOnHero(heroList[25], Team.ALL)))), HudPosition.RIGHT, 26, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[25]], l"{0} -> {1}".format(26, l"{0} {1}".format(heroIcon(heroList[25]), len(getPlayersOnHero(heroList[25], Team.ALL)))), HudPosition.RIGHT, 26, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[26] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[26]], l"{0} -> {1}".format(27, l"{0} {1}".format(heroIcon(heroList[26]), len(getPlayersOnHero(heroList[26], Team.ALL)))), HudPosition.RIGHT, 27, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[26]], l"{0} -> {1}".format(27, l"{0} {1}".format(heroIcon(heroList[26]), len(getPlayersOnHero(heroList[26], Team.ALL)))), HudPosition.RIGHT, 27, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[27] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[27]], l"{0} -> {1}".format(28, l"{0} {1}".format(heroIcon(heroList[27]), len(getPlayersOnHero(heroList[27], Team.ALL)))), HudPosition.RIGHT, 28, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[27]], l"{0} -> {1}".format(28, l"{0} {1}".format(heroIcon(heroList[27]), len(getPlayersOnHero(heroList[27], Team.ALL)))), HudPosition.RIGHT, 28, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[28] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[28]], l"{0} -> {1}".format(29, l"{0} {1}".format(heroIcon(heroList[28]), len(getPlayersOnHero(heroList[28], Team.ALL)))), HudPosition.RIGHT, 29, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[28]], l"{0} -> {1}".format(29, l"{0} {1}".format(heroIcon(heroList[28]), len(getPlayersOnHero(heroList[28], Team.ALL)))), HudPosition.RIGHT, 29, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    if heroList[29] != null:
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() == heroList[29]], l"{0} -> {1}".format(30, l"{0} {1}".format(heroIcon(heroList[29]), len(getPlayersOnHero(heroList[29], Team.ALL)))), HudPosition.RIGHT, 30, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
        hudSubtext([player for player in getAllPlayers() if player.getCurrentHero() != heroList[29]], l"{0} -> {1}".format(30, l"{0} {1}".format(heroIcon(heroList[29]), len(getPlayersOnHero(heroList[29], Team.ALL)))), HudPosition.RIGHT, 30, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)


rule "Time Counter - Add second":
    @Condition isGameInProgress() == true
    
    setMatchTime(timeCounter)
    wait(1)
    timeCounter += 1
    goto RULE_START


rule "Game is almost done":
    @Event eachPlayer
    @Condition isGameInProgress() == true
    @Condition eventPlayer.damageDone >= damageNecessaryForNextHero * len(heroList) - damageNecessaryForNextHero
    @Condition gameIsAlmostDone == false
    
    gameIsAlmostDone = true
    enableAnnouncer()
    enableMusic()
    smallMessage(getAllPlayers(), "Damage Gun Game v9.0.0")
    wait(3.5)
    smallMessage(getAllPlayers(), "Created by Jokaes#2263")


rule "Next Objective {Next hero}":
    @Event eachPlayer
    @Condition isGameInProgress() == true
    @Condition eventPlayer.nextObjective <= damageNecessaryForNextHero * len(heroList) - damageNecessaryForNextHero
    @Condition eventPlayer.nextObjective >= 0
    
    setObjectiveDescription(eventPlayer, l"{0} {1} {2}".format(l"Deal", floor(eventPlayer.nextObjective - eventPlayer.damageDone), l"{0} -> {1}".format(l"Damage", heroIcon(heroList[eventPlayer.nextObjective / damageNecessaryForNextHero]))), HudReeval.VISIBILITY_AND_STRING)


rule "Next Objective {Win}":
    @Event eachPlayer
    @Condition isGameInProgress() == true
    @Condition eventPlayer.nextObjective == damageNecessaryForNextHero * len(heroList)
    
    setObjectiveDescription(eventPlayer, l"{0} {1} {2}".format(l"Deal", floor(eventPlayer.nextObjective - eventPlayer.damageDone), l"{0} -> {1}".format(l"Damage", l"{0} {1}".format(l"You Win", iconString(Icon.HAPPY)))), HudReeval.VISIBILITY_AND_STRING)


rule "Next Hero HUD":
    @Event eachPlayer
    
    hudSubheader(eventPlayer, l"{0}: {1}".format(l"Next Hero", eventPlayer.nextObjective), HudPosition.TOP, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


rule "Random section of the map":
    randomSectionOfMap = random.randint(1, 2)


/*
rule "Always secundary map if exists":
    randomSectionOfMap = 2
*/

rule "Global init -Created by Beemoo":
    @Condition getCurrentMap() == Map.HAVANA
    @Condition randomSectionOfMap == 2
    
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
    @Condition getCurrentMap() == Map.HAVANA
    @Condition arenaMap1 == true
    @Condition arenaMap4 > 0
    @Condition randomSectionOfMap == 2
    
    wait(0.25)
    createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, arenaMap3[arenaMap4], 1.2, EffectReeval.VISIBILITY)
    arenaMap4 -= 1
    if RULE_CONDITION:
        goto RULE_START


rule "No entry pillars (knock, tele) -Created by Beemoo":
    @Event eachPlayer
    @Condition getCurrentMap() == Map.HAVANA
    @Condition any([distance(player, eventPlayer) < 1.25 for player in arenaMap3]) == true
    @Condition randomSectionOfMap == 2
    
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
    @Condition getCurrentMap() == Map.HAVANA
    @Condition eventPlayer.getPosition().y < 26.5
    @Condition eventPlayer.getPosition().y > 25
    @Condition randomSectionOfMap == 2
    
    eventPlayer.setStatusEffect(null, Status.BURNING, 0.5)
    damage(eventPlayer, eventPlayer, 25)
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), arenaMap2[0] + vect(0, 10, 0)), 12, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.5)
    if RULE_CONDITION:
        goto RULE_START


rule "No entry OOB (spawn tele) -Created by Beemoo":
    @Event eachPlayer
    @Condition getCurrentMap() == Map.HAVANA
    @Condition eventPlayer.hasSpawned() == true
    @Condition (eventPlayer.getPosition().x < 171 or eventPlayer.getPosition().x > 229 or eventPlayer.getPosition().z < -66 or eventPlayer.getPosition().z > -15) == true
    @Condition randomSectionOfMap == 2
    
    eventPlayer.teleport(arenaMap2 + vect(random.randint(-8, 8), 0, random.randint(-19, 19)))


/*
rule "Score Debug (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    
    eventPlayer.damageDone += 100
    eventPlayer.setScore(eventPlayer.damageDone)
    eventPlayer.nextObjective = (floor(eventPlayer.damageDone / damageNecessaryForNextHero) + 1) * damageNecessaryForNextHero
    eventPlayer.startForcingHero(heroList[eventPlayer.nextObjective / damageNecessaryForNextHero - 1])
    wait(0.25)
*/

/*
rule "Dummys Summon (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isCommunicating(Comms.HELLO) == true
    
    createDummy(heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
    #createDummy(heroList[0], Team.ALL, -1, eventPlayer.getPosition(), vect(0, 0, 0))
*/

/*
rule "Dummy Aim Bot (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true
    
    eventPlayer.startFacing(directionTowards(eventPlayer, getClosestPlayer(eventPlayer, getOppositeTeam(eventPlayer.getTeam()))), 10000, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
*/

/*
rule "Dummy Ult (TEST)":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.getUltCharge() == 100
    
    eventPlayer.forceButtonPress(Button.ULTIMATE)
*/

rule "Game Mode Description v9.0.0":
    @Condition isGameInProgress() == true
    
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -101, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    hudHeader(getAllPlayers(), "CODE: SSWAT", HudPosition.LEFT, -100, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "Damage Gun Game v9.0.0", HudPosition.LEFT, -99.5, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudSubtext(getAllPlayers(), "{0} to {1} to swap to the {2}".format(l"{0} {1} {2}".format(l"Deal", damageNecessaryForNextHero * len(heroList), l"Damage"), l"{0} and {1}".format(l"Win", damageNecessaryForNextHero), l"Next Hero"), HudPosition.LEFT, -99, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudSubtext(getAllPlayers(), "(Random) {0}{1}{2}".format(("{0} DPS {1}".format(numberOfDpsHeroes, " + " if numberOfTankHeroes > 0 or numberOfSupportHeroes > 0 else "")) if numberOfDpsHeroes > 0 else "", ("{0} TANKS {1}{2}".format(numberOfTankHeroes, "{0}".format("(mid) " if tankHeroesInTheMiddleOfTheList else ""), " + " if numberOfSupportHeroes > 0 else "")) if numberOfTankHeroes > 0 else "", ("{0} SUPPORTS {1}".format(numberOfSupportHeroes, "(end)" if supportHeroesAtTheEndOfTheList else "")) if numberOfSupportHeroes > 0 else ""), HudPosition.LEFT, -98, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudSubtext(getAllPlayers(), "Totally customizable in workshop settings!", HudPosition.LEFT, -97.75, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, -97.5, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), "Created by Jokaes#2263", HudPosition.LEFT, -97, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.ALWAYS)
    hudSubtext(getAllPlayers(), "Join my discord.gg/4N4BAE6", HudPosition.LEFT, -96, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    smallMessage(getAllPlayers(), "Damage Gun Game v9.0.0")
    wait(3.5)
    smallMessage(getAllPlayers(), "{0} to {1} to swap to the {2}".format(l"{0} {1} {2}".format(l"Deal", damageNecessaryForNextHero * len(heroList), l"Damage"), l"{0} and {1}".format(l"Win", damageNecessaryForNextHero), l"Next Hero"))
    wait(3.5)
    smallMessage(getAllPlayers(), "(Random) {0}{1}{2}".format(("{0} DPS {1}".format(numberOfDpsHeroes, " + " if numberOfTankHeroes > 0 or numberOfSupportHeroes > 0 else "")) if numberOfDpsHeroes > 0 else "", ("{0} TANKS {1}{2}".format(numberOfTankHeroes, "{0}".format("(mid) " if tankHeroesInTheMiddleOfTheList else ""), " + " if numberOfSupportHeroes > 0 else "")) if numberOfTankHeroes > 0 else "", ("{0} SUPPORTS {1}".format(numberOfSupportHeroes, "(end)" if supportHeroesAtTheEndOfTheList else "")) if numberOfSupportHeroes > 0 else ""))
    wait(3.5)
    smallMessage(getAllPlayers(), "Created by Jokaes#2263")


rule "Game Mode Description for players who join":
    @Event playerJoined
    @Condition isGameInProgress() == true
    @Condition timeCounter >= 15
    
    smallMessage(eventPlayer, "Damage Gun Game v9.0.0")
    wait(3.5)
    smallMessage(eventPlayer, "{0} to {1} to swap to the {2}".format(l"{0} {1} {2}".format(l"Deal", damageNecessaryForNextHero * len(heroList), l"Damage"), l"{0} and {1}".format(l"Win", damageNecessaryForNextHero), l"Next Hero"))
    wait(3.5)
    smallMessage(eventPlayer, "(Random) {0}{1}{2}".format(("{0} DPS {1}".format(numberOfDpsHeroes, " + " if numberOfTankHeroes > 0 or numberOfSupportHeroes > 0 else "")) if numberOfDpsHeroes > 0 else "", ("{0} TANKS {1}{2}".format(numberOfTankHeroes, "{0}".format("(mid) " if tankHeroesInTheMiddleOfTheList else ""), " + " if numberOfSupportHeroes > 0 else "")) if numberOfTankHeroes > 0 else "", ("{0} SUPPORTS {1}".format(numberOfSupportHeroes, "(end)" if supportHeroesAtTheEndOfTheList else "")) if numberOfSupportHeroes > 0 else ""))
    wait(3.5)
    smallMessage(eventPlayer, "Created by Jokaes#2263")


/*
rule "Damage Gun Game v9.0.0":
*/

/*
rule "Created by Jokaes#2263":
*/

