const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail', // or use SMTP config
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS, // use App Password (NOT real Gmail password)
  },
});

exports.sendOTPEmail = async (to, otp) => {
  await transporter.sendMail({
    from: `"Your App Support" <${process.env.EMAIL_USER}>`,
    to,
    subject: 'Password Reset OTP',
    html: `
      <h3>Password Reset Request</h3>
      <p>Your OTP is:</p>
      <h2>${otp}</h2>
      <p>This OTP expires in 10 minutes.</p>
    `,
  });
};