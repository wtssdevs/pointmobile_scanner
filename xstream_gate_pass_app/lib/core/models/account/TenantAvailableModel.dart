// Model based on the C# class in comments
class TenantAvailableModel {
  TenantAvailabilityState state;
  int? tenantId;

  TenantAvailableModel({
    required this.state,
    this.tenantId,
  });

  // Factory constructor to create a TenantAvailableModel from JSON
  factory TenantAvailableModel.fromJson(Map<String, dynamic> json) {
    return TenantAvailableModel(
      state: TenantAvailabilityState.values[json['state'] - 1],
      tenantId: json['tenantId'],
    );
  }

  // Method to convert TenantAvailableModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'state': state.index + 1, // Adding 1 to match C# enum values starting at 1
      'tenantId': tenantId,
    };
  }
}

// Enum representing TenantAvailabilityState
enum TenantAvailabilityState {
  available, // 1
  inActive, // 2
  notFound // 3
}
