import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/funko.dart';

Future<List<Funko>> loadFunkos() async {
  final String response = await rootBundle.loadString('assets/catalog.json');
  final List<dynamic> data = json.decode(response);
  return data.map((json) => Funko.fromJson(json)).toList();
}