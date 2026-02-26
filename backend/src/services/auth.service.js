const pool = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const config = require('../config/jwt');
const { generateOTP, getOTPExpiry } = require('../utils/otp');
const { sendOTPEmail } = require('../utils/email');

exports.signup = async (name, email, password) => {
  const hashedPassword = await bcrypt.hash(password, 10);

  let userId;

  try {
    const [result] = await pool.execute(
      `INSERT INTO users (username, email, password)
       VALUES (?, ?, ?)`,
      [name, email, hashedPassword]
    );

    userId = result.insertId;
  } catch (err) {
  if (err.code === 'ER_DUP_ENTRY') {
    const error = new Error("Email already exists");
    error.statusCode = 400;
    throw error;
  }
  throw err;
}

  const token = jwt.sign(
    { id: userId, email },
    config.secret,
    { expiresIn: config.expiresIn }
  );

  return {
    message: "User registered successfully",
    token
  };
};

exports.login = async (email, password) => {
  const [rows] = await pool.execute(
    `SELECT * FROM users WHERE email = ?`,
    [email]
  );

  const user = rows[0];
  if (!user) {
    const error = new Error("Invalid credentials");
    error.statusCode = 401;
    throw error;
  }

  const match = await bcrypt.compare(password, user.password);
  if (!match) throw new Error("Invalid credentials");

  const token = jwt.sign(
    { id: user.id, email: user.email },
    config.secret,
    { expiresIn: config.expiresIn }
  );

  return { token };
};

exports.forgotPassword = async (email) => {
  const [rows] = await pool.execute(
    `SELECT * FROM users WHERE email = ?`,
    [email]
  );

  if (!rows.length) throw new Error("Email not found");

  const otp = generateOTP();
  const expiry = getOTPExpiry();

  await pool.execute(
    `UPDATE users
     SET otp = ?, otp_expiry = ?
     WHERE email = ?`,
    [otp, expiry, email]
  );

  // Send email
  await sendOTPEmail(email, otp);

  return { message: "OTP sent to email" };
};

exports.resetPassword = async (email, otp, newPassword) => {
  const [rows] = await pool.execute(
    `SELECT * FROM users WHERE email = ?`,
    [email]
  );

  const user = rows[0];
  if (!user) throw new Error("User not found");

  if (!user.otp || user.otp !== otp)
    throw new Error("Invalid OTP");

  if (new Date(user.otp_expiry) < new Date())
    throw new Error("OTP expired");

  const hashedPassword = await bcrypt.hash(newPassword, 10);

  await pool.execute(
    `UPDATE users
     SET password = ?, otp = NULL, otp_expiry = NULL
     WHERE email = ?`,
    [hashedPassword, email]
  );

  return { message: "Password reset successfully" };
};