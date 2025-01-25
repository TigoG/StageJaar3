import 'package:flutter/material.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_colors.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final bool obscureText;
  final bool showCursor;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final VoidCallback? onTap;
  final bool isError;
  final String? errorMessage;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    required this.controller,
    this.showCursor = true,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.isError = false,
    this.errorMessage,
  });

  @override
  State<StatefulWidget> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? _errorMessage;
  bool? _isError;

  @override
  void initState() {
    super.initState();
    _errorMessage = widget.errorMessage;
    _isError = widget.isError;
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != oldWidget.errorMessage ||
        widget.isError != oldWidget.isError) {
      setState(() {
        _errorMessage = widget.errorMessage;
        _isError = widget.isError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel =
        widget.isError && _errorMessage != null ? _errorMessage : widget.label;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: SensibleDefaults.getBorderRadius(),
      ),
      child: TextField(
        onChanged: (String value) {
          setState(() {
            _errorMessage = '';
            _isError = false;
          });
        },
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        showCursor: widget.showCursor,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          labelText: displayLabel,
          labelStyle: _isError!
              ? const TextStyle(color: Colors.red)
              : const TextStyle(color: Colors.grey),
          floatingLabelBehavior: _isError!
              ? FloatingLabelBehavior.always
              : FloatingLabelBehavior.never,
          contentPadding: EdgeInsets.symmetric(
            vertical: SensibleDefaults.getPadding(context),
            horizontal: SensibleDefaults.getPadding(context),
          ),
          border: InputBorder.none, 
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: SensibleColors.sensibleDeepBlue,
              width: 2,
            ),
          ),
        ),
        onTap: widget.onTap,
      ),
    );
  }
}
