// csv_helper_web.dart
// Web platformu için CSV indirme

import 'dart:convert';
import 'dart:html' as html;

class CsvHelper {
  static Future<void> downloadCsv(String content, String fileName) async {
    // UTF-8 BOM ekle (Excel'de Türkçe karakterler için)
    final bytes = utf8.encode('\uFEFF$content');
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}