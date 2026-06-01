const Redis = require("@common/Redis");
const RedisKeys = require("@common/RedisKeys");
const Model = require("@common-models/Model");

module.exports = class GameLike extends Model {
    constructor(userId) {
        super();

        this.userId = userId;
        this.games = [];
    }

    static async fromUserId(userId) {
        const likedGames = JSON.parse(
            await Redis.getKey(RedisKeys.GAME_USER_LIKED, userId) ?? "[]"
        );

        const gameLikeModel = new GameLike(userId);
        gameLikeModel.setUserId(userId);
        gameLikeModel.setGames(likedGames);

        return gameLikeModel;
    }

    static async getLikeCount(gameId) {
        return await Redis.getKeyScore(RedisKeys.GAME_LIKE_COUNT, gameId) ?? 0;
    }

    static async addLike(gameId) {
        await Redis.incrementKeyScore(RedisKeys.GAME_LIKE_COUNT, gameId, 1);
    }

    addGame(gameId) {
        this.games.push(gameId);
    }

    async save() {
        await Redis.setKey({
            key: RedisKeys.GAME_USER_LIKED, params: [this.userId]
        }, JSON.stringify(this.games));
    }

    response(gameId) {
        return {
            appreciate: this.games.includes(gameId)
        }
    }

    setUserId(userId) {
        this.userId = userId;
    }

    getUserId() {
        return this.userId;
    }

    setGames(games) {
        this.games = games;
    }

    getGames() {
        return this.games;
    }
}