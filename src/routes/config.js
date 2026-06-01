const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const { getPlayerIdentityConfig } = require('../services/activityService');

// GET /config/files/player-identity-config
router.get('/config/files/player-identity-config', (req, res) => {
  const { statusCode, body } = getPlayerIdentityConfig();
  return res.status(statusCode).json(body);
});

// Helper function to dynamically read the config file from your database folder
const serveBlockmodsConfig = (req, res) => {
  // Traces path from src/routes/config.js back to database/appconfigs/blockmods_config
  const configFilePath = path.join(__dirname, '../../database/appconfigs/blockmods_config');
  
  fs.readFile(configFilePath, 'utf8', (err, data) => {
    if (err) {
      console.error('❌ Failed to locate configuration asset:', err.message);
      return res.status(404).json({ 
        code: 404, 
        message: "Config profile not found on server",
        success: false 
      });
    }
    try {
      return res.status(200).json(JSON.parse(data));
    } catch (parseError) {
      console.error('❌ Syntax error parsing JSON config profile:', parseError.message);
      return res.status(500).json({ 
        code: 500, 
        message: "Invalid JSON structure inside configuration file",
        success: false 
      });
    }
  });
};

// FIX: Catch the exact clean path your game engine client is hitting
router.get('/config/files/blockmods-config', serveBlockmodsConfig);

// Alias: Keep the versioned path active just in case legacy clients ask for it
router.get('/config/files/blockmods-config-v1', serveBlockmodsConfig);

// GET /config/files/blockymods-check-version
router.get('/config/files/blockymods-check-version', (req, res) => {
  return res.status(200).json({
    code: 1,
    message: 'Success',
    data: {
      latestVersion: '3410',
      forceUpdate: false,
      message: '',
    },
  });
});

// GET /config/files/dress-guide-config
router.get('/config/files/dress-guide-config', (req, res) => {
  return res.status(200).json({
    code: 1,
    message: 'Success',
    data: {
      enabled: true,
      tips: [],
    },
  });
});

const editorData = require('../Jsons/editor.json');

router.get('/config/files/game-detail-to-editor', (req, res) => {
  try {
    res.status(200).json({
      code: 1,
      message: 'Success',
      data: {
        editorVersion: 1,
        resources: editorData.data,
      },
    });
  } catch (error) {
    console.error('Error in game-detail-to-editor:', error);
    res.status(500).json({
      code: -1,
      message: 'Internal server error',
      error: error.message
    });
  }
});

router.get('/decoration/api/v1/new/decorations/check/resource', (req, res) => {
  const { resVersion, engineVersion } = req.query;
  res.status(200).json({
    code: 1,
    message: 'Success',
    data: {
      resVersion: Number(resVersion),
      engineVersion: Number(engineVersion),
      resources: [],
    },
  });
});

module.exports = router;
