const MariaDB = require("@common/MariaDB");
const Model = require("@common-models/Model");

module.exports = class GamePartyConfig extends Model {
    constructor(gameId) {
        super();
        
        this.gameId = gameId;
        this.gameType = 0;
        this.maxPlayers = 0;
        this.teamNumber = 0;
        this.teamPlayers = 0;
        this.vipPlayers = 0;
        this.commonPlayers = 0;
    }

    /** @returns {Promise<GamePartyConfig>} */
    static async fromGameId(gameId) {
        const gamePartyConfig = await MariaDB.findFirst(`SELECT * FROM game_party_config WHERE gameId="${gameId}"`);
        if (gamePartyConfig) return super.fromJson(GamePartyConfig, gamePartyConfig);

        return null;
    }

    response() {
        return {
            commonMem: this.commonPlayers,
            gameCategory: this.gameType,
            gameId: this.gameId,
            memberMax: this.maxPlayers,
            teamMem: this.teamPlayers,
            teamNum: this.teamNumber,
            vipMem: this.vipPlayers, 
            partyStatus: 1
        }
    }
}