const MariaDB = require("@common/MariaDB");
const Model = require("@common-models/Model");

module.exports = class MailRecord extends Model {
    constructor() {
        super();

        this.mailId = 0;
        this.status = 0;
    }

    /** @returns {Promise<MailRecord[]>} */
    static async fromUserId(userId, excludeStatuses) {
        const userRecords = Object.entries(
            await MariaDB.findFirst(`SELECT * FROM mailbox_record WHERE userId=${userId}`, "data", {})
        ).map(x => MailRecord.fromJson(x)).filter(x => x != null);

        const systemRecords = Object.entries(
            await MariaDB.findFirst(`SELECT * FROM mailbox_record WHERE userId=0`, "data", {})
        ).map(x => MailRecord.fromJson(x)).filter(x => x != null);

        for (let i = 0; i < systemRecords.length; i++) {
            let hasSystemMail = false;
            for (let j = 0; j < userRecords.length; j++) {
                if (userRecords[j].getMailId() == systemRecords[i].getMailId()) {
                    hasSystemMail = true;
                    break;
                }
            }

            if (!hasSystemMail) {
                userRecords.push(systemRecords[i]);
            }
        }

        if (Array.isArray(excludeStatuses)) {
            return userRecords.filter(x => !excludeStatuses.includes(x.status))
                              .map(x => super.fromJson(MailRecord, x));
        }
        
        return userRecords.map(x => super.fromJson(MailRecord, x));
    }

    static async save(userId, records) {
        await MariaDB.addOrUpdateJsonObject("mailbox_record", userId, records);
    }

    static fromJson(data) {
        const record = new MailRecord();
        record.setMailId(parseInt(data[0]));
        record.setStatus(data[1]);

        return record;
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