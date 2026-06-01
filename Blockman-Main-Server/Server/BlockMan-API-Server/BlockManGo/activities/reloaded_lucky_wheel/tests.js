const handler = require("./activity");

const allWheelRewardsConfig = require("./rewards.json");
const rewardConfig = allWheelRewardsConfig["gold"]["rewardConfig"];

function performTest() {
    const table = {};
    for (let i = 0; i < 100; i++) {
        const item = handler.selectByWeight(rewardConfig);
        if (!table[item.rewardId]) {
            table[item.rewardId] = 0;
        }

        table[item.rewardId]++;
    }
    return table;
}

const util = require('util');

function horizontal(obj) {
    const inspectOptions = {
        colors: true,
        depth: null
    };
    const formatted = util.inspect(obj, inspectOptions);
    return formatted.replace(/\n\s*/g, '');
}

for (let i = 0; i < 10; i++) {
    console.log(horizontal(
        performTest()
    ));
}
