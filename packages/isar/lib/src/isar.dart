part of isar;

/// Callback for a newly opened Isar instance.
typedef IsarOpenCallback = void Function(Isar);

/// Callback for a release Isar instance.
typedef IsarCloseCallback = void Function(String);

/// An instance of the Isar Database.
abstract class Isar {
  /// Smallest valid id.
  static const minId = kIsWeb ? -9007199254740991 : -9223372036854775807;

  /// Largest valid id.
  static const maxId = kIsWeb ? 9007199254740991 : 9223372036854775807;

  /// Placeholder for an auto-increment id.
  static const autoIncrement = -9223372036854775808;

  static final _instances = <String, Isar>{};
  static final _openCallbacks = <IsarOpenCallback>{};
  static final _closeCallbacks = <IsarCloseCallback>{};
  static String? _schema;
  var _isOpen = true;

  /// Name of the instance.
  final String name;

  late final Map<String, IsarCollection> _collections;

  @protected
  Isar(this.name, String schema) {
    if (_schema != null && _schema != schema) {
      throw 'Cannot open multiple Isar instances with different schema.';
    }
    _schema = schema;
    _instances[name] = this;
    for (var callback in _openCallbacks) {
      callback(this);
    }
  }

  /// Open a new Isar instance.
  static Future<Isar> open({
    required List<CollectionSchema> schemas,
    required String directory,
    String name = 'isar',
    bool relaxedDurability = true,
  }) {
    if (schemas.isEmpty) {
      throw IsarError('At least one collection needs to be opened.');
    }
    for (var schema in schemas) {
      for (var linkedCol in schema.linkedCollections) {
        if (!schemas.any((e) => e.name == linkedCol)) {
          throw IsarError(
              'Linked collection "$linkedCol" is not part of the schema.');
        }
      }
    }
    if (kIsWeb) {
      throw UnimplementedError();
    } else {
      return openIsarNative(
        schemas: schemas,
        directory: directory,
        name: name,
        relaxedDurability: relaxedDurability,
      );
    }
  }

  /// Is the instance open?
  bool get isOpen => _isOpen;

  /// Executes an asynchronous read-only transaction.
  Future<T> txn<T>(Future<T> Function(Isar isar) callback);

  /// Executes an asynchronous read-write transaction.
  Future<T> writeTxn<T>(Future<T> Function(Isar isar) callback,
      {bool silent = false});

  /// Executes a synchronous read-only transaction.
  T txnSync<T>(T Function(Isar isar) callback);

  /// Executes a synchronous read-write transaction.
  T writeTxnSync<T>(T Function(Isar isar) callback, {bool silent = false});

  /// @nodoc
  @protected
  void attachCollections(Map<String, IsarCollection> collections) {
    _collections = collections;
  }

  /// Get a collection by its name.
  ///
  /// You should use the generated extension methods instead.
  IsarCollection<T> getCollection<T>(String name) {
    final collection = _collections[name];
    if (collection is IsarCollection<T>) {
      return collection;
    } else {
      throw 'Unknown collection or invalid type. Make sure that you opened the collection.';
    }
  }

  /// Remove all data in this instance.
  Future<void> clear() async {
    for (var col in _collections.values) {
      await col.clear();
    }
  }

  /// Remove all data in this instance.
  void clearSync() {
    for (var col in _collections.values) {
      col.clearSync();
    }
  }

  /// Releases an Isar instance.
  ///
  /// If this is the only isolate that holds a reference to this instance, the
  /// Isar instance will be closed.
  ///
  /// Returns whether the instance was actually closed.
  Future<bool> close() {
    _isOpen = false;
    if (identical(_instances[name], this)) {
      _instances.remove(name);
      if (_instances.isEmpty) {
        _schema = null;
      }
    }
    for (var callback in _closeCallbacks) {
      callback(name);
    }
    return Future.value(false);
  }

  /// Returns the schema of this Instance. You should avoid usint the schema directly.
  @protected
  static String? get schema => _schema;

  /// A list of all Isar instances opened in the current isolate.
  static List<String> get instanceNames => _instances.keys.toList();

  /// Returns an Isar instance opened in the current isolate by its name.
  static Isar? getInstance(String name) {
    return _instances[name];
  }

  /// Registers a listener that is called whenever an Isar instance is opened.
  static void addOpenListener(IsarOpenCallback callback) {
    _openCallbacks.add(callback);
  }

  /// Removes a previously registered `IsarOpenCallback`.
  static void removeOpenListener(IsarOpenCallback callback) {
    _openCallbacks.remove(callback);
  }

  /// Registers a listener that is called whenever an Isar instance is
  /// released.
  static void addCloseListener(IsarCloseCallback callback) {
    _closeCallbacks.add(callback);
  }

  /// Removes a previously registered `IsarOpenCallback`.
  static void removeCloseListener(IsarCloseCallback callback) {
    _closeCallbacks.remove(callback);
  }

  /// Split a String into words according to Unicode Annex #29. Only words
  /// containing at least one alphanumeric character will be included.
  static List<String> splitWords(String input) {
    if (kIsWeb) {
      throw UnimplementedError();
    } else {
      return splitWordsNative(input);
    }
  }
}
