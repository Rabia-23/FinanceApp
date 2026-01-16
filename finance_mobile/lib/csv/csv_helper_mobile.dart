
// iOS ve Android için CSV kaydetme ve paylaşma

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvHelper {
  static Future<void> downloadCsv(String content, String fileName) async {
    // UTF-8 BOM ekle (Excel'de Türkçe karakterler için)
    final csvWithBom = '\uFEFF$content';
    
    // Geçici dizine kaydet
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    
    // Dosyayı yaz
    await file.writeAsString(csvWithBom, encoding: utf8);
    
    // Paylaşım menüsünü aç (kullanıcı kaydedebilir veya paylaşabilir)
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'İşlem listesi',
      subject: fileName,
    );
  }
}