const Redis = require("@common/Redis");
const RedisKeys = require("@common/RedisKeys");
const MariaDB = require("@common/MariaDB");
const ServerTime = require("@common/ServerTime");
const clanConfig = require("@common-config/clan");
const Currencies = require("@common-constants/Currencies");
const Clan = require("@common-models/Clan");
const Model = require("@common-models/Model");
const Page = require("@common-models/Page");
const Vip = require("@common-models/Vip");
const ClanTask = require("@common-models/ClanTask");

module.exports = class ClanDonation extends Model {
    constructor() {
        super();

        this.userId = 0;
        this.clanId = 0;
        this.nickName = "";
        this.type = 0;
        this.amount = 0;
        this.expReward = 0;
        this.clanGoldReward = 0;
        this.creationTime = 0;
    }

    static async historyFromClanId(clanId, pageNo, pageSize) {
        const totalSize = await MariaDB.findFirst(`SELECT COUNT(1) FROM clan_donation WHERE clanId=${clanId}`, "COUNT(1)", 0);
        
        const startIndex = Page.getStartIndex(pageNo, pageSize);
        const rows = await MariaDB.executeQuery(`SELECT * FROM clan_donation WHERE clanId=${clanId} ORDER BY creationTime DESC LIMIT ${pageSize} OFFSET ${startIndex}`);
        for (let i = 0; i < rows.length; i++) {
            rows[i] = Model.fromJson(ClanDonation, rows[i]).response();
        }

        return new Page(rows, totalSize, pageNo, pageSize);
    }

    async getInfo() {
        const vip = await Vip.fromUserId(this.userId);
        const clan = await Clan.fromClanId(this.clanId);
        const clanLevelConfig = clanConfig.levels[clan.level];

        const currentGold = await Redis.getKey(RedisKeys.CACHE_USER_DONATION_CURRENCY, Currencies.GOLD, this.userId) ?? 0;
        const currentDiamonds = await Redis.getKey(RedisKeys.CACHE_USER_DONATION_CURRENCY, Currencies.DIAMOND, this.userId) ?? 0;
        const currentTasks = await ClanTask.getFinishedTaskCount(this.userId, this.clanId);

        return {
            currentGold: currentGold,
            currentDiamond: currentDiamonds,
            currentTask: currentTasks,
            currentExperience: clan.getUpgradeExperience(),
            clanId: clan.clanId,
            level: clan.level,
            maxDiamond: clanLevelConfig.maxDiamondDonate * clanConfig.vipBoosts[vip.getLevel()].maxDiamondDonate,
            maxExperience: clanLevelConfig.upgradeExperience,
            maxGold: clanLevelConfig.maxGoldDonate * clanConfig.vipBoosts[vip.getLevel()].maxGoldDonate,
            maxTask: clanLevelConfig.personalTaskCount + clanLevelConfig.clanTaskCount
        }
    }

    async saveToHistory() {
        await MariaDB.executeQuery(`INSERT INTO clan_donation VALUES ${super.getSqlCreate()}`);
    }

    async save() {
        await Redis.setKey({
            key: RedisKeys.CACHE_USER_DONATION_CURRENCY,
            params: [this.type, this.userId] 
        }, this.amount);

        await Redis.setExpire({ key: RedisKeys.CACHE_USER_DONATION_CURRENCY, params: [this.type, this.userId] }, ServerTime.getTodayTimeLeft());
    }

    response() {
        return {
            date: this.creationTime,
            experienceGot: this.expReward,
            nickName: this.nickName,
            quantity: this.amount,
            tribeCurrencyGot: this.clanGoldReward,
            type: this.type,
            userId: this.userId
        }
    }

    setUserId(userId) {
        this.userId = userId;
    }

    getUserId() {
        return this.userId;
    }

    setClanId(clanId) {
        this.clanId = clanId;
    }

    getClanId() {
        return this.clanId;
    }

    setNickname(nickName) {
        this.nickName = nickName;
    }

    getNickname() {
        return this.nickName;
    }

    setType(type) {
        this.type = type;
    }

    getType() {
        return this.type;
    }

    setAmount(amount) {
        this.amount = amount;
    }

    getAmount() {
        return this.amount;
    }

    setExpReward(expReward) {
        this.expReward = expReward;
    }

    getExpReward() {
        return this.expReward;
    }

    setClanGoldReward(clanGoldReward) {
        this.clanGoldReward = clanGoldReward;
    }

    getClanGoldReward() {
        return this.clanGoldReward;
    }

    setCreationTime(creationTime) {
        this.creationTime = creationTime;
    }

    getCreationTime() {
        return this.creationTime;
    }
}