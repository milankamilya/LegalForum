var express = require('express');
var router = express.Router();
const { User } = require('../models');
const { signToken } = require('../utils/signToken');
const { logger } = require('../utils/logger');
const { auth } = require('../middleware');

// TODO:
// 1. Add email availability check api

router.post('/user/create', async (req, res) => {
  try {
    const user = await User.create(req.body);
    return res.status(200).send({ message: 'User created successfully', data: user });
  } catch (err) {
    return res.status(400).send({ error: { message: err.message ?? err } });
  }
});

router.post("/user/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log(req.body);
    let user;
    if (email) {
      user = await User.findOne({ email }).select('+password');
    }

    if (!user) {
      throw `User with email ${email} not found`;
    }
    const { password: storedPassword } = user;
    if (!storedPassword)
      throw `User with email ${email} does not have a password`;
    const correctPw = await user.isCorrectPassword(password);

    if (!correctPw) {
      throw `Incorrect password for user with email ${email}`;
    }
    const token = await signToken(user, req.platform);

    const userId = user._id;
    user = await User.findById(userId);
    return res.status(200).send({ message: "Login successfully", data: { token, user } });
  } catch (err) {
    logger.error(req.route.path, ' : ', err);
    return res.status(400).send({ error: { message: err.message ?? err } });
  }
});

router.post("/user/logout", auth, async (req, res) => {
  try {
    const { _id: userId } = req.session;
    const user = await User.findOne({ _id: userId });
    if (!user) {
      throw "User not found";
    }
    return res.status(200).send({ message: "User logged out successfully" });
  } catch (err) {
    logger.error(req.route.path, " : ", err);
    return res.status(400).send({ error: { message: err.message ?? err } });
  }
});

router.post("/user/list", auth, async (req, res) => {
  try {
    const {role} = req.body;
    const users = await User.find({role});
    return res.status(200).send({ data: users });
  } catch (err) {
    logger.error(req.route.path, " : ", err);
    return res.status(400).send({ error: { message: err.message ?? err } });
  }
});

module.exports = router;
