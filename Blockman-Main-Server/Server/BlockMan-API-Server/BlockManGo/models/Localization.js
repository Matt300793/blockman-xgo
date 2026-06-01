const MariaDB = require("@common/MariaDB");
const Model = require("@common-models/Model");

module.exports = class Localization extends Model {
    constructor(userId) {
        super();

        this.userId = userId;
        this.language = "";
        this.country = "";
    }

    /** @returns {Promise<Localization>} */
    static async fromUserId(userId) {
        const vip = await MariaDB.findFirst(`SELECT * FROM user_locale WHERE userId=${userId}`);
        if (vip) return Model.fromJson(Localization, vip);

        return new Localization(userId);
    }
    
    async save() {
        await MariaDB.executeQuery(`INSERT INTO user_locale VALUES ${super.getSqlCreate()} ON DUPLICATE KEY UPDATE ${super.getSqlUpdate()}`);
    }

    setUserId(userId) {
        this.userId = userId;
    }

    getUserId() {
        return this.userId;
    }

    setLanguage(language) {
        this.language = language;
    }

    getLanguage() {
        return this.language;
    }

    setCountry(country) {
        this.country = country;
    }

    getCountry() {
        return this.country;
    }
}