# ML Kit carga el modelo de recorte como modulo dinamico de Google Play
# Services y encuentra sus clases por nombre. Si R8 las renombra o las quita,
# el recorte automatico falla solo en release (en debug no hay R8).
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_subject_segmentation.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google_mlkit_subject_segmentation.** { *; }
-dontwarn com.google.mlkit.**
