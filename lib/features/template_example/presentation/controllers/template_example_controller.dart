import 'package:get/get.dart';
import '../../../../core/core.dart';
import '../../domain/entities/template_example_entity.dart';
import '../../domain/usecases/create_template_example.dart';
import '../../domain/usecases/get_all_template_examples.dart';
import '../../domain/usecases/get_template_example.dart';

/// Controller responsável pelo gerenciamento de estado da feature Template Example
/// 
/// Demonstra como implementar controllers seguindo as convenções do projeto
class TemplateExampleController extends GetxController {
  final GetTemplateExample getTemplateExample;
  final GetAllTemplateExamples getAllTemplateExamples;
  final CreateTemplateExample createTemplateExample;

  TemplateExampleController({
    required this.getTemplateExample,
    required this.getAllTemplateExamples,
    required this.createTemplateExample,
  });

  // Estado reativo
  final _templateExamples = <TemplateExampleEntity>[].obs;
  final _selectedTemplateExample = Rxn<TemplateExampleEntity>();
  final _isLoading = false.obs;
  final _isCreating = false.obs;
  final _errorMessage = ''.obs;
  final _searchQuery = ''.obs;
  final _filterByStatus = Rxn<bool>();

  // Getters para acessar o estado
  List<TemplateExampleEntity> get templateExamples => _templateExamples;
  TemplateExampleEntity? get selectedTemplateExample => _selectedTemplateExample.value;
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  String get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  bool? get filterByStatus => _filterByStatus.value;

  // Lista filtrada baseada na busca
  List<TemplateExampleEntity> get filteredTemplateExamples {
    if (searchQuery.isEmpty && filterByStatus == null) {
      return templateExamples;
    }

    var filtered = templateExamples.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus = filterByStatus == null || item.isActive == filterByStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    loadTemplateExamples();
  }

  /// Carrega todos os Template Examples
  Future<void> loadTemplateExamples() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await getAllTemplateExamples(
      const GetAllTemplateExamplesParams(),
    );

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        AppUtils.showErrorSnackbar(
          title: 'Erro',
          message: failure.message,
        );
      },
      (templateExamples) {
        _templateExamples.value = templateExamples;
      },
    );

    _isLoading.value = false;
  }

  /// Carrega um Template Example específico
  Future<void> loadTemplateExample(String id) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await getTemplateExample(id);

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        AppUtils.showErrorSnackbar(
          title: 'Erro',
          message: failure.message,
        );
      },
      (templateExample) {
        _selectedTemplateExample.value = templateExample;
      },
    );

    _isLoading.value = false;
  }

  /// Cria um novo Template Example
  Future<void> createNewTemplateExample({
    required String title,
    required String description,
  }) async {
    if (title.trim().isEmpty || description.trim().isEmpty) {
      AppUtils.showWarningSnackbar(
        title: 'Atenção',
        message: 'Preencha todos os campos obrigatórios',
      );
      return;
    }

    _isCreating.value = true;
    _errorMessage.value = '';

    final result = await createTemplateExample(
      CreateTemplateExampleParams(
        title: title.trim(),
        description: description.trim(),
      ),
    );

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        AppUtils.showErrorSnackbar(
          title: 'Erro ao criar',
          message: failure.message,
        );
      },
      (createdTemplateExample) {
        // Adiciona o novo item à lista
        _templateExamples.add(createdTemplateExample);

        AppUtils.showSuccessSnackbar(
          title: 'Sucesso',
          message: 'Template Example criado com sucesso!',
        );

        // Volta para a tela anterior
        Get.back();
      },
    );

    _isCreating.value = false;
  }

  /// Atualiza a query de busca
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  /// Atualiza o filtro por status
  void updateStatusFilter(bool? status) {
    _filterByStatus.value = status;
  }

  /// Limpa todos os filtros
  void clearFilters() {
    _searchQuery.value = '';
    _filterByStatus.value = null;
  }

  /// Atualiza a lista (pull to refresh)
  Future<void> refreshTemplateExamples() async {
    await loadTemplateExamples();
  }

  /// Seleciona um Template Example
  void selectTemplateExample(TemplateExampleEntity templateExample) {
    _selectedTemplateExample.value = templateExample;
  }

  /// Limpa a seleção
  void clearSelection() {
    _selectedTemplateExample.value = null;
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage.value = '';
  }

  /// Navega para a tela de criação
  void goToCreateScreen() {
    Get.toNamed('/template-example/create');
  }

  /// Navega para a tela de detalhes
  void goToDetailsScreen(String id) {
    Get.toNamed('/template-example/details/$id');
  }

  /// Mostra dialog de confirmação para ações destrutivas
  Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) async {
    return await AppUtils.showConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }
}
