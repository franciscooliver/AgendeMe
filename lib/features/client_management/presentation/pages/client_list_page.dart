import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../domain/entities/client_entity.dart';
import '../controllers/client_controller.dart';

/// Página de listagem de clientes do profissional
class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  late final ClientController controller;
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Modular.get<ClientController>();
    
    // Configurar scroll infinito
    scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadClients(refresh: true);
    });
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreClients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Clientes'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showStatistics,
          ),
          PopupMenuButton<ClientSortCriteria>(
            icon: const Icon(Icons.sort),
            onSelected: (criteria) => _sortClients(criteria),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ClientSortCriteria.name,
                child: ListTile(
                  leading: Icon(Icons.sort_by_alpha),
                  title: Text('Nome'),
                ),
              ),
              const PopupMenuItem(
                value: ClientSortCriteria.lastInteraction,
                child: ListTile(
                  leading: Icon(Icons.access_time),
                  title: Text('Última Interação'),
                ),
              ),
              const PopupMenuItem(
                value: ClientSortCriteria.totalAppointments,
                child: ListTile(
                  leading: Icon(Icons.event),
                  title: Text('Total de Agendamentos'),
                ),
              ),
              const PopupMenuItem(
                value: ClientSortCriteria.totalSpent,
                child: ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('Valor Gasto'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Obx(() => _buildClientsList()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Campo de busca
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Buscar clientes por nome ou email...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Debounce da busca
              controller.searchClientsByTerm(value);
            },
          ),
          const SizedBox(height: 12),
          
          // Filtros por categoria
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Todos', ClientCategory.all),
                _buildFilterChip('Ativos', ClientCategory.active),
                _buildFilterChip('VIP ⭐', ClientCategory.vip),
                _buildFilterChip('Novos 🎉', ClientCategory.new_clients),
                _buildFilterChip('Frequentes', ClientCategory.frequent),
                _buildFilterChip('Inativos', ClientCategory.inactive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ClientCategory category) {
    return Obx(() {
      final isSelected = controller.statusFilter == _categoryToStatus(category);
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              controller.setStatusFilter(_categoryToStatus(category));
            } else {
              controller.clearFilters();
            }
          },
        ),
      );
    });
  }

  ClientStatus? _categoryToStatus(ClientCategory category) {
    switch (category) {
      case ClientCategory.active:
        return ClientStatus.active;
      case ClientCategory.vip:
        return ClientStatus.vip;
      case ClientCategory.new_clients:
        return ClientStatus.newClient;
      case ClientCategory.inactive:
        return ClientStatus.inactive;
      default:
        return null;
    }
  }

  Widget _buildClientsList() {
    if (controller.isLoading && controller.clients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (controller.clients.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadClients(refresh: true),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.clients.length + (controller.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.clients.length) {
            return controller.isLoadingMore
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink();
          }

          final client = controller.clients[index];
          return _buildClientCard(client);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.loadClients(refresh: true),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Nenhum cliente encontrado',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.isNotEmpty
                ? 'Tente ajustar sua busca'
                : 'Seus clientes aparecerão aqui após o primeiro agendamento',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(ClientEntity client) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: _buildClientAvatar(client),
        title: Row(
          children: [
            Expanded(
              child: Text(
                client.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              client.statusIcon,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.event,
                  label: '${client.totalAppointments}',
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.attach_money,
                  label: 'R\$ ${client.totalSpent.toStringAsFixed(2)}',
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.access_time,
                  label: _formatLastInteraction(client.lastInteractionDate),
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleClientAction(action, client),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Ver Detalhes'),
              ),
            ),
            const PopupMenuItem(
              value: 'contact',
              child: ListTile(
                leading: Icon(Icons.phone),
                title: Text('Contatar'),
              ),
            ),
            const PopupMenuItem(
              value: 'notes',
              child: ListTile(
                leading: Icon(Icons.note_add),
                title: Text('Adicionar Nota'),
              ),
            ),
          ],
        ),
        onTap: () => _showClientDetails(client),
      ),
    );
  }

  Widget _buildClientAvatar(ClientEntity client) {
    if (client.profileImageUrl != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(client.profileImageUrl!),
      );
    }

    return CircleAvatar(
      backgroundColor: _getStatusColor(client.status),
      child: Text(
        client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.active:
        return Colors.green;
      case ClientStatus.vip:
        return Colors.purple;
      case ClientStatus.newClient:
        return Colors.blue;
      case ClientStatus.inactive:
        return Colors.grey;
      case ClientStatus.blocked:
        return Colors.red;
    }
  }

  String _formatLastInteraction(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}sem';
    } else {
      return '${(difference.inDays / 30).floor()}mês';
    }
  }

  void _sortClients(ClientSortCriteria criteria) {
    controller.sortClients(criteria, ascending: false);
  }

  void _handleClientAction(String action, ClientEntity client) {
    switch (action) {
      case 'view':
        _showClientDetails(client);
        break;
      case 'contact':
        _contactClient(client);
        break;
      case 'notes':
        _addClientNote(client);
        break;
    }
  }

  void _showClientDetails(ClientEntity client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(client.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', client.email),
              if (client.phone != null) _buildDetailRow('Telefone', client.phone!),
              _buildDetailRow('Status', client.statusDescription),
              _buildDetailRow('Total de Agendamentos', '${client.totalAppointments}'),
              _buildDetailRow('Total Gasto', 'R\$ ${client.totalSpent.toStringAsFixed(2)}'),
              _buildDetailRow('Primeira Consulta', _formatDate(client.firstAppointmentDate)),
              _buildDetailRow('Última Interação', _formatDate(client.lastInteractionDate)),
              if (client.servicesUsed.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Serviços Utilizados:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...client.servicesUsed.map((service) => Text('• $service')),
              ],
              if (client.notes != null) ...[
                const SizedBox(height: 8),
                const Text('Observações:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(client.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _contactClient(ClientEntity client) {
    if (client.phone != null) {
      // Implementar abertura do app de telefone
      Get.snackbar(
        'Contato',
        'Funcionalidade de contato será implementada',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Sem Telefone',
        'Este cliente não possui telefone cadastrado',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _addClientNote(ClientEntity client) {
    // Implementar diálogo para adicionar nota
    Get.snackbar(
      'Notas',
      'Funcionalidade de notas será implementada',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showStatistics() {
    final stats = controller.statistics;
    if (stats == null) {
      Get.snackbar(
        'Estatísticas',
        'Carregando estatísticas...',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estatísticas dos Clientes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Total de Clientes', '${stats.totalClients}'),
            _buildStatRow('Clientes Ativos', '${stats.activeClients}'),
            _buildStatRow('Novos este Mês', '${stats.newClientsThisMonth}'),
            _buildStatRow('Clientes VIP', '${stats.vipClients}'),
            _buildStatRow('Receita Total', 'R\$ ${stats.totalRevenue.toStringAsFixed(2)}'),
            _buildStatRow('Média por Cliente', 'R\$ ${stats.averageRevenuePerClient.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
