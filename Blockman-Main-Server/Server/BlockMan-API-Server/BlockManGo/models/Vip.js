const AssetUtil = require("@common/AssetUtil");
const MariaDB = require("@common/MariaDB");
const VipLevels = require("@common-constants/VipLevels");
const Model = require("@common-models/Model");

module.exports = class Vip extends Model {
    constructor(userId) {
        super();

        this.userId = userId;
        this.vip = 0;
        this.expireDate = 0;
        this.startTime = 0;
    }

    /** @returns {Promise<Vip>} */
    static async fromUserId(userId) {
        const vip = await MariaDB.findFirst(`SELECT * FROM vip WHERE userId=${userId}`);
        if (vip) return await Vip.fromJson(vip);

        return new Vip(userId);
    }

    static async fromJson(json) {
        const vip = super.fromJson(Vip, json);
        if (vip.getLevel() > 0 && Date.now() > vip.getExpireDate()) {
            vip.setLevel(0);
            vip.setExpireDate(0);
            vip.setStartTime(0);
            vip.setModifyTime(0);
            await vip.save();
        }

        return vip;
    }

    upgrade(vipLevel) {
        if (this.vip >= vipLevel) {
            return;
        }

        this.vip = vipLevel;
    }

    addDays(days) {
        const daysTimestamp = (days * 24 * 60 * 60 * 1000);
        if (!this.expireDate) {
            this.expireDate = Date.now() + daysTimestamp;
        } else {
            this.expireDate += daysTimestamp;
        }
    }

    getDays() {
        const timestampDiff = new Date(this.expireDate).getTime() - new Date().getTime();
        return Math.ceil(timestampDiff / (1000 * 60 * 60 * 24));
    }

    async save() {
        await MariaDB.executeQuery(`INSERT INTO vip VALUES ${super.getSqlCreate()} ON DUPLICATE KEY UPDATE ${super.getSqlUpdate()}`);
    }

    response() {
        return {
            vip: this.vip,
            expireDate: this.expireDate
        }
    }

    asReward() {
        return {
            pic: AssetUtil.getVipIcon(this.vip),
            vip: this.vip,
            days: this.getDays()
        }
    }

    setUserId(userId) {
        this.userId = userId;
    }

    getUserId() {
        return this.userId;
    }

    setLevel(vip) {
        this.vip = vip;
    }

    getLevel() {
        return this.vip;
    }

    setExpireDate(expireDate) {
        this.expireDate = expireDate;
    }

    getExpireDate() {
        return this.expireDate;
    }

    setStartTime(startTime) {
        this.startTime = startTime;
    }

    getStartTime() {
        return this.startTime;
    }
}