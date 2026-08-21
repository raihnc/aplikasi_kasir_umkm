enum UserRole { owner, cashier }

class StoreUser {
  const StoreUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;

  String get roleLabel => role == UserRole.owner ? 'Owner' : 'Kasir';

  StoreUser copyWith({bool? isActive}) {
    return StoreUser(
      id: id,
      name: name,
      email: email,
      role: role,
      isActive: isActive ?? this.isActive,
    );
  }
}
