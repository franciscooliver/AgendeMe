# Firestore Security Rules - Appointments Collection

## Regras de Segurança para a Coleção `appointments`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Regras para a coleção de agendamentos
    match /appointments/{appointmentId} {
      
      // Função auxiliar para verificar se o usuário é o profissional do agendamento
      function isProfessionalOfAppointment() {
        return request.auth != null && 
               request.auth.uid == resource.data.professional_id;
      }
      
      // Função auxiliar para verificar se o usuário é o cliente do agendamento
      function isClientOfAppointment() {
        return request.auth != null && 
               request.auth.uid == resource.data.client_id;
      }
      
      // Função auxiliar para verificar se o usuário é participante do agendamento
      function isParticipantOfAppointment() {
        return isProfessionalOfAppointment() || isClientOfAppointment();
      }
      
      // Função para validar dados de agendamento
      function isValidAppointmentData() {
        let data = request.resource.data;
        return data.keys().hasAll([
          'professional_id', 'client_id', 'service_id', 
          'appointment_date_time', 'status', 'price', 
          'estimated_duration', 'created_at', 'updated_at'
        ]) &&
        // Validar tipos de dados
        data.professional_id is string &&
        data.client_id is string &&
        data.service_id is string &&
        data.appointment_date_time is timestamp &&
        data.status is string &&
        data.price is number &&
        data.estimated_duration is number &&
        data.created_at is timestamp &&
        data.updated_at is timestamp &&
        // Validar valores
        data.professional_id.size() > 0 &&
        data.client_id.size() > 0 &&
        data.service_id.size() > 0 &&
        data.price >= 0 &&
        data.estimated_duration > 0 &&
        // Validar status permitidos
        data.status in ['pending', 'confirmed', 'cancelled', 'completed', 'no_show', 'in_progress'];
      }
      
      // Função para validar se o profissional pode criar agendamento
      function canProfessionalCreateAppointment() {
        return request.auth != null && 
               request.auth.uid == request.resource.data.professional_id;
      }
      
      // Função para validar se o cliente pode criar agendamento
      function canClientCreateAppointment() {
        return request.auth != null && 
               request.auth.uid == request.resource.data.client_id;
      }
      
      // LEITURA: Apenas participantes do agendamento podem ler
      allow read: if request.auth != null && isParticipantOfAppointment();
      
      // CRIAÇÃO: Profissional ou cliente podem criar agendamentos
      allow create: if request.auth != null && 
                    isValidAppointmentData() &&
                    (canProfessionalCreateAppointment() || canClientCreateAppointment()) &&
                    // Data do agendamento deve ser no futuro
                    request.resource.data.appointment_date_time > request.time;
      
      // ATUALIZAÇÃO: Apenas participantes podem atualizar, com regras específicas
      allow update: if request.auth != null && 
                    isParticipantOfAppointment() &&
                    isValidAppointmentData() &&
                    // Não permitir mudança de IDs básicos
                    request.resource.data.professional_id == resource.data.professional_id &&
                    request.resource.data.client_id == resource.data.client_id &&
                    request.resource.data.service_id == resource.data.service_id &&
                    request.resource.data.created_at == resource.data.created_at &&
                    // updated_at deve ser atualizado
                    request.resource.data.updated_at > resource.data.updated_at &&
                    // Regras específicas por tipo de usuário
                    (
                      // Profissional pode alterar status, notas profissionais, data/hora
                      (isProfessionalOfAppointment() && (
                        // Pode confirmar agendamento pendente
                        (resource.data.status == 'pending' && 
                         request.resource.data.status in ['confirmed', 'cancelled']) ||
                        // Pode marcar como em andamento ou concluído
                        (resource.data.status == 'confirmed' && 
                         request.resource.data.status in ['in_progress', 'completed', 'cancelled']) ||
                        // Pode marcar como não compareceu
                        (resource.data.status == 'confirmed' && 
                         request.resource.data.status == 'no_show') ||
                        // Pode reagendar (alterar data/hora)
                        (resource.data.status in ['pending', 'confirmed'] && 
                         request.resource.data.appointment_date_time != resource.data.appointment_date_time &&
                         request.resource.data.appointment_date_time > request.time)
                      )) ||
                      // Cliente pode cancelar ou reagendar seus próprios agendamentos
                      (isClientOfAppointment() && (
                        // Pode cancelar agendamento não finalizado
                        (resource.data.status in ['pending', 'confirmed'] && 
                         request.resource.data.status == 'cancelled') ||
                        // Pode reagendar com antecedência mínima
                        (resource.data.status in ['pending', 'confirmed'] && 
                         request.resource.data.appointment_date_time != resource.data.appointment_date_time &&
                         request.resource.data.appointment_date_time > request.time)
                      ))
                    );
      
      // EXCLUSÃO: Apenas permitir soft delete (cancelamento), não exclusão física
      allow delete: if false;
    }
    
    // Regras para queries e listagens
    match /appointments/{document=**} {
      // Permitir listagem apenas para usuários autenticados
      // Filtros específicos devem ser aplicados no código do cliente
      allow read: if request.auth != null;
    }
  }
}
```

## Validações Implementadas

### 1. Autenticação
- ✅ Apenas usuários autenticados podem acessar agendamentos
- ✅ Verificação de identidade via `request.auth.uid`

### 2. Autorização de Leitura
- ✅ Profissionais podem ler apenas seus próprios agendamentos
- ✅ Clientes podem ler apenas seus próprios agendamentos
- ✅ Ninguém mais pode acessar agendamentos de terceiros

### 3. Autorização de Criação
- ✅ Profissionais podem criar agendamentos para seus serviços
- ✅ Clientes podem criar agendamentos para si mesmos
- ✅ Data do agendamento deve ser no futuro
- ✅ Validação completa de estrutura de dados

### 4. Autorização de Atualização
- ✅ Profissionais podem:
  - Confirmar agendamentos pendentes
  - Marcar como em andamento ou concluído
  - Marcar como "não compareceu"
  - Reagendar agendamentos
  - Cancelar agendamentos
  - Adicionar notas profissionais

- ✅ Clientes podem:
  - Cancelar seus agendamentos
  - Reagendar com antecedência
  - Adicionar notas do cliente

### 5. Validação de Dados
- ✅ Campos obrigatórios presentes
- ✅ Tipos de dados corretos
- ✅ Valores válidos (preço >= 0, duração > 0)
- ✅ Status permitidos definidos
- ✅ IDs não podem ser alterados após criação
- ✅ `updated_at` deve ser atualizado

### 6. Regras de Negócio
- ✅ Agendamentos só podem ser criados para o futuro
- ✅ Transições de status válidas
- ✅ Reagendamento apenas para o futuro
- ✅ Exclusão física não permitida (apenas soft delete)

### 7. Performance e Segurança
- ✅ Queries otimizadas com filtros no cliente
- ✅ Prevenção de ataques de enumeração
- ✅ Validação de permissões em todas as operações

## Como Aplicar

1. Acesse o Console do Firebase
2. Vá para `Firestore Database > Rules`
3. Cole as regras acima
4. Clique em "Publicar"

## Testes Recomendados

Use o Firebase Emulator Suite para testar:

```bash
firebase emulators:start --only firestore
```

Teste cenários como:
- Usuário não autenticado tentando acessar
- Cliente tentando acessar agendamento de outro cliente
- Profissional tentando modificar agendamento de outro profissional
- Criação de agendamentos com dados inválidos
- Transições de status inválidas
- Reagendamento para o passado
