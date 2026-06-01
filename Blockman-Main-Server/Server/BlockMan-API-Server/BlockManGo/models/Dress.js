const Model = require("@common-models/Model");

module.exports = class Dress extends Model {
    constructor() {
        super();

        this.id = 0;
        this.typeId = 0;
        this.iconUrl = "";
        this.sex = 0;
        this.resourceId = "";
        this.price = 0;
        this.currency = 0;
        this.clanLevel = 0;
        this.vip = 0;
        this.inShop = false;
    }

    static fromJson(json) {
        return super.fromJson(Dress, json);
    }

    isFree() {
        return this.currency == 0 && this.price == 0 && this.vip == 0;
    }

    setDressId(dressId) {
        this.id = dressId;
    }

    getDressId() {
        return this.id;
    }

    setTypeId(typeId) {
        this.typeId = typeId;
    }

    getTypeId() {
        return this.typeId;
    }

    setIconUrl(iconUrl) {
        this.iconUrl = iconUrl;
    }

    getIconUrl() {
        return this.iconUrl;
    }

    setSex(sex) {
        this.sex = sex;
    }

    getSex() {
        return this.sex;
    }

    setResourceId(resourceId) {
        this.resourceId = resourceId;
    }

    getResourceId() {
        return this.resourceId;
    }

    setPrice(price) {
        this.price = price;
    }

    getPrice() {
        return this.price;
    }

    setCurrency(currency) {
        this.currency = currency;
    }

    getCurrency() {
        return this.currency;
    }

    setClanLevel(clanLevel) {
        this.clanLevel = clanLevel;
    }

    getClanLevel() {
        return this.clanLevel;
    }

    setVipLevel(vip) {
        this.vip = vip;
    }

    getVipLevel() {
        return this.vip;
    }

    setInShop(inShop) {
        this.inShop = inShop;
    }

    getInShop() {
        return this.inShop;
    }
}