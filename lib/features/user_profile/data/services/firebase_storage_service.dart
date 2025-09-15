import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/core.dart';

/// Implementação concreta do IStorageService usando Firebase Storage
/// 
/// Responsável por todas as operações de upload, download e gestão
/// de arquivos no Firebase Storage
class FirebaseStorageService implements IStorageService {
  final FirebaseStorage _firebaseStorage;

  FirebaseStorageService({FirebaseStorage? firebaseStorage}) 
    : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadFile({
    required String path,
    required Uint8List fileData,
    String? contentType,
  }) async {
    try {
      // Validar entrada
      if (path.isEmpty) {
        throw StorageException('Caminho do arquivo não pode estar vazio');
      }
      
      if (fileData.isEmpty) {
        throw StorageException('Dados do arquivo não podem estar vazios');
      }

      // Criar referência do arquivo
      final Reference ref = _firebaseStorage.ref().child(path);
      
      // Configurar metadata se contentType foi fornecido
      SettableMetadata? metadata;
      if (contentType != null && contentType.isNotEmpty) {
        metadata = SettableMetadata(
          contentType: contentType,
          cacheControl: 'max-age=86400', // Cache por 24 horas
        );
      }

      // Fazer upload do arquivo
      final UploadTask uploadTask = metadata != null 
        ? ref.putData(fileData, metadata)
        : ref.putData(fileData);

      // Aguardar conclusão do upload
      final TaskSnapshot snapshot = await uploadTask;

      // Verificar se upload foi bem-sucedido
      if (snapshot.state != TaskState.success) {
        throw StorageException(
          'Upload falhou com estado: ${snapshot.state}',
          code: 'upload-failed',
        );
      }

      // Obter URL de download
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;

    } on FirebaseException catch (e) {
      throw StorageException(
        'Erro do Firebase Storage: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Erro inesperado durante upload: $e',
      );
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      // Validar entrada
      if (path.isEmpty) {
        throw StorageException('Caminho do arquivo não pode estar vazio');
      }

      // Criar referência e deletar arquivo
      final Reference ref = _firebaseStorage.ref().child(path);
      await ref.delete();

    } on FirebaseException catch (e) {
      // Se arquivo não existe, considerar como sucesso
      if (e.code == 'object-not-found') {
        return;
      }
      
      throw StorageException(
        'Erro do Firebase Storage ao deletar: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Erro inesperado ao deletar arquivo: $e',
      );
    }
  }

  @override
  Future<String> getDownloadUrl(String path) async {
    try {
      // Validar entrada
      if (path.isEmpty) {
        throw StorageException('Caminho do arquivo não pode estar vazio');
      }

      // Obter URL de download
      final Reference ref = _firebaseStorage.ref().child(path);
      final String downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;

    } on FirebaseException catch (e) {
      throw StorageException(
        'Erro do Firebase Storage ao obter URL: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Erro inesperado ao obter URL de download: $e',
      );
    }
  }

  @override
  Future<bool> fileExists(String path) async {
    try {
      // Validar entrada
      if (path.isEmpty) {
        return false;
      }

      // Tentar obter metadata do arquivo
      final Reference ref = _firebaseStorage.ref().child(path);
      await ref.getMetadata();
      
      return true;

    } on FirebaseException catch (e) {
      // Se arquivo não existe, retornar false
      if (e.code == 'object-not-found') {
        return false;
      }
      
      // Para outros erros, re-lançar exception
      throw StorageException(
        'Erro do Firebase Storage ao verificar existência: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Erro inesperado ao verificar existência do arquivo: $e',
      );
    }
  }

  /// Método auxiliar para gerar caminho de foto de perfil
  /// 
  /// [userId] - ID do usuário
  /// [fileName] - Nome do arquivo (opcional, padrão: 'profile_picture.jpg')
  /// 
  /// Retorna: 'users/{userId}/profile_pictures/{fileName}'
  static String getProfilePicturePath(String userId, {String fileName = 'profile_picture.jpg'}) {
    return 'users/$userId/profile_pictures/$fileName';
  }

  /// Método auxiliar para obter informações de metadata do arquivo
  /// 
  /// [path] - Caminho do arquivo no Firebase Storage
  /// 
  /// Retorna mapa com informações do arquivo
  Future<Map<String, dynamic>> getFileMetadata(String path) async {
    try {
      final Reference ref = _firebaseStorage.ref().child(path);
      final FullMetadata metadata = await ref.getMetadata();
      
      return {
        'name': metadata.name,
        'bucket': metadata.bucket,
        'fullPath': metadata.fullPath,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
        'md5Hash': metadata.md5Hash,
        'customMetadata': metadata.customMetadata,
      };

    } on FirebaseException catch (e) {
      throw StorageException(
        'Erro ao obter metadata: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw StorageException(
        'Erro inesperado ao obter metadata: $e',
      );
    }
  }
}
