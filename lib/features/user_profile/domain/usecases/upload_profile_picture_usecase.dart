import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/core.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';
import 'pick_and_compress_image_usecase.dart';

/// Use Case responsável pelo upload completo de foto de perfil
/// 
/// Orquestra todo o processo de:
/// 1. Seleção e compressão da imagem
/// 2. Upload para Firebase Storage
/// 3. Atualização do perfil do usuário no Firestore
class UploadProfilePictureUseCase extends UseCase<String, UploadProfilePictureParams> {
  final PickAndCompressImageUseCase _pickAndCompressImageUseCase;
  final IStorageService _storageService;
  final UserProfileRepository _userProfileRepository;

  UploadProfilePictureUseCase({
    required PickAndCompressImageUseCase pickAndCompressImageUseCase,
    required IStorageService storageService,
    required UserProfileRepository userProfileRepository,
  }) : _pickAndCompressImageUseCase = pickAndCompressImageUseCase,
       _storageService = storageService,
       _userProfileRepository = userProfileRepository;

  @override
  Future<Either<Failure, String>> call(UploadProfilePictureParams params) async {
    try {
      // 1. Obter usuário atual
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Left(AuthFailure(message: 'Usuário não autenticado'));
      }

      // 2. Obter perfil atual do usuário
      final Either<Failure, UserProfileEntity> profileResult = 
          await _userProfileRepository.getUserProfileByUserId(currentUser.uid);
      
      final UserProfileEntity currentProfile = profileResult.fold(
        (failure) => throw Exception('Erro ao obter perfil: ${failure.message}'),
        (profile) => profile,
      );

      // 3. Selecionar e comprimir imagem
      final Either<Failure, Uint8List> imageResult = 
          await _pickAndCompressImageUseCase(params.pickImageParams);

      if (imageResult.isLeft()) {
        return imageResult.fold(
          (failure) => Left(failure),
          (_) => Left(UnknownFailure(message: 'Erro inesperado na seleção de imagem')),
        );
      }

      final Uint8List compressedImageData = imageResult.fold(
        (_) => throw Exception('Erro inesperado'),
        (data) => data,
      );

      // 4. Deletar foto de perfil anterior se existir
      if (currentProfile.profileImageUrl != null && currentProfile.profileImageUrl!.isNotEmpty) {
        await _deleteOldProfilePicture(currentUser.uid);
      }

      // 5. Upload da nova imagem para Firebase Storage
      final String storagePath = _getStoragePath(currentUser.uid);
      final String downloadUrl = await _storageService.uploadFile(
        path: storagePath,
        fileData: compressedImageData,
        contentType: 'image/jpeg',
      );

      // 6. Atualizar perfil do usuário com nova URL
      final UserProfileEntity updatedProfile = currentProfile.copyWith(
        profileImageUrl: downloadUrl,
        updatedAt: DateTime.now(),
      );

      final Either<Failure, UserProfileEntity> updateResult = 
          await _userProfileRepository.updateUserProfile(updatedProfile);

      return updateResult.fold(
        (failure) => Left(failure),
        (_) => Right(downloadUrl),
      );

    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Erro inesperado durante upload da foto de perfil: $e'
      ));
    }
  }

  /// Deleta a foto de perfil anterior do usuário
  Future<void> _deleteOldProfilePicture(String userId) async {
    try {
      final String oldPath = _getStoragePath(userId);
      await _storageService.deleteFile(oldPath);
    } catch (e) {
      // Log do erro mas não falha o processo principal
      // A nova imagem será criada mesmo se a antiga não for deletada
    }
  }

  /// Gera o caminho de storage para a foto de perfil
  String _getStoragePath(String userId) {
    return 'users/$userId/profile_pictures/profile_picture.jpg';
  }
}

/// Parâmetros para o UseCase de upload de foto de perfil
class UploadProfilePictureParams {
  final PickImageParams pickImageParams;

  const UploadProfilePictureParams({
    required this.pickImageParams,
  });

  /// Construtor de conveniência para galeria
  UploadProfilePictureParams.fromGallery() 
    : pickImageParams = const PickImageParams(
        source: ImageSource.gallery,
        compressionConfig: ImageCompressionConfig.profilePicture(),
      );

  /// Construtor de conveniência para câmera
  UploadProfilePictureParams.fromCamera()
    : pickImageParams = const PickImageParams(
        source: ImageSource.camera,
        compressionConfig: ImageCompressionConfig.profilePicture(),
      );
}
