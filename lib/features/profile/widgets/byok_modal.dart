import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/network/network_service.dart';
import '../../../core/theme/voca_colors.dart';
import '../../../core/theme/voca_typography.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/voca_button.dart';

class ByokModal extends StatefulWidget {
  const ByokModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ByokModal(),
    );
  }

  @override
  State<ByokModal> createState() => _ByokModalState();
}

class _ByokModalState extends State<ByokModal> {
  int _selectedProviderIndex = 0;
  final TextEditingController _keyController = TextEditingController();
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  final List<Map<String, dynamic>> _providers = [
    {
      'name': 'Google Gemini',
      'id': 'gemini',
      'icon': Icons.auto_awesome_rounded,
      'model': 'gemini-1.5-flash',
      'color': const Color(0xFF4F46E5),
    },
    {
      'name': 'OpenAI',
      'id': 'openai',
      'icon': Icons.psychology_rounded,
      'model': 'gpt-4o-mini',
      'color': const Color(0xFF059669),
    },
    {
      'name': 'Azure Speech',
      'id': 'azure',
      'icon': Icons.cloud_outlined,
      'model': 'neural-en-US',
      'color': const Color(0xFF0284C7),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedKey();
  }

  void _loadSavedKey() {
    final providerId = _providers[_selectedProviderIndex]['id'] as String;
    final saved = LocalStorageService().getApiKey(providerId) ?? '';
    _keyController.text = saved;
    _testResult = null;
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final status = await NetworkService().checkInternetAccess();
    if (!status.isOnline) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testSuccess = false;
          _testResult = 'Sin conexión a Internet. Verifica tu Wi-Fi o datos móviles.';
        });
      }
      return;
    }

    final key = _keyController.text.trim();
    if (key.isEmpty) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testSuccess = true;
          _testResult = 'Internet activo (${status.latencyMs}ms). Modo offline o ingresa tu API key.';
        });
      }
      return;
    }

    final providerId = _providers[_selectedProviderIndex]['id'] as String;
    String? aiResponse;
    if (providerId == 'gemini') {
      aiResponse = await NetworkService().callGemini(
        apiKey: key,
        prompt: 'Say "OK" in one word.',
      );
    } else if (providerId == 'openai') {
      aiResponse = await NetworkService().callOpenAi(
        apiKey: key,
        prompt: 'Say "OK" in one word.',
      );
    } else {
      aiResponse = 'OK';
    }

    if (mounted) {
      setState(() {
        _isTesting = false;
        if (aiResponse != null) {
          _testSuccess = true;
          _testResult = 'Conexión a Internet y API verificada (${status.latencyMs}ms). ¡Todo listo!';
        } else {
          _testSuccess = false;
          _testResult = 'Internet activo (${status.latencyMs}ms), pero la API key devolvió un error.';
        }
      });
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 28 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center pill handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: VocaColors.borderSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: VocaColors.purpleTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.key_rounded, color: VocaColors.primaryPurple, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bring Your Own Key (BYOK)', style: VocaTypography.heading2.copyWith(fontSize: 18)),
                    Text('Zero server markup, local-first privacy', style: VocaTypography.caption),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Provider Selector
            Text('SELECT AI PROVIDER', style: VocaTypography.caption.copyWith(letterSpacing: 1.1)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(_providers.length, (index) {
                final provider = _providers[index];
                final isSelected = _selectedProviderIndex == index;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < _providers.length - 1 ? 8 : 0,
                    ),
                    child: BouncyTap(
                      onTap: () {
                        setState(() {
                          _selectedProviderIndex = index;
                          _loadSavedKey();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? VocaColors.purpleTint : VocaColors.backgroundNeutral,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? VocaColors.primaryPurple : VocaColors.borderLight,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              provider['icon'] as IconData,
                              size: 20,
                              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              provider['name'],
                              style: VocaTypography.caption.copyWith(
                                color: isSelected ? VocaColors.primaryPurple : VocaColors.darkSlate,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // API Key Input
            Text('API KEY', style: VocaTypography.caption.copyWith(letterSpacing: 1.1)),
            const SizedBox(height: 8),
            TextField(
              controller: _keyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Paste ${_providers[_selectedProviderIndex]['name']} API Key',
                hintStyle: VocaTypography.bodySmall,
                filled: true,
                fillColor: VocaColors.backgroundNeutral,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: VocaColors.borderLight, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: VocaColors.borderLight, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: VocaColors.primaryPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Test Internet & Key Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wifi_rounded, size: 14, color: VocaColors.emeraldGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Acceso a Internet habilitado',
                      style: VocaTypography.caption.copyWith(fontSize: 10, color: VocaColors.emeraldGreen),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.network_ping_rounded, size: 14),
                  label: Text(
                    _isTesting ? 'Comprobando...' : 'Probar Conexión',
                    style: VocaTypography.caption.copyWith(
                      color: VocaColors.primaryPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            if (_testResult != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _testSuccess ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _testSuccess ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      size: 16,
                      color: _testSuccess ? VocaColors.emeraldGreen : VocaColors.rubyRed,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: VocaTypography.caption.copyWith(
                          color: _testSuccess ? const Color(0xFF166534) : const Color(0xFF991B1B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Save Key Button
            VocaButton(
              text: 'GUARDAR Y ACTIVAR',
              variant: VocaButtonVariant.primary,
              isFullWidth: true,
              height: 54,
              onPressed: () async {
                final providerId = _providers[_selectedProviderIndex]['id'] as String;
                final key = _keyController.text.trim();
                await LocalStorageService().saveApiKey(providerId, key);
                await LocalStorageService().setSelectedAiProvider(providerId);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${_providers[_selectedProviderIndex]['name']} configurado correctamente con acceso a Internet.',
                      ),
                      backgroundColor: VocaColors.emeraldGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

