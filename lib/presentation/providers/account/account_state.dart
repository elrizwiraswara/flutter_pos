import 'dart:io';

class AccountFormState {
  final File? imageFile;
  final String? imageUrl;
  final String? name;
  final String? email;
  final String? phone;
  final bool isLoaded;

  const AccountFormState({
    this.imageFile,
    this.imageUrl,
    this.name,
    this.email,
    this.phone,
    this.isLoaded = false,
  });

  AccountFormState copyWith({
    File? imageFile,
    String? imageUrl,
    String? name,
    String? email,
    String? phone,
    bool? isLoaded,
  }) {
    return AccountFormState(
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
