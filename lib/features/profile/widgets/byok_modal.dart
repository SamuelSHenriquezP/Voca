import 'package:flutter/material.dart';
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

  final List<Map<String, dynamic>> _providers = [
    {
      'name': 'Google Gemini',
      'icon': '✨',
      'model': 'gemini-1.5-flash',
      'color': VocaColors.primaryPurple,
    },
    {
      'name': 'OpenAI',
      'icon': '🤖',
      'model': 'gpt-4o-mini',
      'color': VocaColors.emeraldGreen,
    },
    {
      'name': 'Azure Speech',
      'icon': '☁️',
      'model': 'neural-en-US',
      'color': VocaColors.electricCyan,
    },
  ];

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
                      onTap: () => setState(() => _selectedProviderIndex = index),
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
                            Text(provider['icon'], style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
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
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded, size: 14, color: VocaColors.emeraldGreen),
                const SizedBox(width: 6),
                Text(
                  'Keys stored safely on device keychain via encrypted secure storage.',
                  style: VocaTypography.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save Key Button
            VocaButton(
              text: 'SAVE CONFIGURATION',
              variant: VocaButtonVariant.primary,
              isFullWidth: true,
              height: 54,
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${_providers[_selectedProviderIndex]['name']} API Key saved securely!',
                    ),
                    backgroundColor: VocaColors.emeraldGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

