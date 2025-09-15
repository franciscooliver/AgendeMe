import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../../core/core.dart';

/// Serviço responsável pela seleção de imagens do dispositivo
/// 
/// Utiliza o package image_picker para acessar galeria e câmera
class ImagePickerService {
  final ImagePicker _imagePicker;

  ImagePickerService({ImagePicker? imagePicker}) 
    : _imagePicker = imagePicker ?? ImagePicker();

  /// Seleciona uma imagem da galeria
  /// 
  /// Retorna o arquivo da imagem selecionada ou null se cancelado
  /// Lança [ImageSelectionException] em caso de erro
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Qualidade máxima - compressão será feita depois
      );

      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      throw ImageSelectionException(
        'Erro ao selecionar imagem da galeria: $e'
      );
    }
  }

  /// Seleciona uma imagem da câmera
  /// 
  /// Retorna o arquivo da imagem capturada ou null se cancelado
  /// Lança [ImageSelectionException] em caso de erro
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // Qualidade máxima - compressão será feita depois
      );

      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      throw ImageSelectionException(
        'Erro ao capturar imagem da câmera: $e'
      );
    }
  }

  /// Permite ao usuário escolher entre galeria ou câmera
  /// 
  /// [showCameraOption] - Se true, mostra opção de câmera (padrão: true)
  /// Retorna o arquivo da imagem selecionada ou null se cancelado
  Future<File?> pickImage({bool showCameraOption = true}) async {
    // Por padrão, vamos usar a galeria
    // A escolha entre galeria/câmera será implementada na UI
    return await pickImageFromGallery();
  }
}
