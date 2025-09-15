import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../domain/entities/service_entity.dart';
import '../controllers/service_controller.dart';

/// Página de formulário para adicionar/editar serviços
class ServiceFormPage extends StatefulWidget {
  final String? serviceId;

  const ServiceFormPage({
    super.key,
    this.serviceId,
  });

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  late final ServiceController controller;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers dos campos
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedCategory = ServiceCategories.all.first;
  bool _isActive = true;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    controller = Modular.get<ServiceController>();
    _isEditMode = widget.serviceId != null;
    
    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadServiceData();
      });
    }
  }

  void _loadServiceData() async {
    if (widget.serviceId != null) {
      await controller.loadServiceById(widget.serviceId!);
      final service = controller.currentService;
      
      if (service != null) {
        setState(() {
          _nameController.text = service.name;
          _descriptionController.text = service.description;
          _durationController.text = service.duration.toString();
          _priceController.text = service.price.toStringAsFixed(2);
          _notesController.text = service.notes ?? '';
          _selectedCategory = service.category;
          _isActive = service.isActive;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Serviço' : 'Novo Serviço'),
        elevation: 0,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Obx(() => _buildBody()),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() => ElevatedButton(
            onPressed: controller.isSubmitting ? null : _saveService,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: controller.isSubmitting
                ? const CircularProgressIndicator()
                : Text(_isEditMode ? 'Atualizar Serviço' : 'Criar Serviço'),
          )),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty && _isEditMode) {
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
              onPressed: _loadServiceData,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDurationField()),
                const SizedBox(width: 16),
                Expanded(child: _buildPriceField()),
              ],
            ),
            const SizedBox(height: 16),
            _buildNotesField(),
            if (_isEditMode) ...[
              const SizedBox(height: 16),
              _buildActiveSwitch(),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nome do Serviço *',
        hintText: 'Ex: Corte de Cabelo Masculino',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nome do serviço é obrigatório';
        }
        if (value.trim().length < 3) {
          return 'Nome deve ter pelo menos 3 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descrição *',
        hintText: 'Descreva detalhes do serviço...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Descrição é obrigatória';
        }
        if (value.trim().length < 10) {
          return 'Descrição deve ter pelo menos 10 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Categoria *',
        border: OutlineInputBorder(),
      ),
      items: ServiceCategories.all.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Categoria é obrigatória';
        }
        return null;
      },
    );
  }

  Widget _buildDurationField() {
    return TextFormField(
      controller: _durationController,
      decoration: const InputDecoration(
        labelText: 'Duração (min) *',
        hintText: '60',
        border: OutlineInputBorder(),
        suffixText: 'min',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Duração é obrigatória';
        }
        final duration = int.tryParse(value);
        if (duration == null || duration <= 0) {
          return 'Duração deve ser maior que 0';
        }
        if (duration > 480) { // 8 horas
          return 'Duração máxima é 480 minutos';
        }
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: const InputDecoration(
        labelText: 'Preço (R\$) *',
        hintText: '50,00',
        border: OutlineInputBorder(),
        prefixText: 'R\$ ',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Preço é obrigatório';
        }
        final price = double.tryParse(value);
        if (price == null || price < 0) {
          return 'Preço deve ser um valor válido';
        }
        if (price > 9999.99) {
          return 'Preço máximo é R\$ 9999,99';
        }
        return null;
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Observações (opcional)',
        hintText: 'Informações adicionais sobre o serviço...',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }

  Widget _buildActiveSwitch() {
    return SwitchListTile(
      title: const Text('Serviço Ativo'),
      subtitle: Text(_isActive 
          ? 'Serviço disponível para agendamento' 
          : 'Serviço indisponível para agendamento'),
      value: _isActive,
      onChanged: (value) {
        setState(() {
          _isActive = value;
        });
      },
    );
  }

  void _saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    controller.clearMessages();

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final duration = int.parse(_durationController.text);
    final price = double.parse(_priceController.text);
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    // TODO: Obter professionalId do contexto do usuário logado
    const String professionalId = 'temp-professional-id';

    bool success;
    
    if (_isEditMode && widget.serviceId != null) {
      success = await controller.updateService(
        serviceId: widget.serviceId!,
        professionalId: professionalId,
        name: name,
        description: description,
        category: _selectedCategory,
        duration: duration,
        price: price,
        isActive: _isActive,
        notes: notes,
      );
    } else {
      success = await controller.createService(
        professionalId: professionalId,
        name: name,
        description: description,
        category: _selectedCategory,
        duration: duration,
        price: price,
        notes: notes,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.successMessage),
          backgroundColor: Colors.green,
        ),
      );
      Modular.to.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation() {
    final service = controller.currentService;
    if (service == null) return;

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
              _deleteService();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _deleteService() async {
    if (widget.serviceId == null) return;

    final success = await controller.removeService(widget.serviceId!);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.successMessage),
          backgroundColor: Colors.green,
        ),
      );
      Modular.to.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
