import 'package:flutter/material.dart';

class CustomLoginField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData suffixIcon; // الأيقونة جهة اليمين
  final bool isPassword;
  final TextEditingController? controller;


  const CustomLoginField({
    super.key,
    required this.label,
    required this.hint,
    required this.suffixIcon,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomLoginField> createState() => _CustomLoginFieldState();
}

class _CustomLoginFieldState extends State<CustomLoginField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack( // استخدمنا Stack لنضع "نسيت كلمة المرور" داخل الحقل
        children: [
          TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              hintText: widget.hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),

              // أيقونة العين (تظهر فقط في حقل الباسورد)
              prefixIcon: widget.isPassword
                  ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
                  : null,

              // الأيقونة الأساسية (إيميل أو قفل) على اليمين
              suffixIcon: Icon(widget.suffixIcon, color: Colors.grey, size: 22),

              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade800, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),

          // نص "نسيت كلمة المرور" يظهر فوق الحقل من جهة اليسار (مثل الصورة)
        if (widget.isPassword)
    Positioned(
      left: 50,
      top: 35,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/forgot-password'); // ✅ هون الصح
        },
        child: const Text(
          "نسيت كلمة المرور؟",
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 11,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),

        ],
      ),
    );
  }
}
