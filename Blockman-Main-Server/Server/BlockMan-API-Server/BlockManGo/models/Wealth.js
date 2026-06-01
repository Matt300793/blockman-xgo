const MariaDB = require("@common/MariaDB");
const Model = require("@common-models/Model");

module.exports = class Wealth extends Model {
    constructor(userId) {
        super();

        this.userId = userId;
        this.golds = 0;
        this.diamonds = 0;
        this.clanGolds = 0;
    }

    /** @returns {Promise<Wealth>} */
    static async fromUserId(userId) {
        const rows = await MariaDB.executeQuery(`SELECT * FROM wealth WHERE userId=${userId}`);
        const wealth = rows[0] ?? null;
        if(wealth) {
            return Model.fromJson(Wealth, wealth);
        }
        
        return new Wealth(userId);
    }
    
    async save() {
        await MariaDB.executeQuery(`INSERT INTO wealth VALUES ${super.getSqlCreate()} ON DUPLICATE KEY UPDATE ${super.getSqlUpdate()}`);
    }

    setGold(gold) {
        this.golds = gold;
    }

    getGold() {
        return this.golds;
    }

    setDiamonds(diamonds) {
        this.diamonds = diamonds;
    }

    getDiamonds() {
        return this.diamonds;
    }

    setClanGold(clanGold) {
        this.clanGolds = clanGold;
    }

    getClanGold() {
        return this.clanGolds;
    }
}