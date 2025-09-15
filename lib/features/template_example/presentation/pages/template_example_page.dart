import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/template_example_controller.dart';
import '../widgets/template_example_list_widget.dart';
import '../widgets/template_example_search_widget.dart';

/// Página principal da feature Template Example
/// 
/// Demonstra como implementar páginas seguindo as convenções do projeto
class TemplateExamplePage extends StatelessWidget {
  const TemplateExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Get.find<TemplateExampleController>().refreshTemplateExamples(),
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      body: GetBuilder<TemplateExampleController>(
        builder: (controller) {
          return Column(
            children: [
              // Widget de busca e filtros
              const TemplateExampleSearchWidget(),
              
              // Lista de Template Examples
              Expanded(
                child: _buildContent(controller),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.find<TemplateExampleController>().goToCreateScreen(),
        tooltip: 'Criar Template Example',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(TemplateExampleController controller) {
    if (controller.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando Template Examples...'),
          ],
        ),
      );
    }

    if (controller.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Ops! Algo deu errado',
              style: Theme.of(Get.context!).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                controller.errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(Get.context!).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                controller.clearError();
                controller.refreshTemplateExamples();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (controller.filteredTemplateExamples.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              controller.searchQuery.isNotEmpty || controller.filterByStatus != null
                  ? 'Nenhum resultado encontrado'
                  : 'Nenhum Template Example cadastrado',
              style: Theme.of(Get.context!).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              controller.searchQuery.isNotEmpty || controller.filterByStatus != null
                  ? 'Tente ajustar os filtros de busca'
                  : 'Crie seu primeiro Template Example!',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            if (controller.searchQuery.isNotEmpty || controller.filterByStatus != null)
              ElevatedButton.icon(
                onPressed: controller.clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Limpar filtros'),
              )
            else
              ElevatedButton.icon(
                onPressed: controller.goToCreateScreen,
                icon: const Icon(Icons.add),
                label: const Text('Criar Template Example'),
              ),
          ],
        ),
      );
    }

    return const TemplateExampleListWidget();
  }
}
