import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'collection.dart';
import 'credentials.dart';
import 'error.dart';
import 'event.dart';
import 'memorystorage.dart';
import 'response.dart';
import 'rights.dart';
import 'security.dart';
import 'serverinfo.dart';
import 'statistics.dart';
import 'user.dart';

enum KuzzleConnectType { auto }
enum KuzzleOfflineModeType { auto, manual }

typedef NotificationCallback = void Function(RawKuzzleResponse response);

class CheckTokenResponse {
  int valid;
  String state;
  int expiresAt;
}

class IndexCreationResponse {
  IndexCreationResponse.fromMap(Map<String, dynamic> map)
      : acknowledged = map['acknowledged'],
        shardsAcknowledged = map['shards_acknowledged'];

  final bool acknowledged;
  final bool shardsAcknowledged;
}

class Kuzzle {
  Kuzzle(
    this.host, {
    this.autoQueue = false,
    this.autoReconnect = true,
    this.autoReplay = false,
    this.autoResubscribe = true,
    this.connectType = KuzzleConnectType.auto,
    this.defaultIndex,
    this.headers,
    this.volatile,
    this.offlineMode,
    this.port = 7512,
    this.queueTTL = 120000,
    this.queueMaxSize = 500,
    this.replayInterval = 10,
    this.reconnectionDelay = 1000,
    this.sslConnection = false,
  }) {
    security = Security(this);
    _webSocket = IOWebSocketChannel.connect(
        'ws://' + host + ':' + port.toString() + '/ws');

    _webSocket.stream.listen((dynamic message) {
      final dynamic jsonResponse = json.decode(message);
      final String requestId = jsonResponse['requestId'];
      final RawKuzzleResponse response =
          RawKuzzleResponse.fromMap(this, jsonResponse);
      if (roomMaps.containsKey(response.room)) {
        roomMaps[response.room](response);
      } else if (futureMaps.containsKey(requestId) &&
          !futureMaps[requestId].isCompleted) {
        if (response.error == null) {
          futureMaps[requestId].complete(response);
        } else {
          futureMaps[requestId].completeError(response.error);
        }
        futureMaps.remove(requestId);
      }
    });
  }

  final String host;
  final bool autoQueue;
  final bool autoReconnect;
  final bool autoReplay;
  final bool autoResubscribe;
  final KuzzleConnectType connectType;
  final String defaultIndex;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> volatile;
  final KuzzleConnectType offlineMode;
  final int port;
  final int queueTTL;
  final int queueMaxSize;
  final int replayInterval;
  final int reconnectionDelay;
  final bool sslConnection;
  Security security;
  Map<String, Completer<RawKuzzleResponse>> futureMaps =
      <String, Completer<RawKuzzleResponse>>{};
  Map<String, NotificationCallback> roomMaps = <String, NotificationCallback>{};
  IOWebSocketChannel _webSocket; // Make private
  Uuid uuid = Uuid();

  String jwtToken;
  // int offlineQueue;
  // void Function() offlineQueueLoader;
  // void Function() queueFilter;

  Future<RawKuzzleResponse> addNetworkQuery(
    Map<String, dynamic> body, {
    bool queuable = true,
  }) {
    final Completer<RawKuzzleResponse> completer =
        Completer<RawKuzzleResponse>();
    final String requestId = uuid.v1();
    body.addAll(<String, dynamic>{
      'requestId': requestId,
    });
    if (queuable) {
      networkQuery(body);
      futureMaps[requestId] = completer;
    } else {
      networkQuery(body);
      completer.complete(
          RawKuzzleResponse.fromMap(this, <String, dynamic>{'result': body}));
    }
    return completer.future;
  }

  void networkQuery(Map<String, dynamic> body) {
    _webSocket.sink.add(json.encode(body));
  }

  void addListener(Event event, EventListener callback) =>
      throw ResponseError();

  Future<CheckTokenResponse> checkToken(String token) async =>
      throw ResponseError();

  Collection collection(String collection, {String index}) {
    index ??= defaultIndex;
    return Collection(this, collection, index);
  }

  void connect() => throw ResponseError();

  FutureOr<IndexCreationResponse> createIndex(
    String index, {
    bool queuable = true,
  }) async =>
      addNetworkQuery(<String, dynamic>{
        'index': index,
        'controller': 'index',
        'action': 'create',
      }, queuable: queuable)
          .then((RawKuzzleResponse onValue) =>
              IndexCreationResponse.fromMap(onValue.result));

  Future<Credentials> createMyCredentials(
          String strategy, Credentials credentials,
          {bool queuable = true}) async =>
      throw ResponseError();

  Future<RawKuzzleResponse> deleteMyCredentials(String strategy,
          {bool queuable = true}) async =>
      throw ResponseError();

  void disconect() => throw ResponseError();

  void flushQueue() => throw ResponseError();

  Future<List<Statistics>> getAllStatistics({bool queuable = true}) async =>
      throw ResponseError();

  Future<bool> getAutoRefresh({String index, bool queuable = true}) async =>
      throw ResponseError();

  String getJwtToken() => jwtToken;

  Future<Credentials> getMyCredentials(String strategy,
          {bool queuable = true}) async =>
      throw ResponseError();

  Future<Rights> getMyRights({bool queuable = true}) async =>
      throw ResponseError();

  Future<ServerInfo> getServerInfo({bool queuable = true}) =>
      throw ResponseError();

  Future<List<Statistics>> getStatistics(String timestamp,
          {bool queuable = true}) =>
      throw ResponseError();

  Future<List<Map<String, String>>> listCollections(
    String index, {
    bool queuable = true,
    int from,
    int size,
    String type,
  }) async =>
      throw ResponseError();

  Future<List<String>> listIndexes({bool queuable = true}) async =>
      throw ResponseError();

  Future<RawKuzzleResponse> login(
    String strategy, {
    Credentials credentials,
    String expiresIn,
  }) async =>
      throw ResponseError();

  Future<void> logout() async => throw ResponseError();

  MemoryStorage get memoryStorage => throw ResponseError();

  Future<int> now({bool queuable = true}) async => throw ResponseError();

  // void query({bool queuable = true}) => throw ResponseError();

  Future<void> refreshIndex(String index, {bool queuable = true}) =>
      throw ResponseError();

  void removeAllListeners({Event event}) => throw ResponseError();

  void removeListener(Event event, EventListener eventListener) =>
      throw ResponseError();

  void replayQueue() => throw ResponseError();

  Future<bool> setAutoRefresh(
    bool autoRefresh, {
    String index,
    bool queuable = true,
  }) async =>
      throw ResponseError();

  void setDefaultIndex(String index) => throw ResponseError();

  void setHeaders(Map<String, dynamic> newheaders, {bool replace = false}) =>
      throw ResponseError();

  void setJwtToken(String jwtToken) => throw ResponseError();

  void startQueuing() => throw ResponseError();

  void stopQueuing() => throw ResponseError();

  void unsetJwtToken() => throw ResponseError();

  Future<Credentials> updateMyCredentials(
    String strategy,
    Credentials credentials, {
    bool queuable = true,
  }) =>
      throw ResponseError();

  Future<User> updateSelf(Map<String, dynamic> content,
          {bool queuable = true}) async =>
      throw ResponseError();

  Future<bool> validateMyCredentials(
    String strategy,
    Credentials credentials, {
    bool queuable = true,
  }) async =>
      throw ResponseError();

  Future<User> whoAmI() async => throw ResponseError();
}
