require("module-alias/register");

const express = require("express");
const app = express();

const database = require("@common/database");
const dressing = require("@common/dressing");
// const redis = require("@common/redis");

const logger = require("@common/logger");

// prevent re-initializing on every request (important for serverless)
let initialized = false;

async function init() {
    if (initialized) return;

    database.init();
    dressing.init();
    // redis.init();

    // ❌ DO NOT run persistent systems on Vercel
    // require("@dispatcher/room")();

    initialized = true;
    logger.info("App initialized (serverless mode)");
}

// middleware
app.use(express.json());

app.use((req, res, next) => {
    res.setHeader("Connection", "keep-alive");
    next();
});

// routes
require("./router")(app);

// ❗ EXPORT instead of listen()
module.exports = async (req, res) => {
    try {
        await init();
        return app(req, res);
    } catch (err) {
        console.error(err);
        res.status(500).json({
            error: "Serverless crash",
            details: err.message
        });
    }
};
