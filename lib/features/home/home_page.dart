import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';

import '../auth/presentation/controllers/auth_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Modular.get<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgendeMe'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final success = await authController.signOut();
              if (success) {
                Modular.to.pushReplacementNamed('/auth/login');
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.currentUser;
        
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (user != null) ...[
                        Text(
                          'Email: ${user.email}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (user.displayName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Nome: ${user.displayName}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${user.id}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              user.emailVerified 
                                  ? Icons.verified 
                                  : Icons.pending,
                              size: 16,
                              color: user.emailVerified 
                                  ? Colors.green 
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.emailVerified 
                                  ? 'Email verificado' 
                                  : 'Email não verificado',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: user.emailVerified 
                                    ? Colors.green 
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Funcionalidades em Desenvolvimento',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: const Text('Calendário Profissional'),
                  subtitle: const Text('Visualize e gerencie sua agenda'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Modular.to.pushNamed('/professional/calendar');
                  },
                ),
              ),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.green),
                  title: Text('Perfil'),
                  subtitle: Text('Edite suas informações'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.notifications, color: Colors.orange),
                  title: Text('Notificações'),
                  subtitle: Text('Configure alertas'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
              
              const Spacer(),
              
              Center(
                child: Text(
                  'Módulo de Autenticação Implementado com Sucesso! 🎉',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
