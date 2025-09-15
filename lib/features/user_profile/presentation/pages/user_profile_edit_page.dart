import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../controllers/user_profile_controller.dart';
import '../widgets/profile_form_section.dart';
import '../widgets/profile_image_picker.dart';

/// Página de edição do perfil do usuário
class UserProfileEditPage extends StatefulWidget {
  final String? userId;

  const UserProfileEditPage({
    super.key,
    this.userId,
  });

  @override
  State<UserProfileEditPage> createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  late final UserProfileController controller;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers dos campos
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  
  // Estado do formulário
  String? _profileImageUrl;
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    controller = Modular.get<UserProfileController>();
    
    // Verificar se já existe um perfil carregado
    if (controller.hasProfile && controller.userProfile != null) {
      _loadProfileData(controller.userProfile!);
      _isEditing = true;
    } else if (widget.userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUserProfile();
      });
    }

    // Adicionar listeners para detectar mudanças
    _addChangeListeners();
  }

  void _addChangeListeners() {
    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _stateController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    if (widget.userId != null) {
      await controller.loadUserProfile(widget.userId!);
      if (controller.hasProfile && controller.userProfile != null) {
        _loadProfileData(controller.userProfile!);
        setState(() {
          _isEditing = true;
        });
      }
    }
  }

  void _loadProfileData(UserProfileEntity profile) {
    setState(() {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _bioController.text = profile.bio ?? '';
      _phoneController.text = profile.phone ?? '';
      _addressController.text = profile.address ?? '';
      _cityController.text = profile.city ?? '';
      _stateController.text = profile.state ?? '';
      _profileImageUrl = profile.profileImageUrl;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (bool didPop) async {
        if (!didPop && _hasChanges) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Perfil' : 'Criar Perfil'),
          elevation: 0,
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _saveProfile,
                child: Obx(() => controller.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Salvar',
                        style: TextStyle(color: Colors.white),
                      )),
              ),
          ],
        ),
        body: Obx(() => _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading && !_isEditing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty && !_isEditing) {
      return _buildErrorState();
    }

    return _buildForm();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar perfil',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImageSection(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            _buildContactInfoSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            if (_isEditing && controller.userProfile?.isProfessional == true) ...[
              const SizedBox(height: 16),
              _buildProfessionalSection(),
            ],
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: ProfileImagePicker(
        imageUrl: _profileImageUrl,
        onImageChanged: (String? newImageUrl) {
          setState(() {
            _profileImageUrl = newImageUrl;
            _hasChanges = true;
          });
        },
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return ProfileFormSection(
      title: 'Informações Básicas',
      icon: Icons.person,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nome Completo *',
            hintText: 'Digite seu nome completo',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nome é obrigatório';
            }
            if (value.trim().length < 2) {
              return 'Nome deve ter pelo menos 2 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email *',
            hintText: 'seu@email.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          enabled: false, // Email não pode ser editado
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email é obrigatório';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Email inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          decoration: const InputDecoration(
            labelText: 'Biografia',
            hintText: 'Conte um pouco sobre você...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description_outlined),
          ),
          maxLines: 3,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return ProfileFormSection(
      title: 'Informações de Contato',
      icon: Icons.contact_phone,
      children: [
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Telefone',
            hintText: '(11) 99999-9999',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            // TODO: Adicionar máscara de telefone
          ],
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 10) {
              return 'Telefone deve ter pelo menos 10 dígitos';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return ProfileFormSection(
      title: 'Localização',
      icon: Icons.location_on,
      children: [
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Endereço',
            hintText: 'Rua, número, complemento',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.home_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  hintText: 'São Paulo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  hintText: 'SP',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 2,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                  UpperCaseTextFormatter(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfessionalSection() {
    return ProfileFormSection(
      title: 'Informações Profissionais',
      icon: Icons.work,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(height: 8),
              Text(
                'Informações Profissionais Avançadas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gerencie seus serviços, horários e preços na seção específica do profissional.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blue[600]),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navegar para módulo de serviços
                  Modular.to.pushNamed('/services');
                },
                icon: const Icon(Icons.build),
                label: const Text('Gerenciar Serviços'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _hasChanges ? _saveProfile : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Obx(() => controller.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(_isEditing ? 'Atualizar Perfil' : 'Criar Perfil')),
          ),
        ),
        if (_hasChanges) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _discardChanges,
              child: const Text('Descartar Alterações'),
            ),
          ),
        ],
      ],
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text(
          'Você tem alterações não salvas. Deseja descartar essas alterações?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _discardChanges() {
    if (controller.userProfile != null) {
      _loadProfileData(controller.userProfile!);
    } else {
      // Limpar campos para novo perfil
      _nameController.clear();
      _emailController.clear();
      _bioController.clear();
      _phoneController.clear();
      _addressController.clear();
      _cityController.clear();
      _stateController.clear();
      _profileImageUrl = null;
    }
    
    setState(() {
      _hasChanges = false;
    });
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final bio = _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null;
    final phone = _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null;
    final address = _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null;
    final city = _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null;
    final state = _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : null;

    bool success;

    if (_isEditing) {
      success = await controller.updateProfile(
        name: name,
        email: email,
        bio: bio,
        phone: phone,
        address: address,
        city: city,
        state: state,
      );
    } else {
      // Para criar novo perfil, precisamos do userId e userType
      // TODO: Implementar criação quando necessário
      success = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Criação de perfil ainda não implementada'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (success && mounted) {
      setState(() {
        _hasChanges = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop();
    } else if (mounted && controller.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Formatter para transformar texto em uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
