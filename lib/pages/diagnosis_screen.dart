import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:dart_openai/dart_openai.dart';
import 'dart:convert';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  var diagnosis = Map<String, dynamic>;
  String advice = '';
  bool adviceVisible = false;

  void getNextSteps(String condition) async {
    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: 'gpt-3.5-turbo',
      maxTokens: 100,
      temperature: .7,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: 'What are ways I can treat $condition?',
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );

    setState(
      () {
        adviceVisible = true;
        advice = chatCompletion.choices[0].message.content;
      },
    );
  }

  Future<Map<String, dynamic>> getDiagnosis(String symptoms) async {
    final response = await http.post(
      Uri.parse(
          'https://api-inference.huggingface.co/models/abhirajeshbhai/symptom-2-disease-net'),
      headers: {
        'Authorization': 'Bearer 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',
      },
      body: {
        'inputs': symptoms,
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body)[0][0] as Map<String, dynamic>;

      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo',
        maxTokens: 100,
        temperature: .7,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: 'What is ${result['label']}?',
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );

      result.addAll({'definition': chatCompletion.choices[0].message.content});
      return result;
    } else {
      throw Exception('Failed to load symptoms');
    }
  }

  @override
  void initState() {
    super.initState();
    OpenAI.apiKey = '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';
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var symptoms = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Diagnosis',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
            fontSize: 1 / 35 * height,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 1 / 40 * height),
        child: FutureBuilder(
          future: getDiagnosis(symptoms),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              return SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: 1 / 50 * height,
                        bottom: 1 / 50 * height,
                      ),
                      child: Text(
                        'We believe you have',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 1 / 30 * height,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 1 / 40 * width, right: 1 / 40 * width),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1 / 50 * width),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 1 / 100 * width,
                            spreadRadius: 1 / 100 * width,
                            offset: Offset(0, 1 / 100 * width),
                          ),
                        ],
                      ),
                      child: Text(
                        '${snapshot.data!['label']}',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 1 / 20 * height,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 1 / 50 * height),
                      child: Text(
                        '${((snapshot.data!['score'] as double) * 100).round()}% confident',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 1 / 30 * height,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 1 / 50 * height,
                        left: 1 / 50 * width,
                      ),
                      child: adviceVisible
                          ? Container()
                          : Text(
                              snapshot.data!['definition'],
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 1 / 50 * height,
                                color: Colors.grey[700],
                              ),
                            ),
                    ),
                    adviceVisible
                        ? Container(
                            margin: EdgeInsets.only(
                              left: 1 / 50 * width,
                              top: 1 / 50 * height,
                            ),
                            child: Text(
                              advice,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 1 / 50 * height,
                                color: Colors.grey[700],
                              ),
                            ),
                          )
                        : Container(),
                    MaterialButton(
                      onPressed: () {
                        getNextSteps(snapshot.data!['label']);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 1 / 70 * height,
                          horizontal: 1 / 40 * width,
                        ),
                        margin: EdgeInsets.only(top: 1 / 50 * height),
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.circular(1 / 50 * height),
                        ),
                        child: Text(
                          'Determine next steps',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 1 / 45 * height,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('home_page');
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed('medical_ai_screen');
          } else if (index == 2) {
            Navigator.of(context).pushReplacementNamed('news_generator_screen');
          } else if (index == 3) {
            Navigator.of(context).pushReplacementNamed('settings_screen');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: '',
            backgroundColor: Colors.blue[200],
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.local_hospital),
              label: '',
              backgroundColor: Colors.blue[200]),
          BottomNavigationBarItem(
            icon: const Icon(Icons.newspaper),
            label: '',
            backgroundColor: Colors.blue[200],
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: '',
              backgroundColor: Colors.blue[200]),
        ],
      ),
    );
  }
}
