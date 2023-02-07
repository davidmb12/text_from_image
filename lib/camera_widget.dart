import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:text_from_image/apis/recognition_api.dart';

import 'apis/translation_api.dart';

class CameraWidget extends StatefulWidget {
  final CameraDescription camera;

  const CameraWidget({super.key, required this.camera});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController cameraController;
  late Future<void> initCameraFn;
  TranslateLanguage selectedLanguage = TranslateLanguage.spanish;
  Map<TranslateLanguage, String> languages = {
    TranslateLanguage.english: 'English',
    TranslateLanguage.arabic: 'Árabe',
    TranslateLanguage.bulgarian: 'Búlgaro',
    TranslateLanguage.spanish: 'Español',
    TranslateLanguage.chinese: 'Chinese',
  };
  bool loading = false;
  String? showText;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cameraController = CameraController(widget.camera, ResolutionPreset.max);
    initCameraFn = cameraController.initialize();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FutureBuilder(
          future: initCameraFn,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: CameraPreview(cameraController));
          }),
        ),
        if (showText != null)
          loading
              ? Center(child: CircularProgressIndicator())
              : Center(
                  child: Container(
                    color: Colors.black45,
                    child: Text(
                      showText!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
        Positioned(
          top: 50,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton<TranslateLanguage>(
                  value: selectedLanguage,
                  items: languages.entries
                      .map<DropdownMenuItem<TranslateLanguage>>(
                          (MapEntry<TranslateLanguage, String> entry) {
                    return DropdownMenuItem<TranslateLanguage>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                  }),
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          child: FloatingActionButton(
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                final image = await cameraController.takePicture();
                final recognizedText =
                    await RecognitionApi.recognizeText(InputImage.fromFile(
                  File(image.path),
                ));

                if (recognizedText == null) return;

                final translatedText = await TranslationApi.translateText(
                    recognizedText, selectedLanguage);
                setState(() {
                  showText = translatedText;
                  loading = false;
                });
              },
              child: const Icon(Icons.translate)),
        ),
      ],
    );
  }
}
