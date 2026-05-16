name: test_app
description: "A new Flutter project"
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8

  # قاعدة البيانات
  sqflite: ^2.3.0
  path: ^1.9.0
  path_provider: ^2.1.2

  # Excel
  excel: ^4.0.6

  # اختيار الملفات
  file_picker: ^8.0.0

  # PDF + طباعة
  pdf: ^3.10.7
  printing: ^5.12.0

  # فتح الملفات
  open_file: ^3.5.10

  # مشاركة الملفات
  share_plus: ^10.0.2

  # HTML (لـ PDF العربي لاحقًا)
  html: ^0.15.4

  # 📄 Word / Excel engine (للـ DOCX / XLSX export)
  syncfusion_flutter_xlsio: ^27.1.50

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true

  assets:
    - assets/fonts/
