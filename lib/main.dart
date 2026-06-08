import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const DeletePerfilApp());
}

class DeletePerfilApp extends StatelessWidget {
  const DeletePerfilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DeletePerfil',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C81),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      ),
      home: const RecoveryHomePage(),
    );
  }
}

enum RecoveryIssue {
  senhaEsquecida,
  contaInvadida,
  emailInacessivel,
  telefoneInacessivel,
  autenticacao2fa,
  bloqueioSeguranca,
}

enum RecoveryStage { iniciado, emAndamento, aguardandoResposta, concluido }

class RecoveryHomePage extends StatefulWidget {
  const RecoveryHomePage({super.key});

  @override
  State<RecoveryHomePage> createState() => _RecoveryHomePageState();
}

class _RecoveryHomePageState extends State<RecoveryHomePage> {
  static const _issueKey = 'selected_issue';
  static const _stageKey = 'selected_stage';
  static const _noteKey = 'recovery_note';

  final TextEditingController _noteController = TextEditingController();
  RecoveryIssue _selectedIssue = RecoveryIssue.contaInvadida;
  RecoveryStage _selectedStage = RecoveryStage.iniciado;
  SharedPreferences? _prefs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _prefs = prefs;
      _selectedIssue = RecoveryIssue.values.firstWhere(
        (issue) => issue.name == prefs.getString(_issueKey),
        orElse: () => RecoveryIssue.contaInvadida,
      );
      _selectedStage = RecoveryStage.values.firstWhere(
        (stage) => stage.name == prefs.getString(_stageKey),
        orElse: () => RecoveryStage.iniciado,
      );
      _noteController.text = prefs.getString(_noteKey) ?? '';
      _loading = false;
    });
  }

  Future<void> _saveIssue(RecoveryIssue issue) async {
    setState(() {
      _selectedIssue = issue;
    });
    await _prefs?.setString(_issueKey, issue.name);
  }

  Future<void> _saveStage(RecoveryStage stage) async {
    setState(() {
      _selectedStage = stage;
    });
    await _prefs?.setString(_stageKey, stage.name);
  }

  Future<void> _saveNote() async {
    await _prefs?.setString(_noteKey, _noteController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progresso salvo localmente.')),
    );
  }

  Future<void> _openLink(String url) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final issue = _selectedIssue.data;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF1F8), Color(0xFFF7F9FC), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroCard(
                            issue: issue,
                            selectedIssue: _selectedIssue,
                            selectedStage: _selectedStage,
                            onIssueSelected: _saveIssue,
                            onStageSelected: _saveStage,
                          ),
                          const SizedBox(height: 16),
                          _SectionCard(
                            title: '1. Escolha o cenário',
                            subtitle:
                                'Selecione o problema para adaptar o fluxo de recuperação.',
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: RecoveryIssue.values
                                  .map(
                                    (issueItem) => ChoiceChip(
                                      label: Text(issueItem.label),
                                      avatar: Icon(issueItem.icon, size: 18),
                                      selected: _selectedIssue == issueItem,
                                      onSelected: (_) => _saveIssue(issueItem),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SectionCard(
                            title: '2. Passo a passo oficial',
                            subtitle:
                                'Fluxo curto para organizar a recuperação sem sair dos canais oficiais.',
                            child: Column(
                              children: issue.steps
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => _TimelineItem(
                                      index: entry.key + 1,
                                      text: entry.value,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SectionCard(
                            title: '3. Checklist rápido',
                            subtitle:
                                'Itens úteis para ter em mãos antes de seguir com a tentativa.',
                            child: Column(
                              children: issue.checklist
                                  .map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: _ChecklistItem(text: item),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SectionCard(
                            title: '4. Dúvidas frequentes',
                            subtitle:
                                'Respostas curtas para os bloqueios mais comuns durante a recuperação.',
                            child: Column(
                              children: issue.faqs
                                  .map(
                                    (faq) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Card(
                                        elevation: 0,
                                        color: const Color(0xFFF8FBFE),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFFE3EAF2),
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: ExpansionTile(
                                            title: Text(
                                              faq.question,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            childrenPadding:
                                                const EdgeInsets.fromLTRB(
                                                  16,
                                                  0,
                                                  16,
                                                  16,
                                                ),
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  faq.answer,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: const Color(
                                                          0xFF516172,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SectionCard(
                            title: '5. Progresso local',
                            subtitle:
                                'Salve o estágio atual da tentativa no próprio aparelho.',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: RecoveryStage.values
                                      .map(
                                        (stage) => FilterChip(
                                          label: Text(stage.label),
                                          selected: _selectedStage == stage,
                                          onSelected: (_) => _saveStage(stage),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _noteController,
                                  maxLines: 4,
                                  decoration: const InputDecoration(
                                    labelText: 'Observações locais',
                                    hintText:
                                        'Ex.: tentei recuperar pelo email, aguardei resposta e revisei o número de telefone.',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: _saveNote,
                                  icon: const Icon(Icons.save_outlined),
                                  label: const Text('Salvar progresso'),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Status atual: ${_selectedStage.label}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _selectedStage.description,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        child: LinearProgressIndicator(
                                          value: _selectedStage.progress,
                                          minHeight: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SectionCard(
                            title: '6. Links oficiais',
                            subtitle:
                                'Atalhos para páginas oficiais da Meta e do Facebook.',
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: issue.links
                                  .map(
                                    (link) => OutlinedButton.icon(
                                      onPressed: () => _openLink(link.url),
                                      icon: const Icon(Icons.open_in_new),
                                      label: Text(link.label),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.issue,
    required this.selectedIssue,
    required this.selectedStage,
    required this.onIssueSelected,
    required this.onStageSelected,
  });

  final RecoveryIssueData issue;
  final RecoveryIssue selectedIssue;
  final RecoveryStage selectedStage;
  final ValueChanged<RecoveryIssue> onIssueSelected;
  final ValueChanged<RecoveryStage> onStageSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DeletePerfil',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'MVP para orientar recuperação de acesso ao Facebook',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Recupere o acesso com orientação objetiva, segura e sem pedir credenciais.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            issue.intro,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroBadge(
                icon: Icons.task_alt_outlined,
                label: '${issue.steps.length} etapas guiadas',
              ),
              _HeroBadge(icon: Icons.lock_outline, label: 'Sem senha ou token'),
              _HeroBadge(
                icon: Icons.history_outlined,
                label: 'Progresso salvo localmente',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: RecoveryStage.values
                .map(
                  (stage) => ChoiceChip(
                    label: Text(stage.label),
                    selected: selectedStage == stage,
                    selectedColor: Colors.white,
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.35),
                    onSelected: (_) => onStageSelected(stage),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: RecoveryIssue.values
                .map(
                  (issueItem) => ChoiceChip(
                    label: Text(issueItem.shortLabel),
                    avatar: Icon(issueItem.icon, size: 18, color: Colors.black),
                    selected: selectedIssue == issueItem,
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => onIssueSelected(issueItem),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Estágio atual: ${selectedStage.label}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3EAF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B13304A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5D6B7C)),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class RecoveryIssueData {
  const RecoveryIssueData({
    required this.title,
    required this.shortLabel,
    required this.intro,
    required this.steps,
    required this.checklist,
    required this.faqs,
    required this.links,
  });

  final String title;
  final String shortLabel;
  final String intro;
  final List<String> steps;
  final List<String> checklist;
  final List<FaqItem> faqs;
  final List<OfficialLink> links;
}

class FaqItem {
  const FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

class OfficialLink {
  const OfficialLink({required this.label, required this.url});

  final String label;
  final String url;
}

const recoveryCatalog = <RecoveryIssue, RecoveryIssueData>{
  RecoveryIssue.senhaEsquecida: RecoveryIssueData(
    title: 'Senha esquecida',
    shortLabel: 'Senha',
    intro:
        'Use o fluxo oficial de identificação da conta para tentar recuperar acesso com email, telefone ou nome associado.',
    steps: [
      'Abra o fluxo oficial de identificação de conta.',
      'Informe email, telefone ou nome associado ao perfil.',
      'Escolha o método de recuperação disponível.',
      'Conclua a validação pelo canal confirmado.',
    ],
    checklist: [
      'Acesso ao email ou telefone vinculados à conta.',
      'Nome completo usado no perfil.',
      'Dispositivo que já tenha acessado essa conta antes.',
    ],
    faqs: [
      FaqItem(
        question: 'Posso recuperar sem o email original?',
        answer:
            'Em alguns casos sim, mas o app sempre direciona para os caminhos oficiais disponíveis no Facebook.',
      ),
      FaqItem(
        question: 'Preciso criar uma nova conta?',
        answer:
            'Não como primeira opção. O foco é recuperar a conta já existente.',
      ),
    ],
    links: [
      OfficialLink(
        label: 'Identificar conta',
        url: 'https://www.facebook.com/login/identify',
      ),
      OfficialLink(
        label: 'Central de ajuda',
        url: 'https://www.facebook.com/help/',
      ),
    ],
  ),
  RecoveryIssue.contaInvadida: RecoveryIssueData(
    title: 'Conta invadida',
    shortLabel: 'Invasão',
    intro:
        'Priorize recuperar o acesso e revisar email, telefone e sessões ativas da conta.',
    steps: [
      'Abra o fluxo oficial para conta comprometida.',
      'Siga a etapa de validação e redefinição de senha.',
      'Revise email, telefone e sessões recentes após entrar.',
      'Confirme que não existem alterações suspeitas no perfil.',
    ],
    checklist: [
      'Acesso ao email seguro.',
      'Celular com o número cadastrado, se houver.',
      'Lembrete de senhas antigas ou dados do perfil.',
    ],
    faqs: [
      FaqItem(
        question: 'Se o invasor mudou meu email?',
        answer:
            'O app indica o caminho oficial para reaver a conta e, depois, revisar os dados de contato.',
      ),
      FaqItem(
        question: 'Devo denunciar a invasão?',
        answer:
            'Sim, sempre pelos fluxos oficiais do Facebook para evitar ações inseguras.',
      ),
    ],
    links: [
      OfficialLink(
        label: 'Conta hackeada',
        url: 'https://www.facebook.com/hacked',
      ),
      OfficialLink(
        label: 'Identificar conta',
        url: 'https://www.facebook.com/login/identify',
      ),
    ],
  ),
  RecoveryIssue.emailInacessivel: RecoveryIssueData(
    title: 'Email inacessível',
    shortLabel: 'Email',
    intro:
        'Quando o email de recuperação não está disponível, use os métodos alternativos confirmados pela plataforma.',
    steps: [
      'Verifique se existe outro canal de contato cadastrado.',
      'Use o fluxo oficial de recuperação de conta.',
      'Escolha um método alternativo de confirmação, se aparecer.',
      'Depois de entrar, atualize o email e revise a segurança.',
    ],
    checklist: [
      'Número de telefone vinculado à conta, se existir.',
      'Dispositivo que já tenha sido usado no perfil.',
      'Informações básicas de identificação da conta.',
    ],
    faqs: [
      FaqItem(
        question: 'E se eu não tiver mais acesso a nada?',
        answer:
            'O app orienta a tentar os caminhos oficiais restantes e a revisar as opções disponíveis.',
      ),
      FaqItem(
        question: 'Posso trocar o email depois?',
        answer:
            'Sim, depois de recuperar o acesso, o ideal é atualizar os dados de contato imediatamente.',
      ),
    ],
    links: [
      OfficialLink(
        label: 'Identificar conta',
        url: 'https://www.facebook.com/login/identify',
      ),
      OfficialLink(
        label: 'Ajuda do Facebook',
        url: 'https://www.facebook.com/help/',
      ),
    ],
  ),
  RecoveryIssue.telefoneInacessivel: RecoveryIssueData(
    title: 'Telefone inacessível',
    shortLabel: 'Telefone',
    intro:
        'Se o número cadastrado não está mais disponível, procure o fluxo com email ou outro método validado.',
    steps: [
      'Verifique se o email ainda está acessível.',
      'Use o fluxo oficial de recuperação da conta.',
      'Escolha o método alternativo de confirmação mostrado.',
      'Atualize o número de telefone depois de entrar novamente.',
    ],
    checklist: [
      'Acesso ao email principal.',
      'Dispositivo que já tenha usado a conta.',
      'Informações que ajudem a reconhecer o perfil.',
    ],
    faqs: [
      FaqItem(
        question: 'Preciso manter o mesmo número para sempre?',
        answer:
            'Não. Depois da recuperação, o usuário pode atualizar o contato cadastrado.',
      ),
      FaqItem(
        question: 'O app troca o telefone por mim?',
        answer:
            'Não. Ele só orienta pelos passos oficiais e ajuda a organizar o processo.',
      ),
    ],
    links: [
      OfficialLink(
        label: 'Identificar conta',
        url: 'https://www.facebook.com/login/identify',
      ),
      OfficialLink(
        label: 'Central de ajuda',
        url: 'https://www.facebook.com/help/',
      ),
    ],
  ),
  RecoveryIssue.autenticacao2fa: RecoveryIssueData(
    title: 'Autenticação em dois fatores',
    shortLabel: '2FA',
    intro:
        'O MVP ajuda a revisar os caminhos oficiais quando o código de autenticação não está disponível.',
    steps: [
      'Verifique se há métodos alternativos de confirmação.',
      'Tente recuperar o acesso pelos canais oficiais do Facebook.',
      'Depois de entrar, atualize os meios de autenticação com atenção.',
      'Guarde os códigos de recuperação em local seguro.',
    ],
    checklist: [
      'Acesso ao email principal.',
      'Número de telefone válido, se cadastrado.',
      'Códigos de recuperação, caso tenham sido guardados antes.',
    ],
    faqs: [
      FaqItem(
        question: 'Posso pedir um novo código pelo app?',
        answer:
            'O app não gera códigos; ele apenas orienta a usar os fluxos oficiais da plataforma.',
      ),
      FaqItem(
        question: 'Preciso guardar códigos de recuperação?',
        answer:
            'Sim. Se a conta tiver 2FA, isso pode acelerar futuros acessos seguros.',
      ),
    ],
    links: [
      OfficialLink(
        label: 'Ajuda do Facebook',
        url: 'https://www.facebook.com/help/',
      ),
      OfficialLink(
        label: 'Identificar conta',
        url: 'https://www.facebook.com/login/identify',
      ),
    ],
  ),
  RecoveryIssue.bloqueioSeguranca: RecoveryIssueData(
    title: 'Bloqueio de segurança',
    shortLabel: 'Bloqueio',
    intro:
        'Quando a conta entra em proteção, o fluxo oficial orienta a validar identidade e revisar o motivo do bloqueio.',
    steps: [
      'Leia a mensagem de bloqueio e identifique o motivo.',
      'Siga o fluxo oficial sugerido pela plataforma.',
      'Revise acessos recentes e dispositivos confiáveis.',
      'Ajuste a segurança da conta após recuperar o acesso.',
    ],
    checklist: [
      'Acesso ao email principal.',
      'Dispositivo confiável usado anteriormente.',
      'Capacidade de revisar notificações e alertas recebidos.',
    ],
    faqs: [
      FaqItem(
        question: 'Bloqueio de segurança é sempre invasão?',
        answer:
            'Não necessariamente. Pode ocorrer por atividade suspeita ou validação adicional de identidade.',
      ),
      FaqItem(
        question: 'O app resolve o bloqueio sozinho?',
        answer:
            'Não. Ele organiza a orientação e leva o usuário apenas para caminhos oficiais.',
      ),
    ],
    links: [
      OfficialLink(
        label: 'Central de ajuda',
        url: 'https://www.facebook.com/help/',
      ),
      OfficialLink(
        label: 'Conta hackeada',
        url: 'https://www.facebook.com/hacked',
      ),
    ],
  ),
};

extension RecoveryIssueX on RecoveryIssue {
  String get label => switch (this) {
    RecoveryIssue.senhaEsquecida => 'Senha esquecida',
    RecoveryIssue.contaInvadida => 'Conta invadida',
    RecoveryIssue.emailInacessivel => 'Email inacessível',
    RecoveryIssue.telefoneInacessivel => 'Telefone inacessível',
    RecoveryIssue.autenticacao2fa => 'Autenticação 2FA',
    RecoveryIssue.bloqueioSeguranca => 'Bloqueio de segurança',
  };

  String get shortLabel => switch (this) {
    RecoveryIssue.senhaEsquecida => 'Senha',
    RecoveryIssue.contaInvadida => 'Invasão',
    RecoveryIssue.emailInacessivel => 'Email',
    RecoveryIssue.telefoneInacessivel => 'Telefone',
    RecoveryIssue.autenticacao2fa => '2FA',
    RecoveryIssue.bloqueioSeguranca => 'Bloqueio',
  };

  IconData get icon => switch (this) {
    RecoveryIssue.senhaEsquecida => Icons.password_outlined,
    RecoveryIssue.contaInvadida => Icons.security_outlined,
    RecoveryIssue.emailInacessivel => Icons.email_outlined,
    RecoveryIssue.telefoneInacessivel => Icons.phone_iphone_outlined,
    RecoveryIssue.autenticacao2fa => Icons.pin_outlined,
    RecoveryIssue.bloqueioSeguranca => Icons.shield_outlined,
  };

  RecoveryIssueData get data => recoveryCatalog[this]!;
}

extension RecoveryStageX on RecoveryStage {
  String get label => switch (this) {
    RecoveryStage.iniciado => 'Iniciado',
    RecoveryStage.emAndamento => 'Em andamento',
    RecoveryStage.aguardandoResposta => 'Aguardando resposta',
    RecoveryStage.concluido => 'Concluído',
  };

  String get description => switch (this) {
    RecoveryStage.iniciado =>
      'Você começou o fluxo e ainda está reunindo as informações.',
    RecoveryStage.emAndamento =>
      'A tentativa já está em curso e o usuário segue os passos.',
    RecoveryStage.aguardandoResposta =>
      'A ação foi enviada e agora depende de retorno da plataforma.',
    RecoveryStage.concluido =>
      'O acesso foi recuperado ou o processo foi encerrado.',
  };

  double get progress => switch (this) {
    RecoveryStage.iniciado => 0.25,
    RecoveryStage.emAndamento => 0.5,
    RecoveryStage.aguardandoResposta => 0.75,
    RecoveryStage.concluido => 1,
  };
}
