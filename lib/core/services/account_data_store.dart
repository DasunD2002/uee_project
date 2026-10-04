import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

class AccountSession {
  const AccountSession(this.userId, this.token);
  final String userId, token;

  static Future<AccountSession?> current() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    final token = prefs.getString('jwt_token');
    if (id == null || token == null || id.isEmpty || token.isEmpty) return null;
    return AccountSession(id, token);
  }

  Future<bool> get isCurrent async {
    final current = await AccountSession.current();
    return current?.userId == userId && current?.token == token;
  }
}

class AccountDataException implements Exception {
  const AccountDataException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

/// A versioned, private document. Writes carry the session captured before
/// queueing, so an old account's pending write can never target a new account.
class AccountDataStore extends ChangeNotifier {
  AccountDataStore(this.key, {http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _ownsClient = client == null,
      _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  final String key;
  final http.Client _client;
  final bool _ownsClient;
  final String _baseUrl;
  AccountSession? _session;
  Map<String, dynamic> data = {};
  int _version = 0, _generation = 0;
  Future<void>? _loading;
  Future<void> _tail = Future.value();
  bool loaded = false, saving = false;
  String? error;

  Uri get _uri => Uri.parse('$_baseUrl/api/v1/me/data/$key');

  Map<String, String> _headers(AccountSession session) => {
    'Authorization': 'Bearer ${session.token}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<void> load({bool force = false}) async {
    final session = await AccountSession.current();
    if (session == null) {
      reset();
      throw const AccountDataException(
        'Please sign in to load your saved data.',
        statusCode: 401,
      );
    }
    if (_session?.userId != session.userId ||
        _session?.token != session.token) {
      reset();
      _session = session;
    }
    if (loaded && !force) return;
    if (_loading != null) return _loading!;
    final generation = _generation;
    _loading = () async {
      try {
        final response = await _client
            .get(_uri, headers: _headers(session))
            .timeout(const Duration(seconds: 30));
        final body = _decode(response);
        if (generation != _generation || !await session.isCurrent) return;
        data = Map<String, dynamic>.from(body['data'] as Map);
        _version = (body['version'] as num).toInt();
        loaded = true;
        error = null;
      } catch (e) {
        if (generation == _generation) error = _message(e);
        rethrow;
      } finally {
        if (generation == _generation) {
          _loading = null;
          notifyListeners();
        }
      }
    }();
    return _loading!;
  }

  Future<void> save(Map<String, dynamic> snapshot) {
    final sessionFuture = AccountSession.current();
    final generation = _generation;
    // Detach mutable nested collections before the request is queued.
    final copy = jsonDecode(jsonEncode(snapshot)) as Map<String, dynamic>;
    final operation = _tail.catchError((Object _) {}).then((_) async {
      final session = await sessionFuture;
      if (session == null) {
        throw const AccountDataException(
          'Please sign in to save your data.',
          statusCode: 401,
        );
      }
      if (generation != _generation || !await session.isCurrent) {
        throw const AccountDataException(
          'Your account changed. Please reopen this screen.',
        );
      }
      await load();
      if (generation != _generation || !await session.isCurrent) {
        throw const AccountDataException(
          'Your account changed. Please reopen this screen.',
        );
      }
      saving = true;
      notifyListeners();
      try {
        final response = await _client
            .put(
              _uri,
              headers: _headers(session),
              body: jsonEncode({'version': _version, 'data': copy}),
            )
            .timeout(const Duration(seconds: 30));
        final body = _decode(response);
        if (generation != _generation || !await session.isCurrent) return;
        data = Map<String, dynamic>.from(body['data'] as Map);
        _version = (body['version'] as num).toInt();
        error = null;
      } catch (e) {
        if (generation == _generation) error = _message(e);
        rethrow;
      } finally {
        if (generation == _generation) {
          saving = false;
          notifyListeners();
        }
      }
    });
    _tail = operation;
    return operation;
  }

  Future<void> flush() => _tail;

  void reset() {
    _generation++;
    _session = null;
    data = {};
    _version = 0;
    loaded = false;
    saving = false;
    error = null;
    _loading = null;
    _tail = Future.value();
    notifyListeners();
  }

  static String _message(Object e) {
    if (e is TimeoutException) return 'The server took too long. Please retry.';
    if (e is http.ClientException) return 'Could not connect. Please retry.';
    return e.toString();
  }

  static Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const AccountDataException(
        'The server returned an invalid response.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AccountDataException(
        (body['errorDescription'] ??
                body['detail'] ??
                (response.statusCode == 401
                    ? 'Your session expired. Please sign in again.'
                    : 'Could not save your data. Please retry.'))
            .toString(),
        statusCode: response.statusCode,
      );
    }
    if (body['data'] is! Map || body['version'] is! num) {
      throw const AccountDataException(
        'The server returned invalid saved data.',
      );
    }
    return body;
  }

  @override
  void dispose() {
    _generation++;
    if (_ownsClient) _client.close();
    super.dispose();
  }
}
