const ActivityLoginStatuses = require("../../constants/ActivityLoginStatuses");
const Currencies = require("../../constants/Currencies");
const Genders = require("../../constants/Genders");
const RewardTypes = require("../../constants/RewardTypes");
const rewardsConfig = require("./rewards.json");
const ERROR_ALREADY_CLAIMED = 1;

async function getInfo(userId) {
    const currentDay = await Redis.getKey(RedisKeys.CACHE_ACTIVITY_LOGIN, userId) || 0;
    const hasClaimed = await Redis.getKey(RedisKeys.CACHE_ACTIVITY_LOGIN_HAS_CLAIMED, userId);
    
    const rewards = await getRewardListByUser(userId);
    for (let i = 0; i < rewards.length; i++) {
        if (currentDay > i) {
            rewards[i].status = ActivityLoginStatuses.CLAIMED;
        }
    }

    return {
        signInStatus: currentDay >= rewardsConfig.length ? ActivityLoginStatuses.FINISHED : (hasClaimed ? ActivityLoginStatuses.CLAIMED : ActivityLoginStatuses.NOT_CLAIMED),
        userSignInList: rewards
    }
}

async function claimReward(userId) {
    const currentDay = await Redis.getKey(RedisKeys.CACHE_ACTIVITY_LOGIN, userId) || 0;
    const hasClaimed = await Redis.getKey(RedisKeys.CACHE_ACTIVITY_LOGIN_HAS_CLAIMED, userId);

    const claimStatus = currentDay >= rewardsConfig.length ? ActivityLoginStatuses.FINISHED : (hasClaimed ? ActivityLoginStatuses.CLAIMED : ActivityLoginStatuses.NOT_CLAIMED);
    if (claimStatus > 0) {
        return { code: ERROR_ALREADY_CLAIMED };
    }

    const rewardList = await getRewardListByUser(userId);
    const rewardInfo = rewardList[currentDay];

    for (let i = 0; i < rewardInfo.rewards.length; i++) {
        const reward = rewardInfo.rewards[i];
        switch (reward.rewardType) {
            case RewardTypes.VIP:
                await UserService.addVip(userId, reward.level, reward.quantity);
                break;
            case RewardTypes.DRESS:
                const dresses = await DecorationService.getOwnedDresses(userId);
                if (!dresses.includes(reward.rewardId)) {
                    await DecorationService.addDresses(userId, [reward.rewardId]);
                }
                break;
            case RewardTypes.DIAMOND:
                await PayService.addCurrency(userId, Currencies.DIAMOND, reward.quantity);
                break;
            case RewardTypes.GOLD:
                await PayService.addCurrency(userId, Currencies.GOLD, reward.quantity);
                break;
        }
    }

    await Redis.setKey({
        key: RedisKeys.CACHE_ACTIVITY_LOGIN, params: [userId]
    }, currentDay + 1);

    // await Redis.setKey({
    //     key: RedisKeys.CACHE_ACTIVITY_LOGIN_HAS_CLAIMED, params: [userId]
    // }, "1", ServerTime.getTodayTimeLeft());

    return {
        signInId: currentDay + 1 // Zero-based
    };
}

async function getRewardListByUser(userId) {
    const user = await User.fromUserId(userId);

    // Without structureClone the statements below would have modified the items of `rewardsConfig`
    // `rewardList` would have only stored the references of the items instead of copying
    const rewardList = structuredClone(rewardsConfig);
    for (let i = 0; i < rewardList.length; i++) {
        if (!rewardList[i].rewards) {
            rewardList[i].rewards = rewardList[i][`rewardList_${user.getSex()}`]; 

            delete rewardList[i][`rewardList_${Genders.BOY}`];
            delete rewardList[i][`rewardList_${Genders.GIRL}`];
        }
    }

    return rewardList;
}

module.exports = {
    ERROR_ALREADY_CLAIMED: ERROR_ALREADY_CLAIMED,

    getInfo: getInfo,
    claimReward: claimReward
}