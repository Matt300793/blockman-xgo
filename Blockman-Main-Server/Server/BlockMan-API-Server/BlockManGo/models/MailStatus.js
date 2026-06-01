const Model = require("@common-models/Model");

module.exports = class MailStatus extends Model {
    constructor(mailId, status) {
        super();

        this.mailId = mailId ?? 0;
        this.status = status ?? 0;
    }

    response() {
        return { [this.mailId]: this.status };
    }

    setMailId(mailId) {
        this.mailId = mailId;
    }
    
    getMailId() {
        return this.mailId;
    }

    setStatus(status) {
        this.status = status;
    }

    getStatus() {
        return this.status;
    }
}