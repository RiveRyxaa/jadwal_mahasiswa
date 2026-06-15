# Flutter/Firebase ProGuard Rules

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.** { *; }

# Google Sign In
-keep class com.google.android.gms.auth.** { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
