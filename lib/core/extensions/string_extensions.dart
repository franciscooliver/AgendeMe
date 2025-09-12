/// Extensões para a classe String
extension StringExtensions on String {
  /// Verifica se a string é um email válido
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Verifica se a string é um número de telefone válido (formato brasileiro)
  bool get isValidPhone {
    return RegExp(r'^\(\d{2}\)\s\d{4,5}-\d{4}$').hasMatch(this);
  }

  /// Verifica se a string é um CPF válido
  bool get isValidCPF {
    if (length != 11) return false;
    
    // Remove caracteres especiais
    final cpf = replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;
    
    // Calcula o primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstDigit = (sum * 10) % 11;
    if (firstDigit >= 10) firstDigit = 0;
    
    // Calcula o segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondDigit = (sum * 10) % 11;
    if (secondDigit >= 10) secondDigit = 0;
    
    // Verifica os dígitos
    return int.parse(cpf[9]) == firstDigit && int.parse(cpf[10]) == secondDigit;
  }

  /// Capitaliza a primeira letra da string
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Capitaliza cada palavra da string
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Remove espaços em branco extras
  String get trimExtra {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converte para snake_case
  String get toSnakeCase {
    return replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceFirst(RegExp(r'^_'), '');
  }

  /// Converte para camelCase
  String get toCamelCase {
    List<String> words = split(RegExp(r'[_\s]+'));
    if (words.isEmpty) return this;
    
    String result = words[0].toLowerCase();
    for (int i = 1; i < words.length; i++) {
      result += words[i].capitalize;
    }
    return result;
  }

  /// Máscara para CPF
  String get cpfMask {
    if (length != 11) return this;
    return '${substring(0, 3)}.${substring(3, 6)}.${substring(6, 9)}-${substring(9, 11)}';
  }

  /// Máscara para telefone
  String get phoneMask {
    if (length == 10) {
      return '(${substring(0, 2)}) ${substring(2, 6)}-${substring(6, 10)}';
    } else if (length == 11) {
      return '(${substring(0, 2)}) ${substring(2, 7)}-${substring(7, 11)}';
    }
    return this;
  }

  /// Remove todos os caracteres não numéricos
  String get numbersOnly {
    return replaceAll(RegExp(r'[^0-9]'), '');
  }
}
