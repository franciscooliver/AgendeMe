import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../../user_profile/presentation/controllers/user_profile_controller.dart';
import '../../../services/presentation/controllers/service_controller.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../controllers/professional_config_controller.dart';

/// Tela de configuração específica para profissionais
/// 
/// Permite configurar:
/// - Serviços oferecidos
/// - Horários de trabalho
/// - Localização
/// - Preços e configurações gerais
class ProfessionalConfigScreen extends StatefulWidget {
  const ProfessionalConfigScreen({super.key});

  @override
  State<ProfessionalConfigScreen> createState() => _ProfessionalConfigScreenState();
}

class _ProfessionalConfigScreenState extends State<ProfessionalConfigScreen> {
  late final ProfessionalConfigController controller;
  late final UserProfileController userProfileController;
  late final ServiceController serviceController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfessionalConfigController());
    userProfileController = Modular.get<UserProfileController>();
    serviceController = Modular.get<ServiceController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() async {
    // Carregar perfil do usuário atual
    await controller.loadUserProfile();
    
    // Carregar serviços do profissional
    final currentUser = userProfileController.userProfile;
    if (currentUser != null) {
      await serviceController.loadServices(currentUser.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração Profissional'),
        elevation: 0,
        actions: [
          Obx(() => controller.hasUnsavedChanges
              ? IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveConfiguration,
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return _buildErrorState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSummary(),
              const SizedBox(height: 24),
              _buildServicesSection(),
              const SizedBox(height: 24),
              _buildWorkingHoursSection(),
              const SizedBox(height: 24),
              _buildLocationSection(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        );
      }),
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
            onPressed: _loadInitialData,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummary() {
    final profile = controller.userProfile;
    if (profile == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Resumo do Perfil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _navigateToEditProfile(),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar Perfil'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: profile.profileImageUrl != null
                      ? NetworkImage(profile.profileImageUrl!)
                      : null,
                  child: profile.profileImageUrl == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (profile.phone != null && profile.phone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              profile.phone!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                      if (profile.address != null && profile.address!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                profile.address!,
                                style: const TextStyle(color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (profile.bio != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          profile.bio!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meus Serviços',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => Modular.to.pushNamed('/services/add'),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final services = serviceController.activeServices;
              
              if (serviceController.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (services.isEmpty) {
                return _buildEmptyServicesState();
              }
              
              return Column(
                children: services.map((service) => _buildServiceItem(service)).toList(),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Modular.to.pushNamed('/services'),
                icon: const Icon(Icons.manage_accounts),
                label: const Text('Gerenciar Todos os Serviços'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyServicesState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.work_outline, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'Nenhum serviço cadastrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seus primeiros serviços para começar a receber agendamentos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Modular.to.pushNamed('/services/add'),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Primeiro Serviço'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ServiceEntity service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: service.isActive ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Modular.to.pushNamed('/services/${service.id}/edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Horários de Trabalho',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
              children: controller.workingDays.entries.map((entry) {
                return _buildWorkingDayItem(entry.key, entry.value);
              }).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingDayItem(String day, Map<String, dynamic> dayConfig) {
    final isEnabled = dayConfig['enabled'] as bool;
    final startTime = dayConfig['start'] as String?;
    final endTime = dayConfig['end'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: isEnabled ? null : Colors.grey[50],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isEnabled ? null : Colors.grey,
              ),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) => controller.updateWorkingDay(day, value),
          ),
          if (isEnabled) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(day, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(startTime ?? '08:00'),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('às'),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(day, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(endTime ?? '18:00'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Localização',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.addressController,
              decoration: const InputDecoration(
                labelText: 'Endereço Completo',
                hintText: 'Rua, número, bairro...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              onChanged: (value) => controller.onAddressChanged(value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: controller.cityController,
                    decoration: const InputDecoration(
                      labelText: 'Cidade',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => controller.onCityChanged(value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: controller.stateController,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => controller.onStateChanged(value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.hasUnsavedChanges && !controller.isSaving
            ? _saveConfiguration
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: controller.isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Salvar Configurações',
                style: TextStyle(fontSize: 16),
              ),
      ),
    ));
  }

  void _selectTime(String day, bool isStartTime) async {
    final currentTime = controller.getTimeForDay(day, isStartTime);
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (selectedTime != null) {
      controller.updateWorkingTime(day, selectedTime, isStartTime);
    }
  }

  void _navigateToEditProfile() {
    final currentUser = userProfileController.userProfile;
    if (currentUser != null) {
      Modular.to.pushNamed(
        '/user-profile/profile/edit',
        arguments: {'userId': currentUser.userId},
      ).then((_) {
        // Recarregar dados após edição
        _loadInitialData();
      });
    }
  }

  void _saveConfiguration() async {
    final success = await controller.saveConfiguration();
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    Get.delete<ProfessionalConfigController>();
    super.dispose();
  }
}
