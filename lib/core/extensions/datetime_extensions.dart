/// Extensões para a classe DateTime
extension DateTimeExtensions on DateTime {
  /// Verifica se a data é hoje
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Verifica se a data é amanhã
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && 
           month == tomorrow.month && 
           day == tomorrow.day;
  }

  /// Verifica se a data é ontem
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && 
           month == yesterday.month && 
           day == yesterday.day;
  }

  /// Verifica se a data está no passado
  bool get isPast => isBefore(DateTime.now());

  /// Verifica se a data está no futuro
  bool get isFuture => isAfter(DateTime.now());

  /// Retorna apenas a data (sem horário)
  DateTime get dateOnly => DateTime(year, month, day);

  /// Retorna o início do dia (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Retorna o fim do dia (23:59:59.999)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Retorna o início da semana (segunda-feira)
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  /// Retorna o fim da semana (domingo)
  DateTime get endOfWeek {
    final daysUntilSunday = 7 - weekday;
    return add(Duration(days: daysUntilSunday)).endOfDay;
  }

  /// Retorna o início do mês
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Retorna o fim do mês
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Formata a data no padrão brasileiro (dd/MM/yyyy)
  String get toBrazilianFormat {
    return '${day.toString().padLeft(2, '0')}/'
           '${month.toString().padLeft(2, '0')}/'
           '$year';
  }

  /// Formata a data e hora no padrão brasileiro (dd/MM/yyyy HH:mm)
  String get toBrazilianFormatWithTime {
    return '$toBrazilianFormat '
           '${hour.toString().padLeft(2, '0')}:'
           '${minute.toString().padLeft(2, '0')}';
  }

  /// Formata apenas o horário (HH:mm)
  String get toTimeFormat {
    return '${hour.toString().padLeft(2, '0')}:'
           '${minute.toString().padLeft(2, '0')}';
  }

  /// Retorna o nome do dia da semana em português
  String get weekdayName {
    const weekdays = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];
    return weekdays[weekday - 1];
  }

  /// Retorna o nome do dia da semana abreviado em português
  String get weekdayShort {
    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return weekdays[weekday - 1];
  }

  /// Retorna o nome do mês em português
  String get monthName {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril',
      'Maio', 'Junho', 'Julho', 'Agosto',
      'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }

  /// Retorna o nome do mês abreviado em português
  String get monthShort {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr',
      'Mai', 'Jun', 'Jul', 'Ago',
      'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[month - 1];
  }

  /// Calcula a diferença em dias úteis (excluindo sábados e domingos)
  int businessDaysUntil(DateTime other) {
    if (isAfter(other)) return 0;
    
    int businessDays = 0;
    DateTime current = dateOnly;
    
    while (current.isBefore(other.dateOnly)) {
      if (current.weekday < 6) { // 1-5 = segunda a sexta
        businessDays++;
      }
      current = current.add(const Duration(days: 1));
    }
    
    return businessDays;
  }

  /// Verifica se é fim de semana
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Verifica se é dia útil
  bool get isWeekday => !isWeekend;

  /// Adiciona dias úteis (pula fins de semana)
  DateTime addBusinessDays(int days) {
    DateTime result = this;
    int addedDays = 0;
    
    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.isWeekday) {
        addedDays++;
      }
    }
    
    return result;
  }

  /// Retorna uma descrição relativa da data (hoje, ontem, amanhã, etc.)
  String get relativeDescription {
    if (isToday) return 'Hoje';
    if (isTomorrow) return 'Amanhã';
    if (isYesterday) return 'Ontem';
    
    final difference = DateTime.now().difference(this).inDays;
    
    if (difference > 0) {
      if (difference == 1) return 'Ontem';
      if (difference < 7) return 'Há $difference dias';
      if (difference < 30) return 'Há ${(difference / 7).floor()} semanas';
      if (difference < 365) return 'Há ${(difference / 30).floor()} meses';
      return 'Há ${(difference / 365).floor()} anos';
    } else {
      final futureDays = -difference;
      if (futureDays == 1) return 'Amanhã';
      if (futureDays < 7) return 'Em $futureDays dias';
      if (futureDays < 30) return 'Em ${(futureDays / 7).floor()} semanas';
      if (futureDays < 365) return 'Em ${(futureDays / 30).floor()} meses';
      return 'Em ${(futureDays / 365).floor()} anos';
    }
  }
}
