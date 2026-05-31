const { createClient } = require('redis');
const { REDIS_URL } = require('./env'); 

const client = createClient({
  url: REDIS_URL,
  socket: {
    tls: true,
    rejectUnauthorized: false 
  },
});

client.on('error', (err) => {
  console.error('Redis client error', err);
});

(async () => {
  try {
    await client.connect();
    console.log('Connected to Aiven Redis successfully');
  } catch (e) {
    console.error('Failed to connect to Redis:', e.message);
  }
})();

module.exports = client;
