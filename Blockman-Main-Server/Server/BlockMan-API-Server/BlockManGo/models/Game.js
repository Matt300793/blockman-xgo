const AssetUtil = require("@common/AssetUtil");
const Redis = require("@common/Redis");
const MariaDB = require("@common/MariaDB");
const RedisKeys = require("@common/RedisKeys");
const Translator = require("@common/Translator");
const LanguageKeys = require("@common-constants/LanguageKeys");
const Model = require("@common-models/Model");
const Page = require("@common-models/Page");
const GameLike = require("@common-models/GameLike");

module.exports = class Game extends Model {
    constructor() {
        super();

        this.gameId = "";
        this.gameName = "";
        this.gameTypes = [];
        this.likeCount = 0;
        this.playerCount = 0;
        this.shopEnabled = 0;
        this.rankEnabled = 0;
        this.partyEnabled = 0;
        this.excludeGame = 0;
        this.authorId = 0;
        this.creationTime = 0;
    }
    
    /** @returns {Promise<Game>} */
    static async fromGameId(gameId, language) {
        const game = await MariaDB.findFirst(`SELECT * FROM game WHERE gameId="${gameId}"`);
        if (game) {
            const gameModel = Model.fromJson(Game, game);
            if (language && language != LanguageKeys.NO_LANGUAGE) {
                await gameModel.load(language);
            }

            return gameModel;
        }

        return null;
    }

    /** @returns {Promise<Page>} */
    static async listGames(orderMode, pageNo, pageSize, language) {
        const totalSize = await MariaDB.findFirst(`SELECT COUNT(1) FROM game WHERE excludeGame=0`, "COUNT(1)", 0);
        
        const startIndex = Page.getStartIndex(pageNo, pageSize);
        const rows = await MariaDB.executeQuery(`SELECT * FROM game WHERE excludeGame=0 ORDER BY gameId ${orderMode} LIMIT ${pageSize} OFFSET ${startIndex}`);
        for (let i = 0; i < rows.length; i++) {
            const gameModel = Model.fromJson(Game, rows[i]);
            await gameModel.load(language);
            
            rows[i] = gameModel.response();
        }

        return new Page(rows, totalSize, pageNo, pageSize);
    }

    /** @returns {Promise<List<Game>>} */
    static async listPartyGames(language) {
        const rows = await MariaDB.executeQuery(`SELECT * FROM game WHERE partyEnabled=1`);
        for (let i = 0; i < rows.length; i++) {
            const game = Model.fromJson(Game, rows[i]);
            const gameDetailInfo = await Translator.get(LanguageKeys.TABLE_GAMES, game.getGameId(), language);
            
            rows[i] = {
                gameId: game.getGameId(),
                gameName: gameDetailInfo.gameName ?? game.getGameName()
            };
        }

        return rows;
    }

    /** @returns {Promise<Boolean>} */
    static async exists(gameId) {
        const game = await MariaDB.findFirst(`SELECT * FROM game WHERE gameId="${gameId}"`);
        return game != null;
    }

    async load(language) {
        const gameDetailInfo = await Translator.get(LanguageKeys.TABLE_GAMES, this.getGameId(), language);
        if (gameDetailInfo) {
            this.setGameName(gameDetailInfo.gameName);
        }
        
        const tagsInfo = await Translator.get(LanguageKeys.TABLE_GAMES, LanguageKeys.KEY_TAG, language);
        if (tagsInfo) {
            this.setGameTypes(
                this.getGameTypes().map(x => tagsInfo[x])
            );
        }

        const likeCount = await GameLike.getLikeCount(this.gameId);
        this.setLikeCount(likeCount);

        const playerCount = await Redis.getKeyScore(RedisKeys.GAME_PLAYER_COUNT, this.gameId) ?? 0;
        this.setPlayerCount(playerCount);
    }

    isExcluded() {
        return this.excludeGame != 0;
    }

    response() {
        return {
            gameId: this.gameId,
            gameTitle: this.gameName,
            gameCoverPic: AssetUtil.getGameCover(this.gameId),
            gameTypes: this.gameTypes,
            isShopOnline: this.shopEnabled,
            isRankOnline: this.rankEnabled,
            isOpenParty: this.partyEnabled,
            praiseNumber: this.likeCount,
            onlineNumber: this.playerCount,
            creationTime: this.creationTime
        };
    }

    setGameId(gameId) {
        this.gameId = gameId;
    }

    getGameId() {
        return this.gameId;
    }

    setGameName(gameName) {
        this.gameName = gameName;
    }

    getGameName() {
        return this.gameName;
    }

    setGameTypes(gameTypes) {
        this.gameTypes = gameTypes;
    }

    getGameTypes() {
        return this.gameTypes;
    }

    setLikeCount(likeCount) {
        this.likeCount = likeCount;
    }

    getLikeCount() {
        return this.likeCount;
    }

    setPlayerCount(playerCount) {
        this.playerCount = playerCount;
    }

    getPlayerCount() {
        return this.playerCount;
    }

    setShopEnabled(shopEnabled) {
        this.shopEnabled = shopEnabled;
    }

    getShopEnabled() {
        return this.shopEnabled;
    }

    setRankEnabled(rankEnabled) {
        this.rankEnabled = rankEnabled;
    }

    getRankEnabled() {
        return this.rankEnabled;
    }

    setPartyEnabled(partyEnabled) {
        this.partyEnabled = partyEnabled;
    }

    getPartyEnabled() {
        return this.partyEnabled;
    }

    setAuthorId(authorId) {
        this.authorId = authorId;
    }

    getAuthorId() {
        return this.authorId;
    }

    setCreationTime(creationTime) {
        this.creationTime = creationTime;
    }

    getCreationTime() {
        return this.creationTime;
    }
}