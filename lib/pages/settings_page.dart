import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app/app_controller.dart';
import '../app/app_texts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);
    final controller = AppControllerScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(texts.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          _SectionTitle(title: texts.language),
          const SizedBox(height: 10),
          _LanguageSelector(
            selectedLanguage: controller.language,
            onChanged: controller.setLanguage,
          ),
          const SizedBox(height: 28),
          _SectionTitle(title: texts.appInfoTitle),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _SettingsTile(
                title: texts.privacyTitle,
                subtitle: texts.privacySubtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InfoPage(
                        title: texts.privacyTitle,
                        body: texts.privacyBody,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              _SettingsTile(
                title: texts.termsTitle,
                subtitle: texts.termsSubtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InfoPage(
                        title: texts.termsTitle,
                        body: texts.termsBody,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              _SettingsTile(
                title: texts.supportTitle,
                subtitle: texts.supportSubtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InfoPage(
                        title: texts.supportTitle,
                        body: texts.supportBody,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _VersionTile(versionLabel: texts.version),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onChanged;

  const _LanguageSelector({
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    return _SettingsCard(
      children: [
        _LanguageTile(
          title: 'English',
          subtitle: texts.isTr
              ? 'Uygulamayı İngilizce kullan'
              : 'Use the app in English',
          isSelected: selectedLanguage == AppLanguage.english,
          onTap: () => onChanged(AppLanguage.english),
        ),
        const Divider(height: 1),
        _LanguageTile(
          title: 'Türkçe',
          subtitle: texts.isTr
              ? 'Uygulamayı Türkçe kullan'
              : 'Use the app in Turkish',
          isSelected: selectedLanguage == AppLanguage.turkish,
          onTap: () => onChanged(AppLanguage.turkish),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 10, 14, 10),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: isSelected
            ? Icon(
                Icons.check_circle_rounded,
                key: const ValueKey('selected'),
                color: colorScheme.primary,
              )
            : const SizedBox(
                key: ValueKey('unselected'),
                width: 24,
                height: 24,
              ),
      ),
      onTap: onTap,
    );
  }
}

class InfoPage extends StatelessWidget {
  final String title;
  final String body;

  const InfoPage({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            body.trim(),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _VersionTile extends StatelessWidget {
  final String versionLabel;

  const _VersionTile({required this.versionLabel});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final versionText =
            info == null ? '-' : '${info.version} (${info.buildNumber})';

        return Center(
          child: Text(
            '$versionLabel $versionText',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        );
      },
    );
  }
}
