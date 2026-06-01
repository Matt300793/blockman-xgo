const MariaDB = require("@common/MariaDB");
const Redis = require("@common/Redis");
const RedisKeys = require("@common/RedisKeys");
const ServerTime = require("@common/ServerTime");
const clanConfig = require("@common-config/clan");
const ClanRoles = require("@common-constants/ClanRoles");
const ClanMember = require("@common-models/ClanMember");
const Model = require("@common-models/Model");
const Page = require("@common-models/Page");

module.exports = class Clan extends Model {
    constructor(clanId) {
        super();

        this.clanId = clanId;
        this.name = "";
        this.picUrl = "";
        this.tags = [];
        this.details = "";
        this.experience = 0;
        this.level = 1;
        this.memberCount = 0;
        this.freeVerify = 0;
        this.language = "";
        this.creationTime = 0;
    }

    /** @returns {Promise<Clan>} */
    static async fromClanId(clanId) {
        const clan = await MariaDB.findFirst(`SELECT * FROM clan WHERE clanId=${clanId}`);
        if (clan) return Model.fromJson(Clan, clan);

        return null;
    }

    /** @returns {Promise<Page>}  */
    static async search(clanId, query, pageNo, pageSize) {
        const totalSize = await MariaDB.findFirst(`SELECT COUNT(1) FROM clan WHERE name LIKE "${query}%" AND NOT clanId=${clanId}`, "COUNT(1)", 0);

        const startIndex = Page.getStartIndex(pageNo, pageSize);
        const rows = await MariaDB.executeQuery(`SELECT * FROM clan WHERE name LIKE "${query}%" AND NOT clanId=${clanId} LIMIT ${pageSize} OFFSET ${startIndex}`);
        for (let i = 0; i < rows.length; i++) {
            rows[i] = Model.fromJson(Clan, rows[i]).response();
        }

        return new Page(rows, totalSize, pageNo, pageSize);
    }

    /** @returns {Promise<List<Clan>>} */
    static async getRecommendation(limit) {
        const rows = await MariaDB.executeQuery(`SELECT * FROM clan ORDER BY RAND() LIMIT ${limit};`);
        for (let i = 0; i < rows.length; i++) {
            rows[i] = Model.fromJson(Clan, rows[i]);
        }

        return rows.map(clan => {
            return {
                clanId: clan.getClanId(),
                name: clan.getName(),
                currentCount: clan.getMemberCount(),
                detail: clan.getDetails(),
                headPic: clan.getProfilePic(),
                level: clan.getLevel(),
                maxCount: clanConfig.levels[clan.getLevel()].maxCount,
                freeVerify: clan.getVerification()
            }
        });
    }

    /** @returns {Promise<Boolean>} */
    static async exists(clanId) {
        const count = await MariaDB.findFirst(`SELECT COUNT(1) FROM clan WHERE clanId=${clanId}`, "COUNT(1)", 0);
        return count == 1;
    }

    async addMember(userId, role) {
        const clanMember = new ClanMember(userId);
        clanMember.setClanId(this.clanId);
        clanMember.setRole(role);

        await clanMember.save();
        this.memberCount++;
    }

    async removeMember(userId) {
        const clanMember = await ClanMember.fromUserId(userId);
        if (clanMember.getClanId() != this.clanId) {
            return false;
        }

        await clanMember.delete();
        this.memberCount--;

        return true;
    }

    /** @returns {Promise<List<ClanMember>>} */
    async getMembers(onlyAuthorities, mapToInfo) {
        const rows = await MariaDB.executeQuery(`SELECT * FROM clan_member WHERE clanId=${this.clanId} ${onlyAuthorities ? `AND role > ${ClanRoles.MEMBER}` : ``}`);
        for (let i = 0; i < rows.length; i++) {
            if (mapToInfo) {
                rows[i] = await Model.fromJson(ClanMember, rows[i]).getInfo();
            } else {
                rows[i] = await Model.fromJson(ClanMember, rows[i])
            }
        }

        return rows;
    }

    /** @returns {Promise<Number>} */
    async getElderCount() {
        return Number(
            await MariaDB.findFirst(`SELECT COUNT(1) FROM clan_member WHERE clanId=${this.clanId} AND role=${ClanRoles.ELDER}`, "COUNT(1)", 0)
        );
    }
    
    getUpgradeExperience() {
        const clanLevelConfig = clanConfig.levels[this.level];
        if (!clanLevelConfig.upgradeExperience) {
            return 0;
        }

        let lastUpgradeExperience = 0;
        for (let i = 1; i < this.level - 1; i++) {
            lastUpgradeExperience += (clanConfig.levels[i + 1].upgradeExperience ?? 0);
        }

        return this.experience - lastUpgradeExperience;
    }

    async addExperience(experience) {
        this.experience += experience;

        await this.updateRanking(experience);
        
        const clanLevelConfig = clanConfig.levels[this.level];
        if (clanLevelConfig.upgradeExperience && this.getUpgradeExperience() >= clanLevelConfig.upgradeExperience) {
            this.level += 1;
        }
    }

    async updateRanking(experience) {
        await Redis.incrementKeyScore(RedisKeys.CACHE_CLAN_WEEK_RANK, this.clanId, experience);
        await Redis.setExpire({ key: RedisKeys.CACHE_CLAN_WEEK_RANK }, ServerTime.getWeekTimeLeft()); // Only set once for the whole week
        
        await Redis.incrementKeyScore(RedisKeys.CACHE_CLAN_MONTH_RANK, this.clanId, experience);
        await Redis.setExpire({ key: RedisKeys.CACHE_CLAN_MONTH_RANK }, ServerTime.getMonthTimeLeft()); // Only set once for the whole month

        await Redis.incrementKeyScore(RedisKeys.CLAN_OVERALL_RANK, this.clanId, experience);
    }

    async create() {
        await this.updateRanking(0);
        await MariaDB.executeQuery(`INSERT INTO clan VALUES ${super.getSqlCreate()}`);
    }

    async save() {
        await MariaDB.executeQuery(`UPDATE clan SET ${super.getSqlUpdate()} WHERE clanId=${this.clanId}`);
    }

    async delete() {
        await MariaDB.executeQuery(`DELETE FROM clan WHERE clanId=${this.clanId}`);
        
        await Redis.deleteKeyScore(RedisKeys.CACHE_CLAN_WEEK_RANK, this.clanId);
        await Redis.deleteKeyScore(RedisKeys.CACHE_CLAN_MONTH_RANK, this.clanId);
        await Redis.deleteKeyScore(RedisKeys.CLAN_OVERALL_RANK, this.clanId);

        // TODO: Delete keys related to the clan
        await MariaDB.executeQuery(`DELETE FROM clan_donation WHERE clanId=${this.clanId}`);
    }

    response(shownMembers) {
        return {
            clanId: this.clanId,
            currentCount: this.memberCount,
            details: this.details,
            experience: this.experience,
            headPic: this.picUrl,
            level: this.level,
            name: this.name,
            maxCount: clanConfig.levels[this.level].maxCount,
            clanMembers: shownMembers,
            tags: this.tags,
            freeVerify: this.freeVerify
        }
    }

    setClanId(clanId) {
        this.clanId = clanId;
    }

    getClanId() {
        return this.clanId;
    }

    setName(name) {
        this.name = name;
    }

    getName() {
        return this.name;
    }

    getMemberCount() {
        return this.memberCount;
    }

    setDetails(details) {
        this.details = details;
    }

    getDetails() {
        return this.details;
    }

    setExperience(experience) {
        this.experience = experience;
    }

    getExperience() {
        return this.experience;
    }

    setProfilePic(picUrl) {
        this.picUrl = picUrl;
    }

    getProfilePic() {
        return this.picUrl;
    }

    setLevel(level) {
        this.level = level;
    }

    getLevel() {
        return this.level;
    }

    setTags(tags) {
        this.tags = tags;
    }

    getTags() {
        return this.tags;
    }

    setVerification(freeVerify) {
        this.freeVerify = freeVerify;
    }

    getVerification() {
        return this.freeVerify;
    }

    setCreationTime(creationTime) {
        this.creationTime = creationTime;
    }

    getCreationTime() {
        return this.creationTime;
    }
}