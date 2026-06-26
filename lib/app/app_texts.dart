import 'package:flutter/material.dart';

import 'app_controller.dart';

class AppTexts {
  final AppLanguage currentLanguage;

  const AppTexts(this.currentLanguage);

  bool get isTr => currentLanguage == AppLanguage.turkish;

  static AppTexts of(BuildContext context) {
    return AppTexts(AppControllerScope.of(context).language);
  }

  String get appName => 'PaperPilot PDF';

  String get scanDocumentsTitle => isTr
      ? 'Belgeleri temiz PDF dosyalarına dönüştür.'
      : 'Scan documents into clean PDF files.';

  String get scanDocumentsSubtitle => isTr
      ? 'Fiş, not, form, sözleşme ve evrakları tara. PDF olarak kaydet ve paylaş.'
      : 'Capture receipts, notes, forms, contracts, and paperwork. Save and share them as PDF files.';

  String get scanDocument => isTr ? 'Belge Tara' : 'Scan Document';

  String get scanning => isTr ? 'Taranıyor...' : 'Scanning...';

  String get recentPdfs => isTr ? 'Son PDF’ler' : 'Recent PDFs';

  String get noPdfsYet => isTr ? 'Henüz PDF yok' : 'No PDFs yet';

  String get noPdfsSubtitle => isTr
      ? 'Taranan belgelerin burada görünecek.'
      : 'Your scanned documents will appear here.';

  String get scanCancelled => isTr ? 'Tarama iptal edildi.' : 'Scan cancelled.';

  String get pdfNotSaved => isTr ? 'PDF kaydedilmedi.' : 'PDF was not saved.';

  String get pdfSaved => isTr ? 'PDF kaydedildi.' : 'PDF saved.';

  String get scannerError => isTr ? 'Tarayıcı hatası.' : 'Scanner error.';

  String get pdfFileNotFound =>
      isTr ? 'PDF dosyası bulunamadı.' : 'PDF file was not found.';

  String get scannedPdfFileNotFound => isTr
      ? 'Taranan PDF dosyası bulunamadı.'
      : 'Scanned PDF file could not be found.';

  String get nameYourPdf => isTr ? 'PDF adını gir' : 'Name your PDF';

  String get pdfName => isTr ? 'PDF adı' : 'PDF name';

  String get pdfNameHint =>
      isTr ? 'Fiş, not, sözleşme...' : 'Receipt, notes, contract...';

  String get cancel => isTr ? 'İptal' : 'Cancel';

  String get save => isTr ? 'Kaydet' : 'Save';

  String get deletePdf => isTr ? 'PDF silinsin mi?' : 'Delete PDF?';

  String deletePdfMessage(String title) => isTr
      ? '"$title" bu cihazdan kaldırılacak.'
      : '"$title" will be removed from this device.';

  String get delete => isTr ? 'Sil' : 'Delete';

  String get pdfDeleted => isTr ? 'PDF silindi.' : 'PDF deleted.';

  String get open => isTr ? 'Aç' : 'Open';

  String get share => isTr ? 'Paylaş' : 'Share';

  String get settings => isTr ? 'Ayarlar' : 'Settings';

  String get language => isTr ? 'Dil' : 'Language';

  String get english => isTr ? 'İngilizce' : 'English';

  String get turkish => isTr ? 'Türkçe' : 'Turkish';

  String get privacyTitle => isTr ? 'Gizlilik' : 'Privacy';

  String get privacySubtitle => isTr
      ? 'Veri kullanımı ve belge saklama'
      : 'Data use and document storage';

  String get termsTitle => isTr ? 'Kullanım Şartları' : 'Terms of Use';

  String get termsSubtitle =>
      isTr ? 'Uygulama kullanım koşulları' : 'App usage terms';

  String get supportTitle => isTr ? 'Destek' : 'Support';

  String get supportSubtitle =>
      isTr ? 'Yardım ve iletişim bilgileri' : 'Help and contact information';

  String get appInfoTitle => isTr ? 'Uygulama Bilgisi' : 'App Information';

  String get version => isTr ? 'Sürüm' : 'Version';

  String get privacyBody => isTr
      ? '''
PaperPilot PDF, belgeleri tarayıp PDF olarak cihazında saklamak için tasarlanmıştır.

Belge Saklama
Taranan PDF dosyaları cihazın yerel depolama alanında tutulur. PaperPilot PDF, taranan belgeleri kendi sunucularına yüklemez.

Kamera Kullanımı
Kamera yalnızca belge tarama işlemi için kullanılır. Kamera izni olmadan belge tarama özelliği çalışmaz.

Reklamlar
Uygulamada Google AdMob reklamları gösterilebilir. Reklam hizmetleri; cihaz, reklam tanımlayıcıları veya kullanım sinyalleri gibi bazı verileri işleyebilir. Bu veriler Google’ın reklam ve gizlilik politikalarına tabidir.

Dosya Paylaşımı
Bir PDF’i paylaştığında, seçtiğin üçüncü taraf uygulama veya servis kendi gizlilik kurallarına göre hareket eder.

Hesap ve Sunucu
PaperPilot PDF şu anda hesap oluşturma, giriş yapma veya bulut senkronizasyonu kullanmaz.
'''
      : '''
PaperPilot PDF is designed to scan documents and store them as PDF files on your device.

Document Storage
Scanned PDF files are stored locally on your device. PaperPilot PDF does not upload scanned documents to its own servers.

Camera Usage
The camera is used only for document scanning. The scanning feature cannot work without camera permission.

Ads
The app may display Google AdMob ads. Advertising services may process certain data such as device information, advertising identifiers, or usage signals. This data is subject to Google’s advertising and privacy policies.

File Sharing
When you share a PDF, the selected third-party app or service handles that file according to its own privacy rules.

Account and Server
PaperPilot PDF currently does not use account registration, login, or cloud sync.
''';

  String get termsBody => isTr
      ? '''
PaperPilot PDF, belgeleri taramak, PDF olarak kaydetmek ve paylaşmak için sunulur.

Kullanım Sorumluluğu
Taranan belgelerin doğruluğunu, okunabilirliğini ve uygunluğunu kontrol etmek kullanıcı sorumluluğundadır.

Resmî Belgeler
Uygulama, belgelerin hukukî geçerliliğini garanti etmez. Resmî işlemler için kurumların istediği format ve kalite gereklilikleri ayrıca kontrol edilmelidir.

Veri Kaybı
Belgeler cihazda saklandığı için uygulama silinirse veya cihaz verileri temizlenirse kayıtlı PDF’ler kaybolabilir. Önemli belgeleri ayrıca yedeklemen önerilir.

Reklamlar
Uygulamada reklam gösterilebilir. Reklamların içeriği üçüncü taraf reklam sağlayıcıları tarafından belirlenebilir.
'''
      : '''
PaperPilot PDF is provided for scanning documents, saving them as PDF files, and sharing them.

User Responsibility
Users are responsible for checking the accuracy, readability, and suitability of scanned documents.

Official Documents
The app does not guarantee the legal validity of any document. For official use, users should verify the format and quality requirements requested by the relevant institution.

Data Loss
Documents are stored on the device. If the app is deleted or device data is cleared, saved PDFs may be lost. Important documents should be backed up separately.

Ads
The app may display ads. Ad content may be provided by third-party advertising services.
''';

  String get supportBody => isTr
      ? '''
Destek için App Store’daki destek bağlantısını kullanabilirsin.

Sorun bildirirken şu bilgileri eklemek faydalı olur:
• Cihaz modeli
• iOS sürümü
• Uygulama sürümü
• Sorunun hangi ekranda oluştuğu
• Mümkünse kısa ekran kaydı veya ekran görüntüsü

PaperPilot PDF basit, hızlı ve cihaz üzerinde çalışan bir PDF tarama uygulaması olarak geliştirilmektedir.
'''
      : '''
For support, use the support link listed on the App Store page.

When reporting an issue, it is helpful to include:
• Device model
• iOS version
• App version
• The screen where the issue occurred
• A short screen recording or screenshot if possible

PaperPilot PDF is developed as a simple, fast, on-device PDF scanning app.
''';
}
