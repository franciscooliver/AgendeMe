/// Enum que define os tipos de usuário no sistema AgendeMe
/// 
/// - [client]: Usuário que agenda serviços
/// - [professional]: Usuário que oferece serviços
enum UserType {
  /// Cliente que agenda serviços
  client('client', 'Cliente'),
  
  /// Profissional que oferece serviços
  professional('professional', 'Profissional');

  const UserType(this.value, this.displayName);

  /// Valor string do tipo de usuário (para persistência)
  final String value;
  
  /// Nome para exibição na interface
  final String displayName;

  /// Converte string para UserType
  static UserType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'client':
        return UserType.client;
      case 'professional':
        return UserType.professional;
      default:
        throw ArgumentError('Invalid UserType: $value');
    }
  }

  /// Converte UserType para string
  @override
  String toString() => value;

  /// Verifica se o usuário é um cliente
  bool get isClient => this == UserType.client;

  /// Verifica se o usuário é um profissional
  bool get isProfessional => this == UserType.professional;
}
