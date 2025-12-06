import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { parent, driver, admin }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.index,
        'createdAt': createdAt.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        role: UserRole.values[json['role'] ?? 0],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: UserRole.values[data['role'] ?? 0],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _cachedUserKey = 'cached_user';

  // Get current Firebase user
  fb.User? get currentFirebaseUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Register new user with Firebase Auth + Firestore profile
  Future<({bool success, String message})> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    debugPrint('=== AUTH SERVICE: REGISTER START ===');
    debugPrint('Email: $email');
    debugPrint('Name: $name');

    try {
      debugPrint('Calling Firebase createUserWithEmailAndPassword...');

      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint('Firebase Auth result: ${credential.user?.uid}');

      if (credential.user == null) {
        debugPrint('ERROR: credential.user is null!');
        return (success: false, message: 'Registration failed');
      }

      debugPrint('User created with UID: ${credential.user!.uid}');
      debugPrint('Saving user profile to Firestore...');

      // Create user profile in Firestore
      final user = User(
        id: credential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set({
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'role': user.role.index,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Firestore profile saved successfully!');

      // Cache user locally
      await _cacheUser(user);

      debugPrint('=== AUTH SERVICE: REGISTER SUCCESS ===');
      return (success: true, message: 'Registration successful');
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('=== AUTH SERVICE: FirebaseAuthException ===');
      debugPrint('Code: ${e.code}');
      debugPrint('Message: ${e.message}');
      String message = 'Registration failed';
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'email-already-in-use':
          message = 'Email already registered';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = e.message ?? 'Registration failed';
      }
      return (success: false, message: message);
    } catch (e, stackTrace) {
      debugPrint('=== AUTH SERVICE: GENERIC ERROR ===');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      return (success: false, message: 'Registration failed: $e');
    }
  }

  // Login user with Firebase Auth
  Future<({bool success, String message, User? user})> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return (success: false, message: 'Login failed', user: null);
      }

      // Get user profile from Firestore
      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!doc.exists) {
        // User exists in Auth but not Firestore - create minimal profile
        final user = User(
          id: credential.user!.uid,
          name: credential.user!.displayName ?? 'User',
          email: credential.user!.email ?? email,
          phone: '',
          role: UserRole.parent,
          createdAt: DateTime.now(),
        );
        await _cacheUser(user);
        return (success: true, message: 'Login successful', user: user);
      }

      final user = User.fromFirestore(doc);
      await _cacheUser(user);

      return (success: true, message: 'Login successful', user: user);
    } on fb.FirebaseAuthException catch (e) {
      String message = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Invalid password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password';
          break;
        default:
          message = e.message ?? 'Login failed';
      }
      return (success: false, message: message, user: null);
    } catch (e) {
      return (success: false, message: 'Login failed: $e', user: null);
    }
  }

  // Get current user (from cache first, then Firestore)
  Future<User?> getCurrentUser() async {
    // First check if Firebase user exists
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      await _clearCache();
      return null;
    }

    // Try to get from cache first (faster)
    final cached = await _getCachedUser();
    if (cached != null && cached.id == firebaseUser.uid) {
      return cached;
    }

    // Fall back to Firestore
    try {
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        final user = User.fromFirestore(doc);
        await _cacheUser(user);
        return user;
      }
    } catch (e) {
      // Firestore error - return cached if available
      if (cached != null) return cached;
    }

    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    await _clearCache();
  }

  // Cache user locally for fast access
  Future<void> _cacheUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedUserKey, jsonEncode(user.toJson()));
  }

  Future<User?> _getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_cachedUserKey);
      if (json != null) {
        return User.fromJson(jsonDecode(json));
      }
    } catch (e) {
      // Ignore cache errors
    }
    return null;
  }

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedUserKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedInAsync() async {
    return _auth.currentUser != null;
  }
}
