const mysql = require('mysql2/promise');
const { MYSQL_URL } = require('./env');

// Create a unified pool to handle your database requests efficiently
const pool = mysql.createPool({
  uri: MYSQL_URL,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  ssl: {
    rejectUnauthorized: false // CRITICAL: Required for secure connections to Aiven MySQL
  }
});

// Test connection on startup to make sure your credentials work
(async () => {
  try {
    const connection = await pool.getConnection();
    console.log('Connected to Aiven MySQL successfully!');
    connection.release();
  } catch (err) {
    console.error('❌ MySQL Initialization Error:', err.message);
  }
})();

/**
 * Helper function to run database queries using async/await.
 * Replaces the need for separate file references.
 * * Usage in routes: 
 * const db = require('./db');
 * const [rows] = await db.query('SELECT * FROM main_users WHERE id = ?', [id]);
 */
module.exports = pool;
