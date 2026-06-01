const express = require('express');
const crypto = require('crypto');
const db = require('../config/db'); // Points to your unified MySQL connection pool

/** @type {import('express').Router} */
const router = express.Router();

function genToken() {
  return crypto.randomBytes(20).toString('hex');
}

async function genUserId() {
  const minUserId = 1000;
  let attempts = 0;
  
  while (attempts < 10) {
    const newUserId = Math.max(Math.floor(Date.now() % 1000000) + minUserId, minUserId);
    try {
      const [rows] = await db.query('SELECT userId FROM Accounts WHERE userId = ?', [newUserId]);
      if (rows.length === 0) {
        return newUserId;
      }
    } catch (err) {
      console.error('Error generating userId:', err.message);
      return minUserId;
    }
    attempts++;
  }
  return Math.max(Math.floor(Date.now() % 1000000) + minUserId, minUserId);
}

// Ensure table structures exist in MySQL on engine spin up
(async () => {
  try {
    await db.query(`CREATE TABLE IF NOT EXISTS Accounts (
      account VARCHAR(255) PRIMARY KEY,
      userId INT,
      password VARCHAR(255),
      type INT
    )`);
    
    await db.query(`CREATE TABLE IF NOT EXISTS UserDetails (
      userId INT PRIMARY KEY,
      nickName VARCHAR(255) NOT NULL,
      level INT DEFAULT 1,
      experience INT DEFAULT 0
    )`);
    
    await db.query(`CREATE TABLE IF NOT EXISTS Wallet (
      userId INT PRIMARY KEY,
      gold INT DEFAULT 0,
      gcubes INT DEFAULT 0,
      bcubes INT DEFAULT 0
    )`);
    
    await db.query(`CREATE TABLE IF NOT EXISTS DeviceTokens (
      userId INT PRIMARY KEY,
      deviceToken VARCHAR(255)
    )`);
    console.log('✅ MySQL tables checked & verified successfully.');
  } catch (err) {
    console.error('❌ Critical database structural initialization failure:', err.message);
  }
})();

// Shared handler structure for user info processing pipelines
async function userDetailsHandler(req, res) {
  try {
    const raw = req.query.userId || req.headers.userid || req.body?.userId || '112';
    const userIdNum = parseInt(String(raw), 10) || 112;

    const [details] = await db.query('SELECT * FROM UserDetails WHERE userId = ?', [userIdNum]);
    let currentDetailRow = details[0];

    if (!currentDetailRow) {
      await db.query('INSERT INTO UserDetails (userId, nickName, level, experience) VALUES (?, ?, ?, ?)', [userIdNum, `Player${userIdNum}`, 1, 0]);
      await db.query('INSERT IGNORE INTO Wallet (userId, gold, gcubes, bcubes) VALUES (?, ?, ?, ?)', [userIdNum, 0, 0, 0]);
      
      const [newDetails] = await db.query('SELECT * FROM UserDetails WHERE userId = ?', [userIdNum]);
      currentDetailRow = newDetails[0];
    }

    const [wallets] = await db.query('SELECT * FROM Wallet WHERE userId = ?', [userIdNum]);
    const wallet = wallets[0] || { gold: 0, gcubes: 0, bcubes: 0 };

    const userObj = {
      uid: String(userIdNum),
      userId: String(userIdNum),
      playerId: String(userIdNum),
      nickName: currentDetailRow.nickName,
      level: currentDetailRow.level,
      experience: currentDetailRow.experience,
      appearance: {
        hairId: 5, faceId: 3, topsId: 12, pantsId: 8, shoesId: 4,
        glassesId: 0, scarfId: 0, wingId: 2, hatId: 1, decoratehatId: 0,
        armId: 0, extrawingId: 0, footHaloId: 0,
        skinColor: { r: 0.85, g: 0.7, b: 0.6, a: 1.0 }
      },
      wallet: {
        gold: wallet.gold || 0,
        gcubes: wallet.gcubes || 0,
        bcubes: wallet.bcubes || 0,
        gcube: wallet.gcubes || 0,
        bcube: wallet.bcubes || 0
      }
    };

    return res.status(200).json({ code: 1, message: 'Success', data: userObj });
  } catch (err) {
    return res.status(500).json({ code: 4, message: 'internal error', detail: err.message });
  }
}

// POST /user/api/v1/user/register
router.post('/user/api/v1/user/register', async (req, res) => {
  try {
    const account = (req.body?.account || req.body?.username || req.query.account || '').trim();
    const password = req.body?.password || req.query.password || '';
    const deviceId = req.body?.deviceId || req.query.deviceId || '';
    const appType = req.body?.appType || req.query.appType || 'android';

    if (!account) return res.status(400).json({ code: -1, message: 'Account name is required' });

    const [accounts] = await db.query('SELECT * FROM Accounts WHERE account = ?', [account]);
    if (accounts.length > 0) return res.status(400).json({ code: -1, message: 'Account already exists' });

    const minUserId = 16;
    const userId = Math.max(Math.floor(Date.now() % 1000000) + 100, minUserId);

    await db.query('INSERT INTO Accounts (account, userId, password, type) VALUES (?, ?, ?, ?)', [account, userId, password, 0]);
    await db.query('INSERT IGNORE INTO UserDetails (userId, nickName, level, experience) VALUES (?, ?, ?, ?)', [userId, account, 1, 0]);
    await db.query('INSERT IGNORE INTO Wallet (userId, gold, gcubes, bcubes) VALUES (?, ?, ?, ?)', [userId, 0, 0, 0]);

    const token = genToken();
    const baseUrl = `https://blockman-xgo.onrender.com`;

    return res.status(200).json({
      code: 1,
      message: 'Success',
      data: {
        userId: String(userId),
        uid: String(userId),
        account: account,
        deviceId: deviceId,
        appType: appType,
        token: token,
        isTourist: false,
        baseUrl: baseUrl,
        backupBaseUrl: baseUrl
      }
    });
  } catch (err) {
    return res.status(500).json({ code: 4, message: 'internal error', detail: err.message });
  }
});

// POST /api/v2/app/login
router.post('/api/v2/app/login', async (req, res) => {
  try {
    const account = String(req.body?.uid || req.body?.account || '').trim();
    const password = req.body?.password || '';

    if (!account) return res.status(400).json({ code: -1, message: 'Account required' });

    const [accounts] = await db.query('SELECT * FROM Accounts WHERE account = ?', [account]);
    let targetUserId;

    if (accounts.length === 0) {
      targetUserId = await genUserId();
      await db.query('INSERT INTO Accounts (account, userId, password, type) VALUES (?, ?, ?, ?)', [account, targetUserId, password, 0]);
    } else {
      targetUserId = accounts[0].userId;
    }

    await db.query('INSERT IGNORE INTO UserDetails (userId, nickName, level, experience) VALUES (?, ?, ?, ?)', [targetUserId, account, 1, 0]);
    await db.query('INSERT IGNORE INTO Wallet (userId, gold, gcubes, bcubes) VALUES (?, ?, ?, ?)', [targetUserId, 0, 0, 0]);

    const token = genToken();
    return res.status(200).json({
      code: 1,
      message: 'Success',
      data: { 
        userId: String(targetUserId), 
        uid: String(targetUserId), 
        token, 
        hasPassword: !!password 
      }
    });
  } catch (err) {
    return res.status(500).json({ code: 4, message: 'DB error', detail: err.message });
  }
});

// GET /api/v1/inner/user/details
router.get('/api/v1/inner/user/details', userDetailsHandler);

// POST /api/v1/user/details/info
router.post('/api/v1/user/details/info', userDetailsHandler);

// GET /api/v1/app/auth-token
router.get('/api/v1/app/auth-token', (req, res) => {
  const headerUserId = req.headers['userid'] || req.headers['userId'] || req.headers['bmg-user-id'];
  const userIdNum = parseInt(String(headerUserId || '0'), 10) || 0;
  if (!userIdNum || userIdNum <= 0) return res.status(400).json({ code: -1, message: 'userId is required and must be greater than 0' });

  const deviceId = req.headers['bmg-device-id'] || '';
  return res.status(200).json({ code: 1, message: 'Success', data: { userId: String(userIdNum), deviceId, authToken: genToken() } });
});

// POST /api/v1/account/invalid/check
router.post('/api/v1/account/invalid/check', async (req, res) => {
  try {
    const account = req.query.account || req.body?.account || '';
    const type = req.query.type || req.body?.type || '1';
    let userId = 0;

    if (req.query.userId) userId = parseInt(String(req.query.userId).trim(), 10);
    else if (req.body?.userId) userId = parseInt(String(req.body.userId).trim(), 10);

    const minUserId = 16;

    if (!account) return res.status(400).json({ code: -1, message: 'Account is required' });

    if (type === '2') {
      if (!userId || userId <= 0) {
        return res.status(200).json({ code: 1, message: 'Success', data: null });
      } else {
        return res.status(200).json({ code: 1, message: 'Success', data: { invalid: 0 } });
      }
    }

    const [accounts] = await db.query('SELECT * FROM Accounts WHERE account = ?', [account]);
    const row = accounts[0];

    if (!row || !userId || userId <= 0) {
      const newUserId = Math.max(Math.floor(Date.now() % 1000000) + 100, minUserId);

      await db.query('INSERT INTO Accounts (account, userId, password, type) VALUES (?, ?, ?, ?)', [account, newUserId, '', 0]);
      await db.query('INSERT IGNORE INTO UserDetails (userId, nickName, level, experience) VALUES (?, ?, ?, ?)', [newUserId, account, 1, 0]);
      await db.query('INSERT IGNORE INTO Wallet (userId, gold, gcubes, bcubes) VALUES (?, ?, ?, ?)', [newUserId, 0, 0, 0]);

      const token = crypto.randomBytes(20).toString('hex');
      return res.status(200).json({
        code: 1,
        message: 'Success',
        data: { invalid: 1, userId: String(newUserId), uid: String(newUserId), token }
      });
    } else {
      return res.status(200).json({ code: 1, message: 'Success', data: { invalid: 0, userId: String(row.userId) } });
    }
  } catch (err) {
    return res.status(500).json({ code: 4, message: 'internal error', detail: err.message });
  }
});

// POST /user/api/v1/user/mac/id
router.post('/user/api/v1/user/mac/id', async (req, res) => {
  try {
    const uuid = req.query.uuid || req.body?.uuid || crypto.randomUUID();

    const [tokens] = await db.query('SELECT userId FROM DeviceTokens WHERE deviceToken = ?', [uuid]);
    const row = tokens[0];

    if (row) {
      return res.status(200).json({ code: 1, message: 'SUCCESS', data: { userId: String(row.userId) } });
    } else {
      const minUserId = 16;
      const userId = Math.max(Math.floor(Date.now() % 1000000) + 100, minUserId);

      await db.query('INSERT IGNORE INTO Accounts (account, userId, password, type) VALUES (?, ?, ?, ?)', [uuid, userId, '', 1]);
      await db.query('INSERT IGNORE INTO UserDetails (userId, nickName, level, experience) VALUES (?, ?, ?, ?)', [userId, `Tourist${userId}`, 1, 0]);
      await db.query('INSERT IGNORE INTO Wallet (userId, gold, gcubes, bcubes) VALUES (?, ?, ?, ?)', [userId, 0, 0, 0]);
      await db.query('INSERT INTO DeviceTokens (userId, deviceToken) VALUES (?, ?)', [userId, uuid]);

      return res.status(200).json({ code: 1, message: 'SUCCESS', data: { userId: String(userId) } });
    }
  } catch (err) {
    return res.status(500).json({ code: 4, message: 'internal error', detail: err.message });
  }
});

// POST /api/v1/user/mac/id
router.post('/api/v1/user/mac/id', (req, res) => {
  const appType = req.query.appType || req.body?.appType || 'android';
  const uuid = req.query.uuid || req.body?.uuid || '';
  console.log(`[countDaily] appType: ${appType}, uuid: ${uuid}`);
  return res.status(200).json({ code: 1, message: 'SUCCESS', data: null });
});

// Extended tourist login
router.post('/api/v1/app/user/tourist/login', async (req, res) => {
  try {
    const uuid = req.body?.uuid || req.query?.uuid || crypto.randomUUID();

    const [accounts] = await db.query('SELECT * FROM Accounts WHERE account = ?', [uuid]);
    const row = accounts[0];

    let targetUserId;
    if (row) {
      targetUserId = row.userId;
    } else {
      targetUserId = await genUserId();
      await db.query('INSERT INTO Accounts (account, userId, password, type) VALUES (?, ?, ?, ?)', [uuid, targetUserId, '', 1]);
      await db.query('INSERT INTO UserDetails (userId, nickName, level, experience) VALUES (?, ?, ?, ?)', [targetUserId, `Tourist${targetUserId}`, 1, 0]);
      await db.query('INSERT INTO Wallet (userId, gold, gcubes, bcubes) VALUES (?, ?, ?, ?)', [targetUserId, 0, 0, 0]);
    }

    const token = genToken();
    return res.json({ code: 1, message: 'Success', data: { userId: String(targetUserId), uid: String(targetUserId), token, isTourist: true } });
  } catch (err) {
    return res.status(500).json({ code: 4, message: 'internal error', detail: err.message });
  }
});

// POST /api/v1/user/language
router.post('/api/v1/user/language', (req, res) => {
  const userIdRaw = req.query.userId || req.headers.userid || req.body?.userId || '';
  const userId = String(userIdRaw || '');
  const language = req.query.language || req.body?.language || 'en';
  return res.status(200).json({ code: 1, message: 'Success', data: { userId, language } });
});

// PUT /api/v1/user/device/id
router.put('/api/v1/user/device/id', (req, res) => {
  const userIdRaw = req.headers.userid || req.body?.userId || '0';
  const userId = String(userIdRaw || '0');
  const { deviceId = '', signature = '' } = req.body || {};
  return res.status(200).json({ code: 1, message: 'Success', data: { userId, deviceId, signature } });
});

// GET /api/v1/users/device/token
router.get('/api/v1/users/device/token', async (req, res) => {
  try {
    const headerUserId = req.headers['userid'] || req.headers['userId'] || '0';
    const userIdNum = parseInt(String(headerUserId || '0'), 10) || 0;
    const userId = userIdNum ? userIdNum : 0;

    const [tokens] = await db.query('SELECT * FROM DeviceTokens WHERE userId = ?', [userId]);
    const row = tokens[0];
    const deviceToken = row ? row.deviceToken : 'mock-device-token';

    return res.status(200).json({ code: 1, message: 'Success', data: { userId: String(userId), deviceToken } });
  } catch (err) {
    return res.status(500).json({ code: 4, message: 'internal error', detail: err.message });
  }
});

// GET /api/v1/user/set-psd/param/check
router.get('/api/v1/user/set-psd/param/check', async (req, res) => {
  try {
    const { type } = req.query;
    const headerUserId = req.headers['userid'] || req.headers['userId'] || '0';
    
    if (type === '1') {
      const [accounts] = await db.query('SELECT password FROM Accounts WHERE userId = ?', [headerUserId]);
      const row = accounts[0];
      const isPasswordSet = row && row.password && row.password.trim() !== '';
      return res.json({
        code: 0,
        message: 'Success',
        data: { isSet: isPasswordSet ? 1 : 0, type: 1 }
      });
    } else if (type === '2') {
      return res.json({ code: 0, message: 'Success', data: null });
    } else {
      return res.status(400).json({ code: 2, message: 'Invalid type parameter. Must be 1 or 2.' });
    }
  } catch (err) {
    return res.status(500).json({ code: 1, message: 'Database error' });
  }
});

module.exports = router;
    
