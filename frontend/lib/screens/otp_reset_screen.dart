import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'sign_in_screen.dart';

class OtpResetScreen extends StatefulWidget {
  final String email;
  const OtpResetScreen({super.key, required this.email});

  @override
  State<OtpResetScreen> createState() => _OtpResetScreenState();
}

class _OtpResetScreenState extends State<OtpResetScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNodes[0].requestFocus(),
    );
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendCountdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _resendOtp() async {
    try {
      await AuthService.forgotPassword(email: widget.email);
      _startResendTimer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new code has been sent.'),
          backgroundColor: Color(0xFF6C63FF),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _otpControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  Future<void> _verifyAndReset() async {
    if (_otpValue.length < 6) {
      _showError('Please enter the 6-digit code');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.resetPassword(
        email: widget.email,
        otp: _otpValue,
        newPassword: _newPasswordController.text,
      );
      if (!mounted) return;
      _showSuccessDialog();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFFF5555),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog() {
    final w = MediaQuery.of(context).size.width;
    final bodySize = (w * 0.037).clamp(13.0, 17.0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(w * 0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: w * 0.16,
                height: w * 0.16,
                decoration: BoxDecoration(
                  color: const Color(0xFF33FF99).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: const Color(0xFF33FF99),
                  size: w * 0.08,
                ),
              ),
              SizedBox(height: w * 0.05),
              Text(
                'Password Reset!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (w * 0.05).clamp(16.0, 22.0),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: w * 0.02),
              Text(
                'Your password has been successfully updated.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF888888),
                  fontSize: bodySize - 1,
                  height: 1.5,
                ),
              ),
              SizedBox(height: w * 0.07),
              SizedBox(
                width: double.infinity,
                height: (MediaQuery.of(context).size.height * 0.06).clamp(
                  44.0,
                  54.0,
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (_) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Back to Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: bodySize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final hPad = w * 0.07;
    final headingSize = (w * 0.095).clamp(28.0, 48.0);
    final bodySize = (w * 0.037).clamp(13.0, 17.0);
    final labelSize = (w * 0.032).clamp(11.0, 14.0);
    final buttonHeight = (h * 0.065).clamp(46.0, 60.0);
    final fieldVertPad = (h * 0.019).clamp(12.0, 20.0);
    final topSpace = (h * 0.03).clamp(16.0, 36.0);
    final sectionGap = (h * 0.04).clamp(24.0, 52.0);
    final iconSize = (w * 0.14).clamp(44.0, 64.0);
    // OTP box size: fit 6 boxes with spacing in screen width
    final otpBoxWidth = ((w - hPad * 2 - 25) / 6).clamp(36.0, 52.0);
    final otpBoxHeight = (otpBoxWidth * 1.2).clamp(44.0, 62.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: topSpace),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: w * 0.1,
                  height: w * 0.1,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    maxWidth: 48,
                    minHeight: 36,
                    maxHeight: 48,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: w * 0.04,
                  ),
                ),
              ),
              SizedBox(height: sectionGap * 0.9),
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(iconSize * 0.32),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: const Color(0xFF6C63FF),
                  size: iconSize * 0.5,
                ),
              ),
              SizedBox(height: sectionGap * 0.7),
              Text(
                'Enter code.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: headingSize,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: h * 0.015),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: bodySize,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to '),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sectionGap),
              // OTP boxes — evenly spaced, fully responsive
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (i) => _buildOTPBox(i, otpBoxWidth, otpBoxHeight),
                ),
              ),
              SizedBox(height: h * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _resendCountdown > 0
                        ? 'Resend code in ${_resendCountdown}s'
                        : "Didn't receive it? ",
                    style: TextStyle(
                      color: const Color(0xFF888888),
                      fontSize: labelSize,
                    ),
                  ),
                  if (_resendCountdown == 0)
                    GestureDetector(
                      onTap: _resendOtp,
                      child: Text(
                        'Resend',
                        style: TextStyle(
                          color: const Color(0xFF6C63FF),
                          fontSize: labelSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: sectionGap),
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: const Color(0xFF1E1E1E)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'New password',
                      style: TextStyle(
                        color: const Color(0xFF555555),
                        fontSize: labelSize - 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(height: 1, color: const Color(0xFF1E1E1E)),
                  ),
                ],
              ),
              SizedBox(height: sectionGap * 0.7),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      hint: '••••••••',
                      obscure: _obscureNew,
                      onToggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      labelSize: labelSize,
                      bodySize: bodySize,
                      fieldVertPad: fieldVertPad,
                      w: w,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 8) return 'At least 8 characters';
                        return null;
                      },
                    ),
                    SizedBox(height: h * 0.02),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: '••••••••',
                      obscure: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      labelSize: labelSize,
                      bodySize: bodySize,
                      fieldVertPad: fieldVertPad,
                      w: w,
                      validator: (v) {
                        if (v != _newPasswordController.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    ),
                    SizedBox(height: sectionGap),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyAndReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          disabledBackgroundColor: const Color(
                            0xFF6C63FF,
                          ).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Reset Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: bodySize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sectionGap),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index, double boxWidth, double boxHeight) {
    return SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: TextStyle(
          color: Colors.white,
          fontSize: (boxWidth * 0.42).clamp(16.0, 22.0),
          fontWeight: FontWeight.w700,
        ),
        onChanged: (val) {
          if (val.length == 1 && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: _otpControllers[index].text.isNotEmpty
              ? const Color(0xFF6C63FF).withOpacity(0.12)
              : const Color(0xFF161616),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _otpControllers[index].text.isNotEmpty
                  ? const Color(0xFF6C63FF)
                  : const Color(0xFF2A2A2A),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required double labelSize,
    required double bodySize,
    required double fieldVertPad,
    required double w,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFAAAAAA),
            fontSize: labelSize,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: TextStyle(color: Colors.white, fontSize: bodySize),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF444444),
              fontSize: bodySize,
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: const Color(0xFF444444),
              size: w * 0.05,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF555555),
                size: w * 0.05,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: const Color(0xFF161616),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF6C63FF),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFF5555)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFF5555)),
            ),
            errorStyle: const TextStyle(color: Color(0xFFFF5555)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: fieldVertPad,
            ),
          ),
        ),
      ],
    );
  }
}
