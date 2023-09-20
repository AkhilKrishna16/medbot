import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import 'dart:developer';

import './constants.dart';

main() async {
  final db = await mongo.Db.create(MONGO_URL);
  try {
    await db.open();

    final collection = db.collection(COLLECTION_NAME);
    await collection.insert({'name': 'Akhil'});

    final data = await collection.find().toList();
    inspect(data);
    print(data);
  } catch (e) {
    print(e);
  } finally {
    db.close();
  }

  runApp(const MedBot());
}

class MedBot extends StatefulWidget {
  const MedBot({super.key});

  @override
  State<MedBot> createState() => MedBotState();
}

class MedBotState extends State<MedBot> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
