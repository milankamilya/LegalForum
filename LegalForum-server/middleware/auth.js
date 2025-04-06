const jwt = require("jsonwebtoken");
const { logger } = require('../utils/logger');
const { User } = require("../models");

module.exports = async (req, res, next) => {
  const token = req.headers["x-access-token"];
  if (!token || token == "undefined") {
    res.status(401).send({ error: { message: "Invalid token" } });
  } else {
    jwt.verify(token, "leg@lf0rum", async (err, decoded) => {
      if (err) {
        logger.error(req.route.path, ":","Fail to authenticate","\n",err,'\ntoken :\n',token);
        res.status(401).send({
          auth: false,
          message: "Fail to authenticate",
          error: { message: "Invalid token" },
        });
      } else {
        // adding decoded information to request as a session information here.
        req.session = decoded.data;
        req.platform = req.headers["platform"];
        req.userId = decoded.data._id;
        req.session.id = decoded.data._id;
        let user = await User.findOne({ _id: req.userId });
        let lang = (req.headers["user-language"] ?? user.language ?? "en").toLowerCase();
        var language = "en"
        if (lang == "spanish" || lang == "es") {
          language = "es"
        }
        req.session.language = language;
        req.language = language;

        next();
      }
    });
  }
};