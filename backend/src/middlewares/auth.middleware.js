const jwt = require('jsonwebtoken');
const config = require('../config/jwt');

module.exports = (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1];

  if (!token)
    return res.status(401).json({ message: "Access denied" });

  try {
    const verified = jwt.verify(token, config.secret);
    req.user = verified;
    next();
  } catch {
    res.status(400).json({ message: "Invalid token" });
  }
};