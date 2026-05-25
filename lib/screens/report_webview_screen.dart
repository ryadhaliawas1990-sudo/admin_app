import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReportWebViewScreen extends StatefulWidget {
  final String html;

  const ReportWebViewScreen({
    super.key,
    required this.html,
  });

  @override
  State<ReportWebViewScreen> createState() => _ReportWebViewScreenState();
}

class _ReportWebViewScreenState extends State<ReportWebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..loadHtmlString(_wrapHtml(widget.html));
  }

  /// نغلف HTML لتحسين العرض والدعم العربي
  String _wrapHtml(String html) {
    return """
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">

  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <style>
    body {
      font-family: Arial;
      direction: rtl;
      text-align: right;
      padding: 16px;
      background-color: #ffffff;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 15px;
    }

    th, td {
      border: 1px solid #000;
      padding: 8px;
      text-align: center;
      font-size: 14px;
    }

    h2, h3, h4 {
      text-align: center;
      margin: 10px 0;
    }

    .box {
      border: 1px solid #000;
      padding: 10px;
      margin-top: 10px;
    }

    .footer {
      margin-top: 30px;
      display: flex;
      justify-content: space-between;
      font-size: 14px;
    }
  </style>
</head>

<body>
  $html
</body>
</html>
""";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("التقرير"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
