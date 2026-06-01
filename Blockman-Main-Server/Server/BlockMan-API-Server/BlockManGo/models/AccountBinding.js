const MariaDB = require("@common/MariaDB");
const Model = require("@common-models/Model");

module.exports = class AccountBinding extends Model {
    constructor(data) {
        super();

        data ??= {};

        this.userId = data.userId ?? 0;
        this.connectId = data.connectId ?? "";
    }
    
    /** @returns {Promise<AccountBinding>} */
    static async fromUserId(userId) {
        const accountBinding = await MariaDB.findFirst(`SELECT * FROM account_binding WHERE userId=${userId}`);
        if (accountBinding) return Model.fromJson(AccountBinding, accountBinding);

        return new AccountBinding({ userId });
    }

    /** @returns {Promise<AccountBinding>} */
    static async fromConnectId(connectId) {
        const accountBinding = await MariaDB.findFirst(`SELECT * FROM account_binding WHERE connectId=${connectId}`);
        if (accountBinding) return Model.fromJson(AccountBinding, accountBinding);
        
        return new AccountBinding({ connectId });
    }

    async save() {
        await MariaDB.executeQuery(`INSERT INTO account_binding VALUES ${super.getSqlCreate()}`);
    }

    async delete() {
        await MariaDB.executeQuery(`DELETE FROM account_binding WHERE userId=${this.userId}`);
    }

    setUserId(userId) {
        this.userId = userId;
    }

    getUserId() {
        return this.userId;
    }

    setConnectId(connectId) {
        this.connectId = connectId;
    }

    getConnectId() {
        return this.connectId;
    }
}
