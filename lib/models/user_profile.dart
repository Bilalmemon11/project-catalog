class UserProfile {
  const UserProfile({
    required this.distributor,
    required this.storeName,
    required this.equityNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.email,
    required this.phoneNumber,
  });

  final String distributor;
  final String storeName;
  final String equityNumber;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String email;
  final String phoneNumber;

  bool get isComplete =>
      distributor.isNotEmpty &&
      storeName.isNotEmpty &&
      equityNumber.isNotEmpty &&
      address.isNotEmpty &&
      city.isNotEmpty &&
      state.isNotEmpty &&
      zipCode.isNotEmpty &&
      email.isNotEmpty &&
      phoneNumber.isNotEmpty;

  UserProfile copyWith({
    String? distributor,
    String? storeName,
    String? equityNumber,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? email,
    String? phoneNumber,
  }) {
    return UserProfile(
      distributor: distributor ?? this.distributor,
      storeName: storeName ?? this.storeName,
      equityNumber: equityNumber ?? this.equityNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
