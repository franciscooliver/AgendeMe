import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';

import '../../../../core/core.dart';
import '../../data/services/image_picker_service.dart';
import '../../data/services/image_compressor_service.dart';

/// Use Case responsável por orquestrar seleção e compressão de imagem
/// 
/// Implementa o fluxo completo de:
/// 1. Seleção da imagem (galeria ou câmera)
/// 2. Compressão da imagem para otimizar upload
class PickAndCompressImageUseCase extends UseCase<Uint8List, PickImageParams> {
  final ImagePickerService _imagePickerService;
  final ImageCompressorService _imageCompressorService;

  PickAndCompressImageUseCase({
    required ImagePickerService imagePickerService,
    required ImageCompressorService imageCompressorService,
  }) : _imagePickerService = imagePickerService,
       _imageCompressorService = imageCompressorService;

  @override
  Future<Either<Failure, Uint8List>> call(PickImageParams params) async {
    try {
      // 1. Selecionar imagem
      final File? imageFile = await _selectImage(params.source);
      
      if (imageFile == null) {
        return Left(ImageSelectionFailure(message: 'Nenhuma imagem foi selecionada'));
      }

      // 2. Comprimir imagem
      final Uint8List compressedData = await _compressImage(
        imageFile, 
        params.compressionConfig,
      );

      return Right(compressedData);

    } on ImageSelectionException catch (e) {
      return Left(ImageSelectionFailure(message: e.message));
    } on ImageCompressionException catch (e) {
      return Left(ImageCompressionFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Erro inesperado durante processamento da imagem: $e'));
    }
  }

  /// Seleciona imagem baseado na fonte especificada
  Future<File?> _selectImage(ImageSource source) async {
    switch (source) {
      case ImageSource.gallery:
        return await _imagePickerService.pickImageFromGallery();
      case ImageSource.camera:
        return await _imagePickerService.pickImageFromCamera();
      case ImageSource.both:
        // Por enquanto, usa galeria como padrão
        // A lógica de escolha será implementada na UI
        return await _imagePickerService.pickImageFromGallery();
    }
  }

  /// Comprime imagem usando configuração fornecida
  Future<Uint8List> _compressImage(
    File imageFile, 
    ImageCompressionConfig config,
  ) async {
    if (config.useProfilePictureDefaults) {
      return await _imageCompressorService.compressProfilePicture(imageFile);
    }

    return await _imageCompressorService.compressImage(
      imageFile,
      maxWidth: config.maxWidth,
      maxHeight: config.maxHeight,
      quality: config.quality,
    );
  }
}

/// Parâmetros para o UseCase de seleção e compressão de imagem
class PickImageParams {
  final ImageSource source;
  final ImageCompressionConfig compressionConfig;

  const PickImageParams({
    required this.source,
    this.compressionConfig = const ImageCompressionConfig.profilePicture(),
  });
}

/// Configuração para compressão de imagem
class ImageCompressionConfig {
  final int maxWidth;
  final int maxHeight;
  final int quality;
  final bool useProfilePictureDefaults;

  const ImageCompressionConfig({
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
    this.useProfilePictureDefaults = false,
  });

  /// Configuração padrão otimizada para fotos de perfil
  const ImageCompressionConfig.profilePicture()
    : maxWidth = 512,
      maxHeight = 512,
      quality = 85,
      useProfilePictureDefaults = true;

  /// Configuração para imagens de alta qualidade
  const ImageCompressionConfig.highQuality()
    : maxWidth = 1080,
      maxHeight = 1080,
      quality = 90,
      useProfilePictureDefaults = false;

  /// Configuração para compressão máxima
  const ImageCompressionConfig.maxCompression()
    : maxWidth = 400,
      maxHeight = 400,
      quality = 70,
      useProfilePictureDefaults = false;
}

/// Enum para fonte de seleção de imagem
enum ImageSource {
  gallery,
  camera,
  both, // Permite escolha entre galeria e câmera na UI
}

/// Failures específicos para operações de imagem
class ImageSelectionFailure extends Failure {
  const ImageSelectionFailure({required super.message, super.code, super.details});
}

class ImageCompressionFailure extends Failure {
  const ImageCompressionFailure({required super.message, super.code, super.details});
}
