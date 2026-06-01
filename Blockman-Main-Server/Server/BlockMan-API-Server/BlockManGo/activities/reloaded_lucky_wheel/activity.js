const Redis = require("@common/Redis");
const RedisKeys = require("@common/RedisKeys");
const ServerTime = require("@common/ServerTime");
const Currencies = require("@common-constants/Currencies");
const RewardTypes = require("@common-constants/RewardTypes");
const WheelTypes = require("@common-constants/WheelTypes");
const User = require("@common-models/User");
const DecorationService = require("@decoration-service/base");
const PayService = require("@pay-service/base");
const UserService = require("@user-service/base");

const allWheelConfig = require("./config.json");
const allWheelRewardsConfig = require("./rewards.json");
const allWheelShopConfig = require("./shop.json");

const ERROR_REWARD_NOT_EXISTS = 1;
const ERROR_NOT_ENOUGH_BLOCKS = 2;
const ERRROR_ALREADY_OWNED = 3;

async function getInfo(userId, type) {
    const user = await User.fromUserId(userId);

    const activityInfo = { ...allWheelConfig[type] };
    
    const freeWheel = await Redis.getKey(RedisKeys.CACHE_ACTIVITY_FREE_WHEEL, userId);
    const nextFreeWheel = await Redis.getExpire(RedisKeys.CACHE_ACTIVITY_FREE_WHEEL, userId);

    activityInfo.activityDesc = allWheelConfig.activityDesc;
    activityInfo.rewardInfoList = allWheelRewardsConfig[type][`rewardInfoList_${user.getSex()}`];

    activityInfo.seconds = (type != WheelTypes.DIAMOND ? nextFreeWheel : 0);
    activityInfo.isFree = (freeWheel == null && type != WheelTypes.DIAMOND ? 1 : 0);
    
    activityInfo.luckyValue = parseInt(
        await Redis.getKey(RedisKeys.CACHE_ACTIVITY_WHEEL_LUCK, type, userId)
    ) || 0;

    const goldBlocks = parseInt(
        await Redis.getKey(RedisKeys.CACHE_ACTIVITY_WHEEL_CURRENCY, WheelTypes.GOLD, userId)
    ) || 0;

    const diamondBlocks = parseInt(
        await Redis.getKey(RedisKeys.CACHE_ACTIVITY_WHEEL_CURRENCY, WheelTypes.DIAMOND, userId)
    ) || 0;

    activityInfo.totalBlock = goldBlocks + diamondBlocks;

    return activityInfo;
}

async function getFreeWheelStatus(userId) {
    const freeWheel = await Redis.getKey(RedisKeys.CACHE_ACTIVITY_FREE_WHEEL, userId);
    return { isFree: freeWheel == null ? 1 : 0 };
}

async function getShopInfo(userId, type) {
    const user = await User.fromUserId(userId);
    const shopData = allWheelShopConfig[type][`shop_${user.getSex()}`];

    const blockWealth = parseInt(
        await Redis.getKey(RedisKeys.CACHE_ACTIVITY_WHEEL_CURRENCY, type, userId)
    ) || 0;

    return { userBlock: blockWealth, remainingTime: allWheelConfig.remainingTime, blockShopRewardInfoList: shopData };
}

function selectByWeight(items) {
    const totalWeight = items.reduce((acc, val) => acc + val.weight, 0);

    const randomNumber = Math.random() * totalWeight;

    let cumulativeWeight = 0;
    for (const item of items) {
        cumulativeWeight += item.weight;
        if (randomNumber <= cumulativeWeight) {
            return item;
        }
    }
}

async function spinWheel(userId, type, userLuckyValue) {
    const wheelConfig = allWheelConfig[type];
    const rewardConfig = allWheelRewardsConfig[type]["rewardConfig"];
    
    const user = await User.fromUserId(userId);
    
    const luckyValueLimit = wheelConfig.luckyValueUpperLimit;
    if (userLuckyValue >= luckyValueLimit) {
        const blockWealth = parseInt(
            await Redis.getKey(RedisKeys.CACHE_ACTIVITY_WHEEL_CURRENCY, type, userId)
        ) || 0;

        await Redis.setKey({
            key: RedisKeys.CACHE_ACTIVITY_WHEEL_CURRENCY, params: [type, userId]
        }, blockWealth + 1);

        const itemInfo = allWheelRewardsConfig[type][`rewardInfoList_${user.getSex()}`].find(x => x.rewardType == RewardTypes.BLOCK);
        return { ...itemInfo, luckValue: -luckyValueLimit };
    }

    const item = selectByWeight(rewardConfig);
    const itemInfo = allWheelRewardsConfig[type][`rewardInfoList_${user.getSex()}`].find(x => x.rewardId == item.rewardId);
    
    const spinData = { ...itemInfo };
    let luckValue = wheelConfig.oneIncreaseValue;

    switch (itemInfo.rewardType) {
        case RewardTypes.BLOCK:
            const blockWealth = parseInt(
                await Redis.getKey(RedisKeys.CACHE_ACTIVITY_WHEEL_CURRENCY, type, userId)
            ) || 0;
    
            await Redis.setKey({
                key: RedisKeys.CACHE_ACTIVITY_WHEEL_CURRENCY, params: [type, userId]
            }, blockWealth + 1);
            break;
        case RewardTypes.DIAMOND:
            await PayService.addCurrency(userId, Currencies.DIAMOND, item.rewardQty);
            break;
        case RewardTypes.GOLD:
            await PayService.addCurrency(userId, Currencies.GOLD, item.rewardQty);
            break;
        case RewardTypes.VIP:
            const { before, now } = await UserService.addVip(userId, item.rewardVipLevel, item.rewardVipDays);
            if (before.getLevel() > 0) {
                spinData.isTransform = 1;
                spinData.before = before.asReward();
                spinData.now = now.asReward();
            }
            break;
        case RewardTypes.DRESS:
            const dressId = item[`rewardDressId_${user.getSex()}`];
            const dresses = await DecorationService.getOwnedDresses(userId);
            if (dresses.includes(dressId)) {
                luckValue += item.luckValue;
                
                spinData.isTransform = 1;
                spinData.luckyValue = item.luckValue;
            } else {
                await DecorationService.addDresses(userId, [dressId]);
            }
            break;
    }

    spinData.luckValue = luckValue;
    return spinData;
}

async function playWheel(userId, type, isMultiSpins) {
    const wheelConfig = allWheelConfig[type];

    const freeWheel = await Redis.getKey(RedisKeys.CACHE_ACTIVITY_FREE_WHEEL, userId);
    if (!freeWheel && type == WheelTypes.GOLD && !isMultiSpins) {
        await Redis.setKey({
            key: RedisKeys.CACHE_ACTIVITY_FREE_WHEEL, params: [userId] 
        }, "1", ServerTime.getTodayTimeLeft());
    }

    const priceType = (type == WheelTypes.GOLD ? Currencies.GOLD : Currencies.DIAMOND);
    const price = (isMultiSpins ? wheelConfig.multiQuantity : (freeWheel == null && type == WheelTypes.GOLD) ? 0 : wheelConfig.singleQuantity);
    
    const { hasFailed } = await PayService.removeCurrency(userId, priceType, price);
    if (hasFailed) {
        return null;
    }

    let userLuckyValue = parseInt(
        await Redis.getKey(RedisKeys.CACHE_ACTIVITY_WHEEL_LUCK, type, userId)
    ) || 0;

    if (isMultiSpins) {
        const multiplayInfo = { userLuckyValue, drawList: [] };
        for (let i = 0; i < wheelConfig.drawRewardCount; i++) {
            const playInfo = await spinWheel(userId, type, userLuckyValue);
            userLuckyValue += playInfo.luckValue;
            multiplayInfo.drawList.push(playInfo);
        }
  
        await Redis.setKey({
            key: RedisKeys.CACHE_ACTIVITY_WHEEL_LUCK,
            params: [type, userId]
        }, userLuckyValue);

        return { ...multiplayInfo, userLuckyValue };
    }
    
    const playInfo = await spinWheel(userId, type, userLuckyValue);
    userLuckyValue += playInfo.luckValue;

    await Redis.setKey({
        key: RedisKeys.CACHE_ACTIVITY_WHEEL_LUCK,
        params: [type, userId]
    }, userLuckyValue);

    return { ...playInfo, userLuckyValue };
}

async function exchangeBlock(userId, type, rewardId) {
    const rewardConfig = allWheelShopConfig[type]["shopConfig"];

    const blockWealth = parseInt(
        await Redis.getKey(RedisKeys.CACHE_ACTIVITY_WHEEL_CURRENCY, type, userId)
    ) || 0;

    const user = await User.fromUserId(userId);

    const item = rewardConfig.find(x => x.rewardId == rewardId);
    if (!item) {
        return { code: ERROR_REWARD_NOT_EXISTS  };
    }

    const itemInfo = allWheelShopConfig[type][`shop_${user.getSex()}`].find(x => x.rewardId == rewardId);

    if (blockWealth < itemInfo.needBlock) {
        return { code: ERROR_NOT_ENOUGH_BLOCKS };
    }

    const exchangeData = { ...itemInfo, userBlock: blockWealth };

    switch (itemInfo.rewardType) {
        case RewardTypes.VIP:
            await UserService.addVip(userId, item.vipLevel, item.vipDays);
            break;
        case RewardTypes.DRESS:
            const dressId = item[`dressId_${user.getSex()}`];
            const dresses = await DecorationService.getOwnedDresses(userId);
            if (dresses.includes(dressId)) {
                return { code: ERRROR_ALREADY_OWNED };
            }

            await DecorationService.addDresses(userId, [dressId]);
            break;
    }

    exchangeData.userBlock -= itemInfo.needBlock;

    await Redis.setKey({
        key: RedisKeys.CACHE_ACTIVITY_WHEEL_CURRENCY,
        params: [type, userId]
    }, exchangeData.userBlock);

    return exchangeData;
}

module.exports = {
    ERROR_REWARD_NOT_EXISTS: ERROR_REWARD_NOT_EXISTS,
    ERROR_NOT_ENOUGH_BLOCKS: ERROR_NOT_ENOUGH_BLOCKS,
    ERRROR_ALREADY_OWNED: ERRROR_ALREADY_OWNED,

    getInfo: getInfo,
    getFreeWheelStatus: getFreeWheelStatus,
    getShopInfo: getShopInfo,
    playWheel: playWheel,
    exchangeBlock: exchangeBlock,

    // Tests
    selectByWeight: selectByWeight
}