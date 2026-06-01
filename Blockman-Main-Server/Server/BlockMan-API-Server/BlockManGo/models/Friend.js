const MariaDB = require("@common/MariaDB");
const Clan = require("@common-models/Clan");
const ClanMember = require("@common-models/ClanMember");
const Model = require("@common-models/Model");
const Page = require("@common-models/Page");
const User = require("@common-models/User");
const Vip = require("@common-models/Vip");

module.exports = class Friend extends Model {
    constructor() {
        super();

        this.userId = 0;
        this.friendId = 0;
        this.alias = "";
    }

    /** @returns {Promise<Friend>} */
    static async fromUserId(userId, friendId) {
        const friend = await MariaDB.findFirst(`SELECT * FROM friend WHERE userId=${userId} AND friendId=${friendId}`);
        if (friend) return Model.fromJson(Friend, friend);

        return null;
    }

    static async getRecommendation(userId, limit) {
        const rows = await MariaDB.executeQuery(`SELECT * FROM user WHERE NOT userId=${userId} ORDER BY RAND() LIMIT ${limit};`);
        for (let i = 0; i < rows.length; i++) {
            rows[i] = Model.fromJson(User, rows[i]);
        }

        return rows.map(friend => {
            return {
                userId: friend.getUserId(),
                nickName: friend.getNickname(),
                sex: friend.getSex(),
                headPic: friend.getProfilePic(),
                gameId: []
            }
        });
    }

    static async listFromUserId(userId, pageNo, pageSize) {
        const totalSize = await MariaDB.findFirst(`SELECT COUNT(1) FROM friend WHERE userId=${userId}`, "COUNT(1)", 0);
        
        const startIndex = Page.getStartIndex(pageNo, pageSize);
        const rows = await MariaDB.executeQuery(`SELECT * FROM friend WHERE userId=${userId} LIMIT ${pageSize} OFFSET ${startIndex}`);
        for (let i = 0; i < rows.length; i++) {
            rows[i] = Model.fromJson(Friend, rows[i]);
        }

        return new Page(rows, totalSize, pageNo, pageSize);
    }

    static async listIdsFromUserId(userId) {
        const friendIds = [];
        const rows = await MariaDB.executeQuery(`SELECT * FROM friend WHERE userId=${userId}`);
        for (let i = 0; i < rows.length; i++) {
            friendIds.push(Number(rows[i].friendId));
        }

        return friendIds;
    }

    static async search(userId, query, excludeList, pageNo, pageSize) {
        if (!excludeList || excludeList.length == 0) {
            excludeList = "0";
        } else {
            excludeList = excludeList.toString();
        }
        
        const startIndex = Page.getStartIndex(pageNo, pageSize);
        const rows = await MariaDB.executeQuery(`SELECT * FROM user WHERE nickName LIKE "${query}%" AND NOT userId=${userId} AND userId NOT IN (${excludeList}) LIMIT ${pageSize} OFFSET ${startIndex}`);
        for (let i = 0; i < rows.length; i++) {
            if (excludeList.includes(rows[i].friendId)) {
                rows.splice()
            }
            rows[i] = Model.fromJson(User, rows[i]);
        }
        
        const totalSize = await MariaDB.findFirst(`SELECT COUNT(1) FROM user WHERE nickName LIKE "${query}%" AND NOT userId=${userId}`, "COUNT(1)", 0);
        return new Page(rows, totalSize, pageNo, pageSize);
    }

    static async getInfo(userId) {
        const user = await User.fromUserId(userId);
        const vip = await Vip.fromUserId(userId);
        
        let clanInfo = {};
        const clanMember = await ClanMember.fromUserId(userId);
        if (clanMember && clanMember.clanId != 0) {
            const clan = await Clan.fromClanId(clanMember.clanId);
            clanInfo = {
                clanId: clan.clanId,
                clanName: clan.name,
                role: clanMember.role
            };
        }

        return {
            ...user.response(),
            ...vip.response(),
            ...clanInfo
        };
    }

    static async isFriend(userId, friendId) {
        const rowCount = await MariaDB.findFirst(`SELECT COUNT(1) FROM friend WHERE (userId=${userId} AND friendId=${friendId}) OR (userId=${friendId} AND friendId=${userId})`, "COUNT(1)", 0);
        return rowCount == 2;
    }

    static async addFriend(userId, friendId) {
        await MariaDB.executeQuery(`INSERT INTO friend VALUES (${userId},${friendId},""),
                                                              (${friendId},${userId},"")`);
    }

    static async removeFriend(userId, friendId) {
        await MariaDB.executeQuery(`DELETE FROM friend WHERE (userId=${userId} AND friendId=${friendId}) OR (userId=${friendId} AND friendId=${userId})`);
    }

    async save() {
        await MariaDB.executeQuery(`UPDATE friend SET alias="${this.alias}" WHERE userId=${this.userId} AND friendId=${this.friendId}`);
    }
    
    setUserId(userId) {
        this.userId = userId;
    }

    getUserId() {
        return this.userId;
    }

    setFriendId(friendId) {
        this.friendId = friendId;
    }

    getFriendId() {
        return this.friendId;
    }

    setAlias(alias) {
        this.alias = alias;
    }

    getAlias() {
        return this.alias;
    }
}