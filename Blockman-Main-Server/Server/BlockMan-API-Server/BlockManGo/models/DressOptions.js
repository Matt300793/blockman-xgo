module.exports = class DressOptions {
    constructor(options) {
        this.categoryId = options.categoryId;
        this.sex = options.sex;
        this.vip = options.vip;
        this.currency = options.currency;
        this.showShopOnly = options.showShopOnly;
        this.ownedDresses = options.ownedDresses;
        this.ownerType = options.ownerType;
        this.equippedDresses = options.equippedDresses;
    }

    // Owner Types
    // 1 - STRICT: Strictly filters dresses from the ownerFilter array (No other dresses will be filtered regardless of the options)
    // 2 - TAG_ITEM: Tags dresses from the ownerFilter array with the 'hasPurchases' property set to 1

    setCategoryId(categoryId) {
        this.categoryId = categoryId;
    }

    getCategoryId() {
        return this.categoryId;
    }

    setSex(sex) {
        this.sex = sex;
    }

    getSex() {
        return this.sex;
    }

    setCurrency(currency) {
        this.currency = currency;
    }

    getCurrency() {
        return this.currency;
    }

    setHideClanDresses(hideClanDresses) {
        this.hideClanDresses = hideClanDresses;
    }

    getHideClanDresses() {
        return this.hideClanDresses;
    }

    setHideFreeDresses(hideFreeDresses) {
        this.hideFreeDresses = hideFreeDresses;
    }

    getHideFreeDresses() {
        return this.hideFreeDresses;
    }

    setOwnedDresses(ownedDresses) {
        this.ownedDresses = ownedDresses;
    }

    getOwnedDresses() {
        return this.ownedDresses;
    }

    setEquippedDresses(equippedDresses) {
        this.equippedDresses = equippedDresses;
    }

    getEquippedDresses() {
        return this.equipppedDresses;
    }
}
