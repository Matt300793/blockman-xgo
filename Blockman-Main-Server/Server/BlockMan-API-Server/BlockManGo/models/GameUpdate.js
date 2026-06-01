const MariaDB = require("@common/MariaDB");
const Model = require("@common-models/Model");

module.exports = class GameUpdate extends Model {
    constructor(gameId) {
        super();

        this.gameId = gameId;
        this.version = 0;
        this.content = "";
    }

    static async fromGameId(gameId) {
        const gameUpdate = await MariaDB.findFirst(`SELECT * FROM game_update WHERE gameId="${gameId}"`);
        if (gameUpdate) return Model.fromJson(GameUpdate, gameUpdate);

        return new GameUpdate(gameId);
    }

    response() {
        return {
            count: this.version,
            content: this.content
        }
    }

    setGameId(gameId) {
        this.gameId = gameId;
    }

    getGameId() {
        return this.gameId;
    }

    setVersion(version) {
        this.version = version;
    }

    getVersion() {
        return this.version;
    }

    setContent(content) {
        this.content = content;
    }

    getContent() {
        return this.content;
    }
}