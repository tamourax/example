import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../localization/l10n_extension.dart';
import '../theme/app_colors.dart';

/// A labeled form field. Use inside a Form and call FormState.validate().
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.textColor,
    this.controller,
    this.initialValue,
    this.isRequired = false,
    this.requiredErrorText,
    this.validator,
    this.errorText,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : assert(controller == null || initialValue == null),
       assert(maxLines > 0),
       assert(!obscureText || maxLines == 1);

  final String label;
  final String? hintText;
  final Widget? prefixIcon;
  final Color? textColor;
  final TextEditingController? controller;
  final String? initialValue;
  final bool isRequired;
  final String? requiredErrorText;
  final FormFieldValidator<String>? validator;

  /// An external/server error; clear it in the parent when the input changes.
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final AutovalidateMode autovalidateMode;

  static const _textStyle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(4)),
    borderSide: BorderSide.none,
  );
  static const _errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(4)),
    borderSide: BorderSide(color: Color(0xFFFF0000)),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: _textStyle, textAlign: TextAlign.start),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        initialValue: initialValue,
        focusNode: focusNode,
        style: _textStyle.copyWith(
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        enabled: enabled,
        readOnly: readOnly,
        maxLines: maxLines,
        onChanged: onChanged,
        onSaved: onSaved,
        onFieldSubmitted: onFieldSubmitted,
        autovalidateMode: autovalidateMode,
        forceErrorText: errorText,
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return requiredErrorText ?? context.l10n.fieldRequired;
          }
          return validator?.call(value);
        },
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 36,
          ),
          hintStyle: _textStyle.copyWith(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.hintTextColor,
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          border: _border,
          enabledBorder: _border,
          focusedBorder: _border,
          disabledBorder: _border,
          errorBorder: _errorBorder,
          focusedErrorBorder: _errorBorder,
          errorStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Color(0xFFFF0000),
          ),
          errorMaxLines: 3,
        ),
      ),
    ],
  );
}
