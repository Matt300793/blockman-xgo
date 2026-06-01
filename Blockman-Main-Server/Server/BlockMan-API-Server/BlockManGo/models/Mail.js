const MariaDB = require("@common/MariaDB");
const Model = require("@common-models/Model");
const MailAttachment = require("@common-models/MailAttachment");

module.exports = class Mail extends Model {
    constructor() {
        super();

        this.mailId = null;
        this.mailType = 0;
        this.title = "";
        this.content = "";
        this.attachments = [];
        this.extraContent = "";
        this.creationTime = 0;
        this.status = 0;
    }

    addAttachment(attachment) {
        this.attachments.push(attachment);
    }

    /** @returns {Promise<Mail>} */
    static async fromMailId(mailId) {
        const mail = await MariaDB.findFirst(`SELECT * FROM mailbox_data WHERE mailId=${mailId}`);
        if (mail) {
            const mailModel = Model.fromJson(Mail, mail);
            mailModel.setAttachments(
                mailModel.getAttachments().map(x => Model.fromJson(MailAttachment, x))
            );

            return mailModel;
        }

        return null;
    }

    response() {
        return {
            id: this.mailId,
            type: this.mailType,
            title: this.title,
            content: this.content,
            attachment: this.attachments.map(x => x.response()),
            extra: this.extraContent,
            sendDate: this.creationTime,
            status: this.status
        }
    }

    setMailId(mailId) {
        this.mailId = mailId;
    }
    
    getMailId() {
        return this.mailId;
    }

    setMailType(mailType) {
        this.mailType = mailType;
    }

    getMailType() {
        return this.mailType;
    }

    setTitle(title) {
        this.title = title;
    }

    getTitle() {
        return this.title;
    }

    setContent(content) {
        this.content = content;
    }

    getContent() {
        return this.content;
    }

    setAttachments(attachments) {
        this.attachments = attachments;
    }

    getAttachments() {
        return this.attachments;
    }

    setCreationTime(creationTime) {
        this.creationTime = creationTime;
    }

    getCreationTime() {
        return this.creationTime;
    }

    setExtraContent(extraContent) {
        this.extraContent = extraContent;
    }

    getExtraContent() {
        return this.extraContent;
    }

    setStatus(status) {
        this.status = status;
    }

    getStatus() {
        return this.status;
    }
}