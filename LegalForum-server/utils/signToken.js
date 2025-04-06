const jwt = require('jsonwebtoken');
const secret = 'leg@lf0rum';
const expiration = '365d';

module.exports = {
  signToken: async function ({ email, _id, role},platform) {
    const payload = { email, _id , role,};
    if(platform === 'ios' || platform === 'android'){
      return jwt.sign({ data: payload }, secret);
    }
    return jwt.sign({ data: payload }, secret, { expiresIn: expiration });
  },
};
