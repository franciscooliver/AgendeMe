import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// Dashboard principal do profissional com navegação para diferentes módulos
class ProfessionalDashboardScreen extends StatelessWidget {
  const ProfessionalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Profissional'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              title: 'Calendário',
              subtitle: 'Visualizar agendamentos',
              icon: Icons.calendar_today,
              color: Colors.blue,
              onTap: () => Modular.to.pushNamed('/professional/calendar'),
            ),
            _buildDashboardCard(
              title: 'Meus Clientes',
              subtitle: 'Gerenciar clientes',
              icon: Icons.people,
              color: Colors.green,
              onTap: () => Modular.to.pushNamed('/client-management/clients'),
            ),
            _buildDashboardCard(
              title: 'Meus Serviços',
              subtitle: 'Gerenciar serviços',
              icon: Icons.work,
              color: Colors.orange,
              onTap: () => Modular.to.pushNamed('/services'),
            ),
            _buildDashboardCard(
              title: 'Configurações',
              subtitle: 'Perfil e horários',
              icon: Icons.settings,
              color: Colors.purple,
              onTap: () => Modular.to.pushNamed('/professional/config'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
