const mongoose = require('mongoose');
const { logger } = require('../utils/logger');

require('dotenv').config()
const { MONGODB_CONNECTION_URL } = process.env;
logger.info(`> Connecting too ${MONGODB_CONNECTION_URL}`);
mongoose.connect(
    MONGODB_CONNECTION_URL || `mongodb://127.0.0.1:27017/legalForum`,
    {
        useNewUrlParser: true,
        useUnifiedTopology: true,
    }
);

module.exports = mongoose.connection;