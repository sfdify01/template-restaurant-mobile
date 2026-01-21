# ============================================================================
# R8 KEEP RULES - Only classes that require reflection/JNI/serialization
# ============================================================================

# Flutter embedding (uses reflection for plugin registration)
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Stripe (payment processing - uses reflection for JSON serialization)
-keep class com.stripe.android.** { *; }

# ============================================================================
# OPTIONAL DEPENDENCIES - Features we don't use but are referenced by libraries
# These are R8's intended mechanism for declaring optional dependencies
# ============================================================================

# Flutter Deferred Components (we don't use this feature)
# Flutter engine references old Play Core API for split APK delivery
# Wildcard to catch ALL Play Core classes referenced by Flutter
-dontwarn com.google.android.play.core.**

# Stripe Push Provisioning (we don't use this feature)
# Optional feature for adding cards to Google Pay wallet from within app
# Wildcard to catch ALL push provisioning classes
-dontwarn com.stripe.android.pushProvisioning.**

# Google Maps & Places (native bindings)
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.android.libraries.places.** { *; }

# OneSignal (push notifications)
-keep class com.onesignal.** { *; }

# Geolocator plugin
-keep class com.baseflow.geolocator.** { *; }

# ============================================================================
# REQUIRED ATTRIBUTES FOR REFLECTION & DEBUGGING
# ============================================================================
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes InnerClasses,EnclosingMethod

# ============================================================================
# ANDROID FRAMEWORK REQUIREMENTS
# ============================================================================

# Parcelable (Android IPC)
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Serializable (Java serialization)
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Native methods (JNI)
-keepclasseswithmembernames class * {
    native <methods>;
}

# Enums (reflection for values()/valueOf())
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
