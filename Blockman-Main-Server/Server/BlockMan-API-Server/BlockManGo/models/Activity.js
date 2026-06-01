module.exports = class Activity {
    constructor() {
        this.startTime = 0;
        this.endTime = 0;
        this.type = "";
        this.name = "";
        this.handler = null;
    }

    setStartTime(startTime) {
        this.startTime = startTime;
    }

    getStartTime() {
        return this.startTime;
    }

    setEndTime(endTime) {
        this.endTime = endTime;
    }

    getEndTime() {
        return this.endTime;
    }

    setType(type) {
        this.type = type;
    }

    getType() {
        return this.type;
    }

    setName(name) {
        this.name = name;
    }

    getName() {
        return this.name;
    }

    setHandler(handler) {
        this.handler = handler;
    }

    getHandler() {
        return this.handler;
    }
}