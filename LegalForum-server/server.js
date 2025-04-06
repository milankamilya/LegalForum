const app = require('./app')

const db = require('./config/connection');
const PORT = process.env.PORT || 3001;
const { logger } = require('./utils/logger');

db.once('open', () => {
  app.listen(PORT, () => {
    logger.info(`Legal Forum API server running on port ${PORT}!`);
  });
})
