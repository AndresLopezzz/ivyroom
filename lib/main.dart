import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/images/segmentation_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Pide el modelo de recorte al abrir la app y no al primer recorte: asi
  // cuando se añade la primera prenda ya suele estar descargado.
  SegmentationModel.ensure();
  runApp(const ProviderScope(child: IvyroomApp()));
}
