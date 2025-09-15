import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

import '../../../../core/core.dart';

/// Serviço responsável pela compressão de imagens
/// 
/// Utiliza o package flutter_image_compress para otimizar imagens
class ImageCompressorService {
  
  /// Comprime uma imagem para otimizar upload
  /// 
  /// [imageFile] - Arquivo da imagem a ser comprimida
  /// [maxWidth] - Largura máxima da imagem (padrão: 800px)
  /// [maxHeight] - Altura máxima da imagem (padrão: 800px)
  /// [quality] - Qualidade da compressão 0-100 (padrão: 80)
  /// 
  /// Retorna os dados binários da imagem comprimida
  /// Lança [ImageCompressionException] em caso de erro
  Future<Uint8List> compressImage(
    File imageFile, {
    int maxWidth = 800,
    int maxHeight = 800,
    int quality = 80,
  }) async {
    try {
      // Validar parâmetros
      if (quality < 0 || quality > 100) {
        throw ImageCompressionException(
          'Qualidade deve estar entre 0 e 100. Valor fornecido: $quality'
        );
      }

      if (maxWidth <= 0 || maxHeight <= 0) {
        throw ImageCompressionException(
          'Dimensões devem ser positivas. Fornecido: ${maxWidth}x$maxHeight'
        );
      }

      // Verificar se o arquivo existe
      if (!await imageFile.exists()) {
        throw ImageCompressionException(
          'Arquivo de imagem não encontrado: ${imageFile.path}'
        );
      }

      // Comprimir a imagem
      final Uint8List? compressedData = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
        format: CompressFormat.jpeg, // Sempre JPEG para melhor compressão
      );

      if (compressedData == null) {
        throw ImageCompressionException(
          'Falha na compressão da imagem: resultado nulo'
        );
      }

      return compressedData;
    } catch (e) {
      if (e is ImageCompressionException) {
        rethrow;
      }
      throw ImageCompressionException(
        'Erro inesperado durante compressão: $e'
      );
    }
  }

  /// Comprime uma imagem com configurações otimizadas para foto de perfil
  /// 
  /// [imageFile] - Arquivo da imagem a ser comprimida
  /// 
  /// Retorna os dados binários da imagem comprimida
  Future<Uint8List> compressProfilePicture(File imageFile) async {
    return compressImage(
      imageFile,
      maxWidth: 512,  // Tamanho ideal para foto de perfil
      maxHeight: 512,
      quality: 85,    // Qualidade alta mas com boa compressão
    );
  }

  /// Obtém informações sobre a imagem original
  /// 
  /// [imageFile] - Arquivo da imagem
  /// 
  /// Retorna mapa com informações da imagem
  Future<Map<String, dynamic>> getImageInfo(File imageFile) async {
    try {
      final fileStat = await imageFile.stat();
      final extension = path.extension(imageFile.path).toLowerCase();
      
      return {
        'filePath': imageFile.path,
        'fileName': path.basename(imageFile.path),
        'fileSize': fileStat.size,
        'fileSizeKB': (fileStat.size / 1024).round(),
        'fileSizeMB': (fileStat.size / (1024 * 1024)).toStringAsFixed(2),
        'extension': extension,
        'lastModified': fileStat.modified,
      };
    } catch (e) {
      throw ImageCompressionException(
        'Erro ao obter informações da imagem: $e'
      );
    }
  }
}
