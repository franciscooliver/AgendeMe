import 'dart:typed_data';

/// Interface abstrata para serviços de armazenamento
/// 
/// Define contratos para upload, download e gerenciamento de arquivos
/// em serviços de storage como Firebase Storage
abstract interface class IStorageService {
  /// Faz upload de um arquivo para o storage
  /// 
  /// [path] - Caminho onde o arquivo será armazenado
  /// [fileData] - Dados binários do arquivo
  /// [contentType] - Tipo de conteúdo (ex: 'image/jpeg')
  /// 
  /// Retorna a URL de download do arquivo
  Future<String> uploadFile({
    required String path,
    required Uint8List fileData,
    String? contentType,
  });

  /// Remove um arquivo do storage
  /// 
  /// [path] - Caminho do arquivo a ser removido
  Future<void> deleteFile(String path);

  /// Obtém a URL de download de um arquivo
  /// 
  /// [path] - Caminho do arquivo
  /// 
  /// Retorna a URL de download
  Future<String> getDownloadUrl(String path);

  /// Verifica se um arquivo existe
  /// 
  /// [path] - Caminho do arquivo
  /// 
  /// Retorna true se o arquivo existir
  Future<bool> fileExists(String path);
}
