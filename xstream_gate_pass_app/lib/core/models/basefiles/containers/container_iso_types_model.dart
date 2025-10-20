class IsoType {
  final String size;
  final String type;
  final String code;
  final String description;

  IsoType({
    required this.size,
    required this.type,
    required this.code,
    required this.description,
  });

  // Factory constructor to create an IsoType from a JSON map
  factory IsoType.fromJson(Map<String, dynamic> json) {
    return IsoType(
      size: json['Size'] as String,
      type: json['Type'] as String,
      code: json['Code'] as String,
      description: json['Description'] as String,
    );
  }

  // Convert IsoType to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'Size': size,
      'Type': type,
      'Code': code,
      'Description': description,
    };
  }

  @override
  String toString() {
    return 'IsoType(size: $size, type: $type, code: $code, description: $description)';
  }

  // Convenience method to check if an ISO code matches this type
  bool matchesCode(String isoCode) {
    return code == isoCode;
  }

  // Equality and hashCode overrides for comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IsoType &&
        other.size == size &&
        other.type == type &&
        other.code == code &&
        other.description == description;
  }

  @override
  int get hashCode =>
      size.hashCode ^ type.hashCode ^ code.hashCode ^ description.hashCode;
}
