import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/app_texts.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class SavedPdf {
  final String id;
  final String title;
  final String filePath;
  final DateTime createdAt;
  final int fileSizeBytes;

  const SavedPdf({
    required this.id,
    required this.title,
    required this.filePath,
    required this.createdAt,
    required this.fileSizeBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'fileSizeBytes': fileSizeBytes,
    };
  }

  factory SavedPdf.fromJson(Map<String, dynamic> json) {
    return SavedPdf(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
    );
  }
}

class _HomePageState extends State<HomePage> {
  static const String _storageKey = 'paperpilot_saved_pdfs';
  static const String _iosBannerAdUnitId =
      'ca-app-pub-8274979068153688/9689726714';

  final FlutterDocScanner _scanner = FlutterDocScanner();

  List<SavedPdf> _pdfs = [];
  bool _isLoading = true;
  bool _isScanning = false;

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPdfs();
    _loadBannerAd();
  }

  Future<void> _loadSavedPdfs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? [];

    final loaded = rawList
        .map((raw) => SavedPdf.fromJson(jsonDecode(raw)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (!mounted) return;

    setState(() {
      _pdfs = loaded;
      _isLoading = false;
    });
  }

  Future<void> _savePdfList(List<SavedPdf> pdfs) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = pdfs.map((pdf) => jsonEncode(pdf.toJson())).toList();
    await prefs.setStringList(_storageKey, rawList);
  }

  void _loadBannerAd() {
    final ad = BannerAd(
      adUnitId: _iosBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner failed to load: $error');
        },
      ),
    );

    ad.load();
  }

  Future<void> _scanDocument() async {
    final texts = AppTexts.of(context);

    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final result = await _scanner.getScannedDocumentAsPdf(page: 50);

      if (!mounted) return;

      if (result == null) {
        _showMessage(texts.scanCancelled);
        return;
      }

      final defaultName =
          'Scan ${DateFormat('yyyy-MM-dd HH.mm').format(DateTime.now())}';

      final title = await _askPdfName(defaultName);

      if (!mounted) return;

      if (title == null || title.trim().isEmpty) {
        _showMessage(texts.pdfNotSaved);
        return;
      }

      final savedPdf = await _copyScannedPdf(
        sourceUriOrPath: result.pdfUri,
        title: title.trim(),
      );

      final updatedList = [savedPdf, ..._pdfs];
      await _savePdfList(updatedList);

      if (!mounted) return;

      setState(() {
        _pdfs = updatedList;
      });

      _showMessage(texts.pdfSaved);
    } on PlatformException catch (error) {
      _showMessage(error.message ?? texts.scannerError);
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<SavedPdf> _copyScannedPdf({
    required String sourceUriOrPath,
    required String title,
  }) async {
    final texts = AppTexts.of(context);
    final sourcePath = _normalizeFilePath(sourceUriOrPath);
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw Exception(texts.scannedPdfFileNotFound);
    }

    final appDir = await getApplicationDocumentsDirectory();
    final scansDir = Directory(p.join(appDir.path, 'scans'));

    if (!await scansDir.exists()) {
      await scansDir.create(recursive: true);
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final cleanTitle = _cleanFileName(title);
    final destinationPath = p.join(scansDir.path, '${cleanTitle}_$id.pdf');

    final copiedFile = await sourceFile.copy(destinationPath);
    final fileSize = await copiedFile.length();

    return SavedPdf(
      id: id,
      title: title,
      filePath: destinationPath,
      createdAt: DateTime.now(),
      fileSizeBytes: fileSize,
    );
  }

  String _normalizeFilePath(String value) {
    if (value.startsWith('file://')) {
      return Uri.parse(value).toFilePath();
    }

    return value;
  }

  String _cleanFileName(String value) {
    final cleaned = value
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    return cleaned.isEmpty ? 'PaperPilot_Scan' : cleaned;
  }

  Future<String?> _askPdfName(String defaultName) async {
    final texts = AppTexts.of(context);
    final controller = TextEditingController(text: defaultName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final dialogTexts = AppTexts.of(context);

        return AlertDialog(
          title: Text(dialogTexts.nameYourPdf),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: dialogTexts.pdfName,
              hintText: dialogTexts.pdfNameHint,
            ),
            onSubmitted: (_) {
              Navigator.of(context).pop(controller.text);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(dialogTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(dialogTexts.save),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<void> _openPdf(SavedPdf pdf) async {
    final texts = AppTexts.of(context);
    final file = File(pdf.filePath);

    if (!await file.exists()) {
      _showMessage(texts.pdfFileNotFound);
      return;
    }

    await OpenFilex.open(pdf.filePath);
  }

  Future<void> _sharePdf(SavedPdf pdf) async {
    final texts = AppTexts.of(context);
    final file = File(pdf.filePath);

    if (!await file.exists()) {
      _showMessage(texts.pdfFileNotFound);
      return;
    }

    final box = context.findRenderObject() as RenderBox?;

    await Share.shareXFiles(
      [XFile(pdf.filePath)],
      subject: pdf.title,
      text: pdf.title,
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<void> _deletePdf(SavedPdf pdf) async {
    final texts = AppTexts.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dialogTexts = AppTexts.of(context);

        return AlertDialog(
          title: Text(dialogTexts.deletePdf),
          content: Text(dialogTexts.deletePdfMessage(pdf.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(dialogTexts.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(dialogTexts.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final file = File(pdf.filePath);
    if (await file.exists()) {
      await file.delete();
    }

    final updatedList = _pdfs.where((item) => item.id != pdf.id).toList();
    await _savePdfList(updatedList);

    if (!mounted) return;

    setState(() {
      _pdfs = updatedList;
    });

    _showMessage(texts.pdfDeleted);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • HH:mm').format(date);
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return 'Unknown size';

    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }

    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildBanner() {
    if (!_isBannerLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
        ),
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    return Scaffold(
      bottomNavigationBar: _buildBanner(),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverAppBar.large(
                    title: Text(texts.appName),
                    centerTitle: false,
                    actions: [
                      IconButton(
                        tooltip: texts.settings,
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _HeroCard(
                          isScanning: _isScanning,
                          onScanPressed: _scanDocument,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          texts.recentPdfs,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        if (_pdfs.isEmpty)
                          const _EmptyState()
                        else
                          ..._pdfs.map(
                            (pdf) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _PdfCard(
                                pdf: pdf,
                                dateText: _formatDate(pdf.createdAt),
                                sizeText: _formatFileSize(pdf.fileSizeBytes),
                                onOpen: () => _openPdf(pdf),
                                onShare: () => _sharePdf(pdf),
                                onDelete: () => _deletePdf(pdf),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

class _HeroCard extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onScanPressed;

  const _HeroCard({required this.isScanning, required this.onScanPressed});

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.document_scanner_rounded,
            size: 46,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: 18),
          Text(
            texts.scanDocumentsTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            texts.scanDocumentsSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.75),
                ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isScanning ? null : onScanPressed,
              icon: isScanning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt_rounded),
              label: Text(isScanning ? texts.scanning : texts.scanDocument),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfCard extends StatelessWidget {
  final SavedPdf pdf;
  final String dateText;
  final String sizeText;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _PdfCard({
    required this.pdf,
    required this.dateText,
    required this.sizeText,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.picture_as_pdf_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          pdf.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('$dateText\nPDF • $sizeText'),
        ),
        isThreeLine: true,
        onTap: onOpen,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'open':
                onOpen();
                break;
              case 'share':
                onShare();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(value: 'open', child: Text(texts.open)),
              PopupMenuItem(value: 'share', child: Text(texts.share)),
              PopupMenuItem(value: 'delete', child: Text(texts.delete)),
            ];
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.25),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(texts.noPdfsYet, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            texts.noPdfsSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
