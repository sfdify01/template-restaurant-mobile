import 'package:flutter/widgets.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl_phone_field/phone_number.dart';

class AppValidators {
  AppValidators._();

  static final RegExp _usPhoneRegex = RegExp(
    r'^\s*(?:\+?1\s*)?(?:\(?\d{3}\)?[\s.-]?)\d{3}[\s.-]?\d{4}\s*$',
  );

  static FormFieldValidator<String> required({String message = 'Required'}) {
    return FormBuilderValidators.required(errorText: message);
  }

  static FormFieldValidator<String> name({
    String label = 'name',
    bool required = true,
  }) {
    final validators = <FormFieldValidator<String>>[];
    if (required) {
      validators.add(
        FormBuilderValidators.required(
          errorText: 'Please enter your $label',
        ),
      );
    }
    validators.add(
      FormBuilderValidators.minLength(
        2,
        errorText: 'Please enter a valid $label',
        checkNullOrEmpty: required,
      ),
    );
    validators.add(
      FormBuilderValidators.maxLength(
        50,
        errorText: 'Please enter a valid $label',
        checkNullOrEmpty: required,
      ),
    );
    return FormBuilderValidators.compose(validators);
  }

  static FormFieldValidator<String> email({bool required = true}) {
    final validators = <FormFieldValidator<String>>[];
    if (required) {
      validators.add(
        FormBuilderValidators.required(
          errorText: 'Please enter your email',
        ),
      );
    }
    validators.add(
      FormBuilderValidators.email(
        errorText: 'Please enter a valid email',
        checkNullOrEmpty: required,
      ),
    );
    return FormBuilderValidators.compose(validators);
  }

  static FormFieldValidator<String> usPhone({bool required = true}) {
    return (value) => _validateUsPhone(value, required: required);
  }

  static FormFieldValidator<PhoneNumber> usPhoneIntl({bool required = false}) {
    return (phone) =>
        _validateUsPhone(phone?.completeNumber, required: required);
  }

  static FormFieldValidator<String> password({int minLength = 6}) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: 'Please enter your password',
      ),
      FormBuilderValidators.minLength(
        minLength,
        errorText: 'Password must be at least $minLength characters',
      ),
    ]);
  }

  static FormFieldValidator<String> confirmPassword(
    TextEditingController controller,
  ) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != controller.text) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  static bool isValidUsPhone(String? value) {
    return _validateUsPhone(value, required: false) == null;
  }

  static String? _validateUsPhone(String? value, {required bool required}) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return required ? 'Please enter your phone number' : null;
    }
    if (!_usPhoneRegex.hasMatch(input)) {
      return 'Enter a valid US phone number';
    }
    return null;
  }
}
