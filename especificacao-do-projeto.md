# Especificação do Projeto

## 1. Visão Geral

O projeto consiste em um aplicativo mobile desenvolvido em Flutter para orientar usuários que perderam o acesso à conta do Facebook. O produto atua como um assistente de recuperação, organizando informações, indicando os próximos passos e direcionando o usuário apenas para fluxos e canais oficiais da plataforma.

O aplicativo não realiza autenticação, não acessa contas e não solicita senhas, tokens ou códigos de verificação.

## 2. Problema que o Produto Resolve

Muitos usuários perdem acesso ao Facebook por motivos como senha esquecida, conta invadida, troca de telefone, perda de acesso ao e-mail ou bloqueio de segurança. O processo de recuperação costuma ser confuso, fragmentado e difícil para pessoas com pouca familiaridade técnica.

O app resolve esse problema centralizando a orientação em um fluxo simples, claro e seguro.

## 3. Objetivo do Projeto

Facilitar a recuperação de acesso ao Facebook por meio de uma experiência guiada, com linguagem simples, organização das etapas e apoio ao usuário durante todo o processo.

## 4. Escopo do Produto

### 4.1. Incluído

- Triagem do tipo de problema de acesso.
- Fluxo guiado de orientação para recuperação.
- Checklist de informações úteis antes de iniciar a recuperação.
- Links e instruções baseados em canais oficiais do Facebook.
- Perguntas frequentes com respostas simples.
- Registro local do progresso da tentativa de recuperação.

### 4.2. Não Incluído

- Login no Facebook dentro do app.
- Armazenamento de credenciais.
- Coleta de senha, token ou código de autenticação.
- Recuperação automática de conta.
- Integração não oficial com APIs do Facebook.

## 5. Público-Alvo

- Usuários leigos ou com pouca experiência técnica.
- Pessoas que tiveram conta invadida ou bloqueada.
- Usuários que perderam acesso por troca de dispositivo, e-mail ou número de telefone.
- Pequenos negócios e criadores que dependem do Facebook para trabalhar.

## 6. Personas Principais

### 6.1. Usuário Leigo

Pessoa que quer recuperar o acesso, mas não sabe por onde começar e precisa de instruções objetivas.

### 6.2. Usuário em Situação Crítica

Pessoa que suspeita de invasão, bloqueio ou perda de controle da conta e precisa agir rapidamente.

### 6.3. Pequeno Empreendedor

Pessoa que usa a conta do Facebook como canal de negócio e precisa reduzir o tempo parado sem acesso.

## 7. Jornada do Usuário

1. O usuário abre o app.
2. Informa qual é o tipo de problema enfrentado.
3. O app apresenta o fluxo de orientação mais adequado.
4. O usuário consulta o checklist e reúne as informações necessárias.
5. O app mostra os links e passos oficiais de recuperação.
6. O usuário acompanha o andamento pelo status local.
7. O usuário consulta dúvidas frequentes caso encontre bloqueios ou dúvidas.

## 8. Requisitos Funcionais

### RF01 - Identificação do tipo de problema

O sistema deve permitir que o usuário selecione o cenário de perda de acesso, como senha esquecida, conta invadida, bloqueio de segurança, e-mail inacessível ou telefone inacessível.

### RF02 - Fluxo guiado de recuperação

O sistema deve exibir um conjunto de etapas orientadas de acordo com o cenário selecionado.

### RF03 - Checklist de preparação

O sistema deve apresentar um checklist com itens úteis para a recuperação, como acesso ao e-mail, número de telefone, documentos e dispositivos já utilizados na conta.

### RF04 - Links oficiais

O sistema deve direcionar o usuário para páginas e recursos oficiais do Facebook relacionados à recuperação de conta.

### RF05 - Dúvidas frequentes

O sistema deve oferecer uma seção com perguntas frequentes e respostas objetivas.

### RF06 - Acompanhamento de status

O sistema deve permitir registrar localmente o status da tentativa de recuperação, como iniciado, em andamento, pendente e concluído.

### RF07 - Histórico local

O sistema deve armazenar localmente o histórico básico da jornada de recuperação, sem dados sensíveis.

## 9. Requisitos Não Funcionais

### RNF01 - Segurança

O aplicativo não deve solicitar ou armazenar senhas, códigos de verificação ou tokens.

### RNF02 - Privacidade

O aplicativo deve manter o mínimo possível de dados pessoais e operar com armazenamento local, quando necessário.

### RNF03 - Usabilidade

A interface deve ser simples, com texto claro, navegação curta e foco em usuários não técnicos.

### RNF04 - Compatibilidade

O aplicativo deve funcionar em dispositivos Android e iPhone.

### RNF05 - Manutenibilidade

O código deve ser organizado de forma modular para facilitar evolução futura.

### RNF06 - Desempenho

As telas principais devem carregar rapidamente e responder bem mesmo em aparelhos intermediários.

## 10. Funcionalidades da Primeira Versão

- Tela inicial com escolha do problema.
- Tela de fluxo guiado de recuperação.
- Tela de checklist.
- Tela de perguntas frequentes.
- Tela de status da recuperação.
- Abertura de links oficiais externos.

## 11. Estrutura de Telas

### 11.1. Tela Inicial

Exibe a proposta do app e atalhos para os principais cenários de recuperação.

### 11.2. Tela de Seleção de Problema

Permite ao usuário escolher o tipo de dificuldade de acesso.

### 11.3. Tela de Passo a Passo

Apresenta instruções organizadas em etapas curtas e objetivas.

### 11.4. Tela de Checklist

Lista os itens que o usuário deve reunir antes de seguir para a recuperação.

### 11.5. Tela de FAQ

Responde dúvidas comuns sobre bloqueio, invasão e recuperação.

### 11.6. Tela de Status

Mostra o progresso atual da tentativa de recuperação.

## 12. Dados do Aplicativo

### 12.1. Dados que podem ser armazenados

- Tipo de problema selecionado.
- Status da tentativa de recuperação.
- Data e hora das etapas registradas.
- Notas locais criadas pelo usuário, se houver.

### 12.2. Dados que não podem ser armazenados

- Senhas.
- Códigos de autenticação.
- Tokens de acesso.
- Credenciais de login.

## 13. Critérios de Aceite

- O usuário consegue identificar seu cenário de perda de acesso.
- O app apresenta instruções claras e consistentes com fluxos oficiais.
- O app não pede dados sensíveis.
- O usuário consegue acompanhar o status da recuperação localmente.
- As telas funcionam de forma estável em Android e iPhone.

## 14. Riscos e Limitações

- Mudanças nos fluxos oficiais do Facebook podem exigir atualização do conteúdo.
- O aplicativo não garante recuperação da conta, pois depende das regras e validações da plataforma.
- O valor do produto depende da clareza das instruções e da confiança transmitida ao usuário.

## 15. Stack Sugerida

- Flutter para o aplicativo mobile.
- Armazenamento local para status e histórico simples.
- Navegação baseada em rotas simples.
- Componentes reutilizáveis para manter consistência visual.

## 16. Próximos Passos

1. Definir o MVP com prioridade das telas.
2. Desenhar os fluxos de navegação.
3. Criar o wireframe das telas principais.
4. Iniciar a implementação em Flutter.