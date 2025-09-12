import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Interface abstrata para todos os casos de uso da aplicação
/// 
/// [T] é o tipo de retorno do caso de uso
/// [Params] é o tipo dos parâmetros necessários para executar o caso de uso
abstract class UseCase<T, Params> {
  /// Executa o caso de uso e retorna um [Either] com [Failure] ou [T]
  /// 
  /// O lado esquerdo [Left] representa uma falha [Failure]
  /// O lado direito [Right] representa o sucesso com o resultado [T]
  Future<Either<Failure, T>> call(Params params);
}

/// Interface para casos de uso síncronos
/// 
/// [T] é o tipo de retorno do caso de uso
/// [Params] é o tipo dos parâmetros necessários para executar o caso de uso
abstract class SyncUseCase<T, Params> {
  /// Executa o caso de uso de forma síncrona e retorna um [Either] com [Failure] ou [T]
  Either<Failure, T> call(Params params);
}

/// Interface para casos de uso que não retornam dados (void)
/// 
/// [Params] é o tipo dos parâmetros necessários para executar o caso de uso
abstract class VoidUseCase<Params> {
  /// Executa o caso de uso e retorna um [Either] com [Failure] ou [void]
  Future<Either<Failure, void>> call(Params params);
}

/// Classe utilizada quando o caso de uso não precisa de parâmetros
class NoParams {
  const NoParams();
  
  @override
  bool operator ==(Object other) => other is NoParams;
  
  @override
  int get hashCode => 0;
}
