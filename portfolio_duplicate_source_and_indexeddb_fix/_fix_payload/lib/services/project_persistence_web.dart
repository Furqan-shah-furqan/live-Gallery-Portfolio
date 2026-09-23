import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _databaseName = 'live_systems_gallery_local_database';
const String _objectStoreName = 'portfolio_data';
const int _databaseVersion = 1;

Database? _database;

Future<String?> readProjectJson(String key) async {
  try {
    final database = await _openDatabase();
    final transaction = database.transaction(
      _objectStoreName,
      idbModeReadOnly,
    );
    final value = await transaction.objectStore(_objectStoreName).getObject(key);
    await transaction.completed;

    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
  } catch (_) {
    // Fall back to the previous SharedPreferences/localStorage value.
  }

  final legacyValue = await _readLegacyValue(key);
  if (legacyValue != null && legacyValue.trim().isNotEmpty) {
    try {
      await writeProjectJson(key, legacyValue);
    } catch (_) {
      // The legacy value can still be used if migration is unavailable.
    }
  }

  return legacyValue;
}

Future<void> writeProjectJson(String key, String value) async {
  try {
    final database = await _openDatabase();
    final transaction = database.transaction(
      _objectStoreName,
      idbModeReadWrite,
    );
    await transaction.objectStore(_objectStoreName).put(value, key);
    await transaction.completed;
    return;
  } catch (indexedDbError) {
    // Fallback for browser environments where IndexedDB is disabled.
    final preferences = await SharedPreferences.getInstance();
    try {
      final saved = await preferences.setString(key, value);
      if (saved) return;
    } catch (_) {
      // Surface the primary IndexedDB error below.
    }

    throw StateError(
      'The browser could not save the portfolio data: $indexedDbError',
    );
  }
}

Future<Database> _openDatabase() async {
  final cachedDatabase = _database;
  if (cachedDatabase != null) return cachedDatabase;

  if (!idbFactoryWebSupported) {
    throw UnsupportedError('IndexedDB is not supported by this browser.');
  }

  final database = await idbFactoryWeb.open(
    _databaseName,
    version: _databaseVersion,
    onUpgradeNeeded: (event) {
      final database = event.database;
      if (!database.objectStoreNames.contains(_objectStoreName)) {
        database.createObjectStore(_objectStoreName);
      }
    },
  );

  _database = database;
  return database;
}

Future<String?> _readLegacyValue(String key) async {
  try {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(key);
    if (value != null && value.trim().isNotEmpty) {
      return value;
    }
  } catch (_) {
    // No legacy browser value is available.
  }

  return null;
}
