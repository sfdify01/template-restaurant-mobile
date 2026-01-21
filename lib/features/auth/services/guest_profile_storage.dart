import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/market_api_service.dart';

class GuestProfile {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? customerId;
  final int? loyaltyBalance;
  final DateTime createdAt;

  const GuestProfile({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.customerId,
    this.loyaltyBalance,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'customerId': customerId,
    'loyaltyBalance': loyaltyBalance,
    'createdAt': createdAt.toIso8601String(),
  };

  factory GuestProfile.fromJson(Map<String, dynamic> json) {
    return GuestProfile(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      customerId: json['customerId'] as String?,
      loyaltyBalance: json['loyaltyBalance'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class GuestProfileStorage {
  GuestProfileStorage._();
  static final GuestProfileStorage instance = GuestProfileStorage._();

  static const String _storageKey = 'guest_profile';

  Future<void> saveFromOrder(
    OrderDetailsResponse order, {
    LoyaltySummary? loyalty,
  }) async {
    final contact = order.contact ?? {};
    final name = contact['name'] as String?;
    final email = contact['email'] as String?;
    final phone = contact['phone'] as String?;
    final customerId = order.customerId;
    final identifier = customerId ?? email ?? phone ?? order.id;
    final profile = GuestProfile(
      id: 'guest-$identifier',
      name: name?.trim().isEmpty == true ? null : name,
      email: email?.trim().isEmpty == true ? null : email,
      phone: phone?.trim().isEmpty == true ? null : phone,
      customerId: customerId,
      loyaltyBalance: loyalty?.newBalance,
      createdAt: DateTime.now(),
    );

    await saveProfile(profile);
  }

  Future<void> saveProfile(GuestProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
      if (kDebugMode) {
        debugPrint('[GuestProfileStorage] Saved guest profile: ${profile.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GuestProfileStorage] Failed to save guest profile: $e');
      }
    }
  }

  Future<GuestProfile?> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return GuestProfile.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GuestProfileStorage] Failed to load guest profile: $e');
      }
      return null;
    }
  }

  Future<void> clearProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      if (kDebugMode) {
        debugPrint('[GuestProfileStorage] Cleared guest profile');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GuestProfileStorage] Failed to clear guest profile: $e');
      }
    }
  }
}
