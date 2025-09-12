# 📄 PRD — Agende.Me

## 🧠 Resumo Executivo
O propósito do app é permitir que profissionais autônomos realizem agendamentos.


## ❗ Problema a ser Resolvido
Autonomos e pequenos comerciantes não conseguem gerenciar seus serviços de forma profissional


## 🎯 Objetivo da Solução
permitir que profissionais autônomos realizem agendamentos por meio de um aplicativo de gestão


## 👥 Público-Alvo
profissionais autônomos e pequenos comércios


## ⚙️ Funcionalidades Principais
- Divisão de Perfis (Cliente e Profissiional)
- Autenticação
- Gestão de Perfil
- Agenda e Agendamentos
- Gestão de Clientes (Profissional)
- Notificações
- Painel Financeiro
- Gestão de Serviços (Profissional)
- Pagamento (Versão Simples)
- Configurações

## 🔄 Fluxo de Usuário (User Flow)
Usuário seleciona qual tipo de usuario (Cliente ou Profissional), realiza login login via e-mail/senha, se tipo usuario cliente terá acesso a
(Histórico de agendamentos, Busca por profissional (filtro por nome, serviço ou localização), Visualização de agenda disponível, Agendamento com confirmação, Notificações locais:
lembretes de agendamento, Histórico de pagamentos, Serviços contratados, Geração de QR Code Pix, Confirmação manual ou por envio de comprovante (upload), Trocar senha, Preferência de
notificações, Tema claro/escuro (opcional), Se tipo usuario Profissional, terá acesso a (gestão perfil(Nome, foto, bio, serviços, valores)), Horários de atendimento e localização, Visualização de agenda (calendário), Edição e cancelamento de agendamentos, Notificação de novos agendamentos, Cadastro automático no primeiro agendamento, Histórico de atendimentos por cliente, Contato rápido via WhatsApp, Notificações locais: lembretes de agendamento, Histórico de valores recebidos, Total de serviços realizados, Filtros por data e tipo de serviço, Visualização dos pagamentos pendentes, Marcar como recebido, Trocar senha, Preferência de notificações, Tema claro/escuro (opcional)


## 💻 Requisitos Técnicos
Plataforma: Mobile (Flutter), apenas Android e IOS
Infraestrutura: Firebase Authentication, Firebase Firestore + Storage
Banco de dados: Firebase
Bibliotecas: table_calendar (Flutter), Modular (injecao de dependencias), GetX (gerencia de estado)
Arquitetura: Escalável, limpa e baseado em padrões SOLID com componentes reutilizáveis e de fácil manutenabilidade


## 🗺️ Roadmap
MVP (1ª fase)
 Funcionalidades básicas
 Agendamentos/Gerenciamento de agendamentos
2ª fase
 Integrar com a API de pagamentos Mercado Pago ou Gerencianet
 Versão Web


## ⚠️ Considerações Éticas e Privacidade
- Dados sensí­veis tratados com criptografia
- Consentimento claro para uso de dados


## 🚨 Riscos
- Baixo retorno no início
- Baixa adesão inicial dos usuários

## 📈 Métricas de Sucesso
- Retenção de usuários após 7 dias
- Taxa de conversão do onboarding

## Padrões de nomenclatura de arquivos
- snake case

## Convenções
- Seguir padrão snake_case para nomenclatura de arquivos
- Implementar padrões SOLID em toda a arquitetura
- Manter componentes reutilizáveis e de fácil manutenção
- Documentar código complexo
- Seguir guidelines do Flutter para UI/UX
- Usar sempre return early em funções
- Matenha o código sempre o mais legível possível, sem abrir mão da qualidade e segurança.
- Evite duplicação de código, sempre que possível reutilize funções e classes.
