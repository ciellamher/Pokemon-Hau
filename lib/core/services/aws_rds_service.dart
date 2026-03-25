import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AWS RDS Service Foundation
/// 
/// ⚠️ NOT YET INTEGRATED — This is a foundation/scaffold only.
/// 
/// Architecture: Flutter → API Gateway → Lambda → RDS MySQL (Private Subnet)
/// 
/// VPC Configuration:
///   - VPC CIDR: 10.0.0.0/16
///   - Public Subnets:  10.0.1.0/24 (az-1a), 10.0.2.0/24 (az-1b)
///   - Private Subnets: 10.0.10.0/24 (az-1a), 10.0.11.0/24 (az-1b)
///   - Security Group (rds-sg): Inbound MySQL 3306 from lambda-sg
///   - Security Group (lambda-sg): Outbound to rds-sg
/// 
/// RDS Instance:
///   - Engine: MySQL 8.0
///   - Instance: db.t3.micro
///   - DB Name: pokemon_hau_db
///   - Public Access: No (private subnet only)

class AwsRdsService {
  static final AwsRdsService _instance = AwsRdsService._internal();
  factory AwsRdsService() => _instance;
  AwsRdsService._internal();

  /// Base URL for the API Gateway endpoint (connects to Lambda → RDS)
  /// Set this in .env as AWS_API_GATEWAY_URL
  String get _baseUrl => dotenv.env['AWS_API_GATEWAY_URL'] ?? '';

  /// Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-api-key': dotenv.env['AWS_API_KEY'] ?? '',
  };

  // ──────────────────────────────────────────────
  // AUTH ENDPOINTS (Lambda → RDS)
  // ──────────────────────────────────────────────

  /// Register a new user
  Future<Map<String, dynamic>?> register({
    required String email,
    required String username,
    required String playerName,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'username': username,
          'player_name': playerName,
          'password': password,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('AWS Register Error: $e');
    }
    return null;
  }

  /// Login an existing user
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('AWS Login Error: $e');
    }
    return null;
  }

  // ──────────────────────────────────────────────
  // PROFILE ENDPOINTS
  // ──────────────────────────────────────────────

  /// Fetch user profile by ID
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile/$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('AWS Get Profile Error: $e');
    }
    return null;
  }

  /// Update user profile
  Future<bool> updateProfile(String userId, {String? playerName, String? username}) async {
    try {
      final body = <String, dynamic>{};
      if (playerName != null) body['player_name'] = playerName;
      if (username != null) body['username'] = username;

      final response = await http.put(
        Uri.parse('$_baseUrl/profile/$userId'),
        headers: _headers,
        body: json.encode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('AWS Update Profile Error: $e');
    }
    return false;
  }

  // ──────────────────────────────────────────────
  // POKEMON ENDPOINTS
  // ──────────────────────────────────────────────

  /// Save a caught pokemon
  Future<bool> saveCaughtPokemon({
    required String userId,
    required int pokemonId,
    required String name,
    required String spriteUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/pokemon/catch'),
        headers: _headers,
        body: json.encode({
          'user_id': userId,
          'pokemon_id': pokemonId,
          'name': name,
          'sprite_url': spriteUrl,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('AWS Save Pokemon Error: $e');
    }
    return false;
  }

  /// Get user's caught pokemon collection
  Future<List<Map<String, dynamic>>> getCaughtPokemon(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pokemon/$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print('AWS Get Pokemon Error: $e');
    }
    return [];
  }

  // ──────────────────────────────────────────────
  // RANKINGS ENDPOINT
  // ──────────────────────────────────────────────

  /// Fetch leaderboard rankings
  Future<List<Map<String, dynamic>>> getRankings({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rankings?limit=$limit'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print('AWS Rankings Error: $e');
    }
    return [];
  }

  // ──────────────────────────────────────────────
  // ACCOUNT MANAGEMENT
  // ──────────────────────────────────────────────

  /// Delete user account and all associated data
  Future<bool> deleteAccount(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/account/$userId'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('AWS Delete Account Error: $e');
    }
    return false;
  }
}
