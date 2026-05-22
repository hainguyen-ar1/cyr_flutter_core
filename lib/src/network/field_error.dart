/// Lỗi validation theo từng field trong envelope API.
class FieldError {
  const FieldError({
    required this.field,
    required this.message,
  });

  final String field;
  final String message;

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] as String? ?? '_',
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'field': field,
        'message': message,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldError && field == other.field && message == other.message;

  @override
  int get hashCode => Object.hash(field, message);
}
