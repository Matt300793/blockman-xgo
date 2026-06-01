const Translator = require("@common/Translator");
const cdnConfig = require("@common-config/cdn");
const hostConfig = require("@common-config/host");
const LanguageKeys = require("@common-constants/LanguageKeys");
const Model = require("@common-models/Model");

module.exports = class GameDetail extends Model {
    constructor() {
        super();

        this.gameId = "";
        this.gameDetail = "";
        this.featuredPlay = [];
    }

    /** @returns {Promise<GameDetail>} */
    static async fromGameId(gameId, language) {
        const gameDetail = new GameDetail();
        gameDetail.setGameId(gameId);

        const gameDetailInfo = await Translator.get(LanguageKeys.TABLE_GAMES, gameId, language);
        if (gameDetailInfo) {
            gameDetail.setGameDetail(gameDetailInfo.gameDetail);
            gameDetail.setFeaturedPlay(gameDetailInfo.featuredPlay);
        }

        return gameDetail;
    }

    response() {
        return {
            gameId: this.gameId,
            bannerPic: [this.getBannerUrl()],
            gameDetail: this.gameDetail,
            featuredPlay: this.featuredPlay
        }
    }

    setGameId(gameId) {
        this.gameId = gameId;
    }

    getGameId() {
        return this.gameId;
    }

    setGameDetail(gameDetail) {
        this.gameDetail = gameDetail;
    }

    getGameDetail() {
        return this.gameDetail;
    }

    setFeaturedPlay(featuredPlay) {
        this.featuredPlay = featuredPlay;
    }

    getBannerUrl() {
        return `${hostConfig.cdnUrl}/${cdnConfig.gameBannerPath}/${this.gameId}.png`;
    }
}