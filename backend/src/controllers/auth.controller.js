const authService = require('../services/auth.service');
const { validateEmail, validatePassword, validateRequired } = require('../utils/validator');

exports.signup = async (req, res, next) => {
  try {
    const error = validateRequired(req.body);
    if (error) return res.status(400).json({ message: error });

    const { name, email, password } = req.body;

    if (!validateEmail(email))
      return res.status(400).json({ message: "Invalid email format" });

    if (!validatePassword(password))
      return res.status(400).json({ message: "Weak password" });

    const result = await authService.signup(name, email, password);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
};

exports.login = async (req, res, next) => {
  try {
    const error = validateRequired(req.body);
    if (error) return res.status(400).json({ message: error });

    const { email, password } = req.body;
    const result = await authService.login(email, password);

    res.json(result);
  } catch (err) {
    res.status(401).json({ message: err.message });
  }
};

exports.forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ message: "Email required" });

    const result = await authService.forgotPassword(email);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.resetPassword = async (req, res, next) => {
  try {
    const { email, otp, newPassword } = req.body;

    if (!email || !otp || !newPassword)
      return res.status(400).json({ message: "All fields are required" });

    if (!validatePassword(newPassword))
      return res.status(400).json({ message: "Weak password" });

    const result = await authService.resetPassword(
      email,
      otp,
      newPassword
    );

    res.json(result);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};