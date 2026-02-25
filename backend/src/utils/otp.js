exports.validateEmail = (email) => {
  const regex = /^\S+@\S+\.\S+$/;
  return regex.test(email);
};

exports.validatePassword = (password) => {
  // Minimum 6 chars, at least 1 number
  const regex = /^(?=.*\d).{6,}$/;
  return regex.test(password);
};

exports.validateRequired = (fields) => {
  for (const key in fields) {
    if (!fields[key]) {
      return `${key} is required`;
    }
  }
  return null;
};

exports.generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

exports.getOTPExpiry = () => {
  return new Date(Date.now() + 10 * 60 * 1000);
};