const { createClient } = require('redis');

const redisUrl = process.env.REDIS_URL || '';

// Cleanly parse out the password in case the client misses it
const passwordMatch = redisUrl.match(/redis(?:s)?:\/\/(?:([^:]+)?):([^@]+)@/);
const redisPassword = passwordMatch ? passwordMatch[2] : undefined;

const client = createClient({
  url: redisUrl,
  password: redisPassword,
  socket: {
    // Crucial for Aiven: This handles the secure "rediss://" connection
    tls: redisUrl.startsWith('rediss://'), 
    rejectUnauthorized: false // Prevents self-signed certificate errors from blocking you
  }
});

client.on('error', (err) => {
  // Keeps your logs clean instead of crashing the whole server process
  console.error('Redis client error:', err.message);
});

// Connect to Redis/Valkey
(async () => {
  try {
    await client.connect();
    console.log('✅ Connected to Aiven Valkey/Redis successfully!');
  } catch (err) {
    console.error('❌ Failed to connect to Redis:', err.message);
  }
})();

module.exports = client;
