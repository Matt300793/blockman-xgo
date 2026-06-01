const MariaDB = require("@common/MariaDB");
const policyConfig = require("@common-config/policies");
const BanStatuses = require("@common-constants/BanStatuses");
const DeviceBindTypes = require("@common-constants/DeviceBindTypes");
const Model = require("@common-models/Model");
const User = require("@common-models/User");

module.exports = class Account extends Model {
    constructor(userId) {
        super();

        this.userId = userId;
        this.email = "";
        this.password = "";
        this.creationTime = 0;
        this.accessToken = "";
        this.connectId = "";
        this.hasDeviceBinding = 0;
        this.banDuration = 0;
        this.banReason = 0;
    }

    /** @returns {Promise<Account>} */
    static async fromUserId(userId) {
        const account = await MariaDB.findFirst(`SELECT * FROM account WHERE userId=${userId}`);
        if (account) return Account.fromJson(account);

        return null;
    }

    /** @returns {Promise<Account>} */
    static async fromIdentifier(identifier) {
	    if (isNaN(identifier)) {
	        const user = await User.fromNickname(identifier);
	    
	        const account = user ? await Account.fromUserId(user.getUserId()) : null;
	        if (account) {
	            return Account.fromJson(account);
	        }

	        return null;
	    }

	    return Account.fromUserId(identifier);
    }

    static async fromConnectId(connectId) {
        const account = await MariaDB.findFirst(`SELECT * FROM account WHERE connectId="${connectId}"`);
        if (account) return Account.fromJson(account);

        return null;
    }

    static async fromEmail(email) {
        const account = await MariaDB.findFirst(`SELECT * FROM account WHERE email="${email}"`);
        if (account) return Account.fromJson(account);

        return null;
    }

    static fromJson(json) {
        const account = Model.fromJson(Account, json);
        if (policyConfig.enforceDeviceBinding) {
            account.setHasDeviceBinding(DeviceBindTypes.ENABLED);
        }

        if (account.banDuration < Date.now()) {
            account.setBanDuration(0);
            account.setBanReason(0);
        }
        
        return account;
    }

    async save() {
        await MariaDB.executeQuery(`INSERT INTO account VALUES ${super.getSqlCreate()} ON DUPLICATE KEY UPDATE ${super.getSqlUpdate()}`);
    }

    response() {
        return {
            userId: this.userId,
            accessToken: this.accessToken,
            hasPassword: this.password != null,
            hasDeviceBinding: this.getHasDeviceBinding(),
            connectId: this.connectId
        };
    }

    getBanInfo() {
        return {
            userId: this.userId,
            status: this.banDuration > 0 ? BanStatuses.BANNED : BanStatuses.NOT_BANNED,
            stopToTime: this.banDuration,
            stopReason: `ban_reason_${this.banReason}`
        }
    }

    setUserId(userId) {
        this.userId = userId;
    }

    getUserId() {
        return this.userId;
    }

    setEmail(email) {
        this.email = email;
    }

    getEmail() {
        return this.email;
    }

    setPassword(password) {
        this.password = password;
    }

    getPassword() {
        return this.password;
    }

    setCreationTime(creationTime) {
        this.creationTime = creationTime;
    }

    getCreationTime() {
        return this.creationTime;
    }

    setAccessToken(accessToken) {
        this.accessToken = accessToken;
    }

    getAccessToken() {
        return this.accessToken;
    }

    setConnectId(connectId) {
        this.connectId = connectId;
    }

    getConnectId() {
        return this.connectId;
    }

    setHasDeviceBinding(hasDeviceBinding) {
        this.hasDeviceBinding = hasDeviceBinding;
    }

    getHasDeviceBinding() {
        if (policyConfig.enforceDeviceBinding) {
            return DeviceBindTypes.ENFORCED;
        }

        return this.hasDeviceBinding;
    }

    setBanDuration(banDuration) {
        this.banDuration = banDuration;
    }

    getBanDuration() {
        return this.banDuration;
    }

    setBanReason(banReason) {
        this.banReason = banReason;
    }

    getBanReason() {
        return this.banReason;
    }
}