const logger = require("../logger");
const activityListConfig = require("../config/activities");
const Activity = require("../models/Activity");

const activities = {};

function init() {
    for (let i = 0; i < activityListConfig.length; i++) {
        try {
            //require(`@activities/${activityListConfig[i]}/tests`);
            
            const activityConfig = require(`../activities/${activityListConfig[i]}/config.json`);
            const activityHandler = require(`../activities/${activityListConfig[i]}/activity`);
            
            const activity = new Activity();
            activity.setName(activityConfig.name);
            activity.setType(activityConfig.type);
            activity.setStartTime(activityConfig.startTime);
            activity.setEndTime(activityConfig.endTime);
            activity.setHandler(activityHandler);
            
            activities[activityListConfig[i]] = activity;

            logger.info(`Activity Manager: loaded activity '${activity.getName()}'`);
        } catch (err) {
            logger.error(`Activity (config or handler) is likely missing (${activityListConfig[i]})`);
            logger.error(err);
        }
    }
}

/** @returns {Activity} */
function getActivity(name, type) {
    if (!activities[name]) {
        return null;
    }

    const activity = activities[name];
    if (type && activity.getType() != type) {
        return null;
    }

    return activity;
}

module.exports = {
    init: init,
    getActivity: getActivity
}