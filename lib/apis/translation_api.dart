import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationApi {
  static Future<String?> translateText(
      String recognizedText, TranslateLanguage translateTo) async {
    try {
      final langIdentifier = await LanguageIdentifier(confidenceThreshold: 0.5);
      final languageCode =
          await langIdentifier.identifyLanguage(recognizedText);
      langIdentifier.close();
      final translator = OnDeviceTranslator(
          sourceLanguage: TranslateLanguage.values
              .firstWhere((element) => element.bcpCode == languageCode),
          targetLanguage: translateTo);
      final translatedText = await translator.translateText(recognizedText);
      translator.close();
      return translatedText;
    } catch (e) {
      return null;
    }
  }
}
