const MailAttachmentTypes = require("@common-constants/MailAttachmentTypes");
const Model = require("@common-models/Model");

module.exports = class MailAttachment extends Model {
    constructor() {
        super();

        this.name = "";
        this.quantity = 0;
        this.icon = "";
        this.itemId = "";
        this.type = 0;

        this.vipLevel = 0;
        this.vipDays = 0;
    }

    /** @returns {MailAttachment} */
    static fromJson(json) {
        return super.fromJson(MailAttachment, json);
    }

    response() {
        switch (this.type) {
            case MailAttachmentTypes.CURRENCY:
                return { name: this.name, icon: this.icon, type: this.type, itemId: this.itemId, qty: this.quantity };
            case MailAttachmentTypes.DRESS:
                return { name: this.name, icon: this.icon, type: this.type, itemId: this.itemId };
            case MailAttachmentTypes.VIP:
                return { name: this.name, icon: this.icon, type: this.type, vipLevel: this.vipLevel, vipDays: this.vipDays };
        }

        return this;
    }

    setName(name) {
        this.name = name;
    }
    
    getName() {
        return this.name;
    }

    setQuantity(quantity) {
        this.quantity = quantity;
    }

    getQuantity() {
        return this.quantity;
    }

    setIcon(icon) {
        this.icon = icon;
    }

    getIcon() {
        return this.icon;
    }

    setItemId(itemId) {
        this.itemId = itemId;
    }

    getItemId() {
        return this.itemId;
    }

    setType(type) {
        this.type = type;
    }

    getType() {
        return this.type;
    }

    setVipLevel(vipLevel) {
        this.vipLevel = vipLevel;
    }

    getVipLevel() {
        return this.vipLevel;
    }

    setVipDays(vipDays) {
        this.vipDays = vipDays;
    }

    getVipDays() {
        return this.vipDays;
    }
}