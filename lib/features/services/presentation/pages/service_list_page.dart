import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/service_entity.dart';
import '../controllers/service_controller.dart';

/// Página de listagem de serviços do profissional
class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  ServiceController? controller;
  AuthController? authController;
  String searchQuery = '';
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    print('🔍 DEBUG: Iniciando _initializeControllers');
    try {
      print('🔍 DEBUG: Tentando obter ServiceController...');
      controller = Modular.get<ServiceController>();
      print('🔍 DEBUG: ServiceController obtido com sucesso');
      
      print('🔍 DEBUG: Tentando obter AuthController...');
      authController = Modular.get<AuthController>();
      print('🔍 DEBUG: AuthController obtido com sucesso');
      
      print('🔍 DEBUG: Chamando _loadServices...');
      _loadServices();
      
      // Forçar rebuild da UI após inicialização
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('🔍 DEBUG: Erro ao obter controllers: $e');
      print('🔍 DEBUG: Stack trace: ${StackTrace.current}');
      
      // Tentar novamente após um pequeno delay
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          print('🔍 DEBUG: Tentativa de retry - obtendo controllers...');
          controller = Modular.get<ServiceController>();
          authController = Modular.get<AuthController>();
          print('🔍 DEBUG: Retry bem-sucedido, chamando _loadServices...');
          _loadServices();
          
          // Forçar rebuild da UI após retry
          if (mounted) {
            setState(() {});
          }
        } catch (e2) {
          print('🔍 DEBUG: Erro persistente ao obter controllers: $e2');
          print('🔍 DEBUG: Stack trace retry: ${StackTrace.current}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao carregar serviços: $e2'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    }
  }

  void _loadServices() {
    print('🔍 DEBUG: _loadServices iniciado');
    
    if (controller == null || authController == null) {
      print('🔍 DEBUG: Controllers não inicializados ainda');
      return;
    }
    
    print('🔍 DEBUG: Controllers inicializados, obtendo currentUser...');
    final currentUser = authController!.currentUser;
    print('🔍 DEBUG: currentUser: $currentUser');
    
    if (currentUser != null) {
      print('🔍 DEBUG: Usuário encontrado, chamando controller.loadServices com ID: ${currentUser.id}');
      controller!.loadServices(currentUser.id).then((_) {
        print('🔍 DEBUG: loadServices completado');
        // Forçar rebuild da UI após carregamento
        if (mounted) {
          setState(() {});
        }
      }).catchError((error) {
        print('🔍 DEBUG: Erro em loadServices: $error');
        // Forçar rebuild da UI mesmo em caso de erro
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      print('🔍 DEBUG: Usuário não autenticado');
      // Se não há usuário logado, mostrar erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não autenticado'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Serviços'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Modular.to.pushNamed('/services/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: controller != null 
                ? Obx(() => _buildServicesList())
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Campo de busca
          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar serviços...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          
          // Filtro por categoria
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('Todos', ''),
                ...ServiceCategories.all.map(
                  (category) => _buildCategoryChip(category, category),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedCategory = selected ? value : '';
          });
        },
      ),
    );
  }

  Widget _buildServicesList() {
    if (controller?.isLoading ?? false) {
      return const Center(child: CircularProgressIndicator());
    }

    if ((controller?.errorMessage ?? '').isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              controller?.errorMessage ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadServices,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    final filteredServices = _getFilteredServices();

    if (filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum serviço encontrado',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione seus primeiros serviços para começar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Modular.to.pushNamed('/services/add'),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Serviço'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadServices(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredServices.length,
        itemBuilder: (context, index) {
          final service = filteredServices[index];
          return _buildServiceCard(service);
        },
      ),
    );
  }

  List<ServiceEntity> _getFilteredServices() {
    List<ServiceEntity> services = controller?.services ?? [];

    // Filtrar por categoria
    if (selectedCategory.isNotEmpty) {
      services = services.where((s) => s.category == selectedCategory).toList();
    }

    // Filtrar por busca
    if (searchQuery.isNotEmpty) {
      services = controller?.searchServicesByName(searchQuery) ?? [];
    }

    return services;
  }

  Widget _buildServiceCard(ServiceEntity service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: service.isActive ? Colors.green : Colors.grey,
          child: Icon(
            Icons.work,
            color: Colors.white,
          ),
        ),
        title: Text(
          service.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: service.isActive ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    service.category,
                    style: const TextStyle(fontSize: 12),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Text(
                  service.formattedPrice,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                Text(
                  service.formattedDuration,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleServiceAction(action, service),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
              ),
            ),
            PopupMenuItem(
              value: service.isActive ? 'deactivate' : 'activate',
              child: ListTile(
                leading: Icon(service.isActive ? Icons.visibility_off : Icons.visibility),
                title: Text(service.isActive ? 'Desativar' : 'Ativar'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Excluir', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
        onTap: () => _showServiceDetails(service),
      ),
    );
  }

  void _handleServiceAction(String action, ServiceEntity service) {
    switch (action) {
      case 'edit':
        Modular.to.pushNamed('/services/${service.id}/edit');
        break;
      case 'activate':
      case 'deactivate':
        _toggleServiceStatus(service);
        break;
      case 'delete':
        _showDeleteConfirmation(service);
        break;
    }
  }

  void _toggleServiceStatus(ServiceEntity service) async {
    if (authController == null) return;
    
    final currentUser = authController!.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (controller == null) return;
    
    final success = await controller!.updateService(
      serviceId: service.id,
      professionalId: currentUser.id,
      name: service.name,
      description: service.description,
      category: service.category,
      duration: service.duration,
      price: service.price,
      isActive: !service.isActive,
      notes: service.notes,
      imageUrl: service.imageUrl,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller?.successMessage ?? 'Sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller?.errorMessage ?? 'Erro'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(ServiceEntity service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o serviço "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteService(service);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _deleteService(ServiceEntity service) async {
    if (controller == null) return;
    
    final success = await controller!.removeService(service.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller?.successMessage ?? 'Sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller?.errorMessage ?? 'Erro'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showServiceDetails(ServiceEntity service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Categoria: ${service.category}'),
              const SizedBox(height: 8),
              Text('Descrição: ${service.description}'),
              const SizedBox(height: 8),
              Text('Duração: ${service.formattedDuration}'),
              const SizedBox(height: 8),
              Text('Preço: ${service.formattedPrice}'),
              const SizedBox(height: 8),
              Text('Status: ${service.isActive ? "Ativo" : "Inativo"}'),
              if (service.notes != null && service.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Observações: ${service.notes}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Modular.to.pushNamed('/services/${service.id}/edit');
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }
}
