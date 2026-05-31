const path = require('path');

const PORT = parseInt(process.env.PORT || '38199', 10);

// Fallbacks are removed to prevent accidental leakage in your source control (e.g., GitHub)
const SECRET_KEY = process.env.SECRET_KEY;
const REDIS_URL = process.env.REDIS_URL;
const MYSQL_URL = process.env.MYSQL_URL;

// Throw an early error if the server is missing critical database variables
if (!REDIS_URL || !MYSQL_URL || !SECRET_KEY) {
  console.error('❌ ERROR: Missing required environment variables (REDIS_URL, MYSQL_URL, or SECRET_KEY). Exiting...');
  process.exit(1);
}

module.exports = {
  PORT,
  SECRET_KEY,
  REDIS_URL,
  MYSQL_URL,
};
