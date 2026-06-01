const MariaDB = require("@common/MariaDB");
const Redis = require("@common/Redis");
const RedisKeys = require("@common/RedisKeys");
const Model = require("@common-models/Model");

module.exports = class User extends Model {
    constructor(userId) {
        super();

        this.userId = userId;
        this.nickName = "";
        this.sex = 0;
        this.picUrl = "";
        this.details = "";
        this.birthday = "";
        this.isFreeNickname = true;
        this.donatorTier = 0;
    }

    /** @returns {Promise<User>} */
    static async fromUserId(userId) {
        const user = await MariaDB.findFirst(`SELECT * FROM user WHERE userId=${userId}`);
        if (user) return Model.fromJson(User, user);

        return null;
    }

    /** @returns {Promise<User>} */
    static async fromNickname(nickName) {
        const user = await MariaDB.findFirst(`SELECT * FROM user WHERE nickName="${nickName}"`);
	    if (user) return Model.fromJson(User, user);

	    return null;
    }

    /** @returns {Promise<Boolean>} */
    static async exists(userId) {
        const rows = await MariaDB.executeQuery(`SELECT COUNT(1) FROM user WHERE userId=${userId}`);
        if (!rows) {
            return null;
        }
        
        return rows[0]["COUNT(1)"] == 1;
    }

    async changeNickname(newNickname) {
        if (this.nickName) {
            await Redis.deleteKey(RedisKeys.NICKNAME_RESERVATION, this.nickName);
        }

        await Redis.setKey({
            key: RedisKeys.NICKNAME_RESERVATION, params: [newNickname]
        }, "1");

        this.nickName = newNickname;
    }

    async create() {
        await MariaDB.executeQuery(`INSERT INTO user VALUES ${super.getSqlCreate()}`);
    }

    async save() {
        await MariaDB.executeQuery(`UPDATE user SET ${super.getSqlUpdate()} WHERE userId=${this.userId}`);
    }

    response() {
        return {
            userId: this.userId,
            nickName: this.nickName,
            sex: this.sex,
            picUrl: this.picUrl,
            details: this.details,
            birthday: this.birthday,
            donatorTier: this.donatorTier
        }
    }

    setUserId(userId) {
        this.userId = userId;
    }

    getUserId() {
        return this.userId;
    }

    setNickname(nickName) {
        this.nickName = nickName;
    }

    getNickname() {
        return this.nickName;
    }

    setSex(sex) {
        this.sex = sex;
    }

    getSex() {
        return this.sex;
    }

    setProfilePic(picUrl) {
        this.picUrl = picUrl;
    }

    getProfilePic() {
        return this.picUrl;
    }

    setDetails(details) {
        this.details = details;
    }

    getDetails() {
        return this.details;
    }
 
    setBirthday(birthday) {
        this.birthday = birthday;
    }

    getBirthday() {
        return this.birthday;
    }

    setIsFreeNickname(isFreeNickname) {
        this.isFreeNickname = isFreeNickname;
    }

    getIsFreeNickname() {
        return this.isFreeNickname;
    }

    setDonatorTier(donatorTier) {
        this.donatorTier = donatorTier;
    }

    getDonatorTier() {
        return this.donatorTier;
    }
}
