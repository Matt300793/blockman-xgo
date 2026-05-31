let express = require('express');
let app = express();

//404 handler
app.use((req, res) => {
  res.status(404).json({ 
    code: 0, 
    message: 'Endpoint not found' 
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err.stack);
  res.status(500).json({ 
    code: 0, 
    message: 'Internal Server Error' 
  });
});

// ======================
// Server Configuration
// ======================
let port = process.env.PORT || 38199;
let server = app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});

// Handle server events
server.on('connection', (socket) => {
  socket.setTimeout(30 * 1000); // 30 seconds
  console.log('New connection established');
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('Unhandled Rejection:', err);
  server.close(() => process.exit(1));
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  server.close(() => process.exit(1));
});

module.exports = { app, server };
