const Redis = require("@common/Redis");
const RedisKeys = require("@common/RedisKeys");
const ServerTime = require("@common/ServerTime");
const Translator = require("@common/Translator");
const clanConfig = require("@common-config/clan");
const LanguageKeys = require("@common-constants/LanguageKeys");
const ClanTaskTypes = require("@common-constants/ClanTaskTypes");
const ClanTaskStatuses = require("@common/constants/ClanTaskStatuses");
const Model = require("@common-models/Model");

module.exports = class ClanTask extends Model {
    constructor() {
        super();

        this.id = 0;
        this.taskId = 0;
        this.taskName = "";
        this.currencyReward = 0;
        this.experienceReward = 0;
        this.level = "";
        this.targetGame = "";
        this.targetMetrics = "";
        this.targetCount = 0;
        this.progress = 0;
        this.status = 0;
    }

    async save(masterId, taskType, taskIdx) {
        const cacheKey = taskType == ClanTaskTypes.PERSONAL ? RedisKeys.CACHE_PERSONAL_CLAN_TASK : RedisKeys.CACHE_CLANWIDE_CLAN_TASK;
        await Redis.setKey({
            key: cacheKey, params: [masterId, taskIdx]
        }, `${this.taskId},${this.progress},${this.status}`, ServerTime.getTodayTimeLeft());
    }

    static async getFinishedTaskCount(userId, clanId) {
        let count = 0;

        for (let taskIdx = 1; taskIdx <= clanConfig.maxClanTasks; taskIdx++) {
            const task = await this.getTaskFromRedis(clanId, ClanTaskTypes.CLANWIDE, taskIdx);
            if (task.status > ClanTaskStatuses.RUNNING) 
                count++;
        }

        for (let taskIdx = 1; taskIdx <= clanConfig.maxPersonalTasks; taskIdx++) {
            const task = await this.getTaskFromRedis(userId, ClanTaskTypes.PERSONAL, taskIdx);
            if (task.status > ClanTaskStatuses.RUNNING) 
                count++;
        }

        return count;
    }

    /** @returns {Promise<Object>} */
    static async getTaskFromRedis(masterId, taskType, taskIdx) {
    const cacheKey = taskType == ClanTaskTypes.PERSONAL
        ? RedisKeys.CACHE_PERSONAL_CLAN_TASK
        : RedisKeys.CACHE_CLANWIDE_CLAN_TASK;

    const taskInfo = await Redis.getKey(cacheKey, masterId, taskIdx); // ID,Progress,Status

    if (!taskInfo) {
        console.warn(`No Redis data for cacheKey=${cacheKey}, masterId=${masterId}, taskIdx=${taskIdx}`);
        return null;  // Or you can throw an Error depending on your needs
    }

    const splitTaskInfo = taskInfo.split(',');

    return {
        id: parseInt(splitTaskInfo[0], 10),
        progress: parseInt(splitTaskInfo[1], 10),
        status: parseInt(splitTaskInfo[2], 10)
    };
}

    /** @returns {Promise<ClanTask>} */
    static async getPersonalTask(userId, taskIdx, clanLevel, language) {
        const clanLevelConfig = clanConfig.levels[clanLevel];
        const clanTaskNames = await Translator.get(LanguageKeys.TABLE_CLAN, LanguageKeys.KEY_TASKS, language);

        const taskInfo = await this.getTaskFromRedis(userId, ClanTaskTypes.PERSONAL, taskIdx);
        const taskConfig = clanConfig.personalTasks[taskInfo.id];
        
        const clanTask = new ClanTask();
        clanTask.setId(taskIdx);
        clanTask.setTaskId(taskInfo.id);
        clanTask.setTaskName(clanTaskNames[taskInfo.id]);
        clanTask.setCurrencyReward(clanLevelConfig.taskCompletedCurrencyReward * taskConfig.currencyRate);
        clanTask.setExperienceReward(clanLevelConfig.taskCompletedExperienceReward * taskConfig.experienceRate);
        clanTask.setLevel(taskConfig.level);
        clanTask.setTargetGame(taskConfig.game);
        clanTask.setTargetMetrics(taskConfig.type);
        clanTask.setTargetCount(taskConfig.value);
        clanTask.setProgress(taskInfo.progress);
        clanTask.setStatus(taskInfo.status);

        return clanTask;
    }

    /** @returns {Promise<ClanTask>} */
    static async getSpecialPersonalTask(userId, clanLevel, language) {
        let completedTasks = 0;
        for (let taskIdx = 1; taskIdx <= clanConfig.maxPersonalTasks; taskIdx++) {
            const taskInfo = await this.getTaskFromRedis(userId, ClanTaskTypes.PERSONAL, taskIdx);
            if (taskInfo.status > ClanTaskStatuses.RUNNING)
                completedTasks++;
        }

        const hasClaimedReward = await Redis.getKey(RedisKeys.CACHE_PERSONAL_CLAN_SPECIAL_TASK, userId);
        const isTaskCompleted = completedTasks == clanConfig.maxPersonalTasks;

        const clanLevelConfig = clanConfig.levels[clanLevel];
        const clanTaskNames = await Translator.get(LanguageKeys.TABLE_CLAN, LanguageKeys.KEY_TASKS, language);

        const taskConfig = clanConfig.personalTasks[clanConfig.specialPersonalTask];
        
        const clanTask = new ClanTask();
        clanTask.setTaskId(taskConfig.taskId);
        clanTask.setTaskName(clanTaskNames[taskConfig.taskId]);
        clanTask.setCurrencyReward(clanLevelConfig.taskCompletedCurrencyReward * taskConfig.currencyRate);
        clanTask.setExperienceReward(clanLevelConfig.taskCompletedExperienceReward * taskConfig.experienceRate);
        clanTask.setLevel(taskConfig.level);
        clanTask.setTargetCount(clanConfig.maxPersonalTasks);
        clanTask.setProgress(completedTasks);
        clanTask.setStatus(isTaskCompleted ? (hasClaimedReward ? ClanTaskStatuses.CLAIMED : ClanTaskStatuses.FINISHED) : ClanTaskStatuses.RUNNING);

        return clanTask;
    }

    /** @returns {Promise<ClanTask>} */
    static async getClanwideTask(userId, clanId, taskIdx, clanLevel, language) {
        const clanLevelConfig = clanConfig.levels[clanLevel];
        const clanTaskNames = await Translator.get(LanguageKeys.TABLE_CLAN, LanguageKeys.KEY_TASKS, language);

        const taskInfo = await this.getTaskFromRedis(clanId, ClanTaskTypes.CLANWIDE, taskIdx);
        const taskConfig = clanConfig.clanTasks[taskInfo.id];
        
        const clanTask = new ClanTask();
        clanTask.setId(taskIdx);
        clanTask.setTaskId(taskInfo.id);
        clanTask.setTaskName(clanTaskNames[taskInfo.id]);
        clanTask.setCurrencyReward(clanLevelConfig.taskCompletedCurrencyReward * taskConfig.currencyRate);
        clanTask.setExperienceReward(clanLevelConfig.taskCompletedExperienceReward * taskConfig.experienceRate);
        clanTask.setLevel(taskConfig.level);
        clanTask.setTargetGame(taskConfig.game);
        clanTask.setTargetMetrics(taskConfig.type);
        clanTask.setTargetCount(taskConfig.value);
        clanTask.setProgress(taskInfo.Progress);

        const isTaskClaimed = await Redis.getKey(RedisKeys.CACHE_CLANWIDE_USER_CLAIM_TASK, userId, taskIdx);
        clanTask.setStatus(isTaskClaimed ? ClanTaskStatuses.CLAIMED : taskInfo.status);

        return clanTask;
    }

    static async isRefreshAvailable(masterId, taskType) {
    const maxTasks = taskType == ClanTaskTypes.PERSONAL ? clanConfig.maxPersonalTasks : clanConfig.maxClanTasks;

    let acceptedTasks = 0;
    for (let taskIdx = 1; taskIdx <= maxTasks; taskIdx++) {
        const taskInfo = await this.getTaskFromRedis(masterId, taskType, taskIdx);

        if (!taskInfo) {
            // If there's no task at all, skip it
            continue;
        }

        if (taskInfo.status != ClanTaskStatuses.ACCEPT) {
            acceptedTasks++;
        }
    }

    return maxTasks > acceptedTasks;
}

    /** @returns {Promise<boolean>} */
    static async hasTasks(masterId, taskType) {
        const cacheKey = taskType == ClanTaskTypes.PERSONAL ? RedisKeys.CACHE_PERSONAL_CLAN_TASK : RedisKeys.CACHE_CLANWIDE_CLAN_TASK;
        return await Redis.getKey(cacheKey, masterId, 1);
    }

    /** @returns {Promise<ClanTask[]>} */
    static async getTasks(userId, clanId, taskType, clanLevel, language) {
        const tasks = [];

        const maxTasks = taskType == ClanTaskTypes.PERSONAL ? clanConfig.maxPersonalTasks : clanConfig.maxClanTasks;
        for (let taskIdx = 1; taskIdx <= maxTasks; taskIdx++) {
            switch (taskType) {
                case ClanTaskTypes.PERSONAL:
                    tasks.push(await this.getPersonalTask(userId, taskIdx, clanLevel, language));
                    break;
                case ClanTaskTypes.CLANWIDE:
                    tasks.push(await this.getClanwideTask(userId, clanId, taskIdx, clanLevel, language));
                    break;
            }
        }

        return tasks;
    }

    static async refreshTasks(masterId, taskType) {
        const allTaskConfig = taskType == ClanTaskTypes.PERSONAL ? clanConfig.personalTasks : clanConfig.clanTasks;
        const maxTasks = taskType == ClanTaskTypes.PERSONAL ? clanConfig.maxPersonalTasks : clanConfig.maxClanTasks;
        const cacheKey = taskType == ClanTaskTypes.PERSONAL ? RedisKeys.CACHE_PERSONAL_CLAN_TASK : RedisKeys.CACHE_CLANWIDE_CLAN_TASK;

        const clanTaskIds = Object.keys(allTaskConfig);
        const clanTasks = Object.values(allTaskConfig);
        for (let taskIdx = 1; taskIdx <= maxTasks; taskIdx++) {
            const taskInfo = await this.getTaskFromRedis(masterId, taskType, taskIdx);
            if (taskInfo.status > ClanTaskStatuses.ACCEPT)
                continue;

            const freshTaskId = clanTasks.indexOf(this.selectByWeight(clanTasks));
            await Redis.setKey({
                key: cacheKey, params: [masterId, taskIdx]
            }, `${clanTaskIds[freshTaskId]},0,0`, ServerTime.getTodayTimeLeft());
        }
    }

    static selectByWeight(items) {
        const totalWeight = items.reduce((acc, val) => acc + val.weight, 0);
        const randomNumber = Math.random() * totalWeight;
    
        let cumulativeWeight = 0;
        for (let i = 0; i < items.length; i++) {
            cumulativeWeight += items[i].weight;
            if (randomNumber <= cumulativeWeight) {
                return items[i];
            }
        }
    }

    response() {
        return {
            id: this.id,
            taskId: this.taskId,
            name: this.taskName,
            type: this.level,
            currencyReward: this.currencyReward,
            experienceReward: this.experienceReward,
            need: this.targetCount,
            finished: this.progress,
            status: this.status
        }
    }

    setId(id) {
        this.id = id;
    }

    getId() {
        return this.id;
    }

    setTaskId(taskId) {
        this.taskId = taskId;
    }

    getTaskId() {
        return this.taskId;
    }

    setTaskName(taskName) {
        this.taskName = taskName;
    }

    getTaskName() {
        return this.taskName;
    }

    setCurrencyReward(currencyReward) {
        this.currencyReward = currencyReward;
    }

    getCurrencyReward() {
        return this.currencyReward;
    }

    setExperienceReward(experienceReward) {
        this.experienceReward = experienceReward;
    }

    getExperienceReward() {
        return this.experienceReward;
    }

    setLevel(level) {
        this.level = level;
    }
    
    getLevel() {
        return this.level;
    }

    setTargetGame(targetGame) {
        this.targetGame = targetGame;
    }

    getTargetGame() {
        return this.targetGame;
    }

    setTargetMetrics(targetMetrics) {
        this.targetMetrics = targetMetrics;
    }

    getTargetMetrics() {
        return this.targetMetrics;
    }

    setTargetCount(targetCount) {
        this.targetCount = targetCount;
    }

    getTargetCount() {
        return this.targetCount;
    }

    setProgress(progress) {
        this.progress = progress;
    }
    
    getProgress() {
        return this.progress;
    }

    setStatus(status) {
        this.status = status;
    }

    getStatus() {
        return this.status;
    }
}