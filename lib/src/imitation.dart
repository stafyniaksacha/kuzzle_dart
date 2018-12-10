import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'helpers.dart';
import 'imitation_databse.dart';

class ImitationServer {
  final ImitationDatabase imitationDatabase = ImitationDatabase();

  String transform(String data) {
    final jsonRequest = json.decode(data);
    // print(jsonRequest);
    var response = <String, dynamic>{};
    switch (jsonRequest['controller']) {
      case 'admin':
        response = _admin(jsonRequest);
        break;
      case 'auth':
        response = _auth(jsonRequest);
        break;
      case 'bulk':
        response = _bulk(jsonRequest);
        break;
      case 'collection':
        response = _collection(jsonRequest);
        break;
      case 'document':
        response = _document(jsonRequest);
        break;
      case 'index':
        response = _index(jsonRequest);
        break;
      case 'ms':
        response = _ms(jsonRequest);
        break;
      case 'realtime':
        response = _realtime(jsonRequest);
        break;
      case 'security':
        response = _security(jsonRequest);
        break;
      case 'server':
        response = _server(jsonRequest);
        break;
      default:
        break;
    }
    response['requestId'] = jsonRequest['requestId'];
    response['controller'] = jsonRequest['controller'];
    // print(imitationDatabase.db);
    return json.encode(response);
  }

  Map<String, dynamic> _admin(jsonRequest) {
    final response = <String, dynamic>{};

    switch (jsonRequest['action']) {
      case 'dump':
      case 'resetCache':
      case 'resetDatabase':
      case 'resetKuzzleData':
      case 'resetSecurity':
      case 'shutdowndefault:':
        response['result'] = <String, dynamic>{};
        break;
    }
    return response;
  }

  Map<String, dynamic> _auth(jsonRequest) {
    final response = <String, dynamic>{};

    switch (jsonRequest['action']) {
      case 'checkToken':
      case 'createMyCredentials':
      case 'credentialsExist':
      case 'deleteMyCredentials':
      case 'getCurrentUser':
      case 'getMyCredentials':
      case 'getMyRights':
      case 'getStrategies':
      case 'login':
        response['result'] = <String, dynamic>{
          'uuid': Uuid().v1(),
          'jwt': Uuid().v1(),
          'expiresAt': 1321085955000,
          'ttl': 360000
        };
        break;
      case 'logout':
      case 'updateMyCredentials':
      case 'updateSelf':
      case 'validateMyCredentials':
      default:
        response['result'] = <String, dynamic>{};
        break;
    }

    return response;
  }

  Map<String, dynamic> _bulk(jsonRequest) {
    final response = <String, dynamic>{};

    switch (jsonRequest['action']) {
      case 'import':
      default:
        break;
    }

    return response;
  }

  /// takes in json and returns a string
  Map<String, dynamic> _collection(jsonRequest) {
    final doesIndexExist =
        imitationDatabase.doesIndexExist(jsonRequest['index']);
    final doesCollectionExist =
        imitationDatabase.doesCollectionExist(jsonRequest);

    final response = <String, dynamic>{};
    switch (jsonRequest['action']) {
      case 'create':
        if (!doesIndexExist) {
          response['result'] = <String, dynamic>{'acknowledged': false};
        } else {
          imitationDatabase.db[jsonRequest['index']]
              [jsonRequest['collection']] = <String, dynamic>{};
          response['result'] = <String, dynamic>{'acknowledged': true};
        }
        break;
      case 'deleteSpecifications':
        response['result'] = <String, dynamic>{
          'acknowledged': true,
        };
        break;
      case 'exists':
        response['result'] = doesCollectionExist;
        break;
      case 'getMapping':
        response['result'] = <String, dynamic>{
          jsonRequest['index']: <String, dynamic>{
            'mappings': <String, dynamic>{
              jsonRequest['collection']: <String, dynamic>{
                'properties': <String, dynamic>{}
              }
            }
          }
        };
        break;
      case 'getSpecifications':
        response['result'] = <String, dynamic>{
          'collection': jsonRequest['collection'],
          'index': jsonRequest['index'],
          'validation': <String, dynamic>{'fields': {}},
        };
        break;
      case 'list':
        response['result'] = <String, dynamic>{
          'collections': <Map<String, dynamic>>[
            <String, dynamic>{
              'name': 'posts',
              'type': 'realtime',
            },
          ]
        };
        break;
      case 'scrollSpecifications':
        response['result'] = <String, dynamic>{
          'scrollId': Uuid().v1(),
          'total': 1,
          'hits': <Map<String, dynamic>>[
            <String, dynamic>{
              '_id': '${jsonRequest['index']}#posts',
              'index': jsonRequest['index'],
              '_score': 1,
              '_source': <String, dynamic>{
                'collection': 'posts',
                'index': jsonRequest['index'],
                'validation': <String, dynamic>{}
              }
            },
          ]
        };
        break;
      case 'searchSpecifications':
        response['result'] = <String, dynamic>{
          '_shards': <String, dynamic>{
            'failed': 0,
            'successful': 5,
            'total': 5,
          },
          'total': 5,
          'hits': <Map<String, dynamic>>[
            <String, dynamic>{
              '_id': '${jsonRequest['index']}#posts',
              'index': jsonRequest['index'],
              '_score': 1,
              '_source': <String, dynamic>{
                'collection': 'posts',
                'index': jsonRequest['index'],
                'validation': <String, dynamic>{}
              }
            },
          ]
        };
        break;
      case 'truncate':
        response['result'] = {
          'ids': (imitationDatabase.db[jsonRequest['index']]
                  [jsonRequest['collection']] as Map<String, dynamic>)
              .keys
              .toList(),
        };
        break;
      case 'updateMapping':
        response['result'] = <String, dynamic>{};
        break;
      case 'updateSpecifications':
        response['result'] = <String, dynamic>{
          jsonRequest['index']: <String, dynamic>{
            jsonRequest['collection']: <String, dynamic>{
              'fields': {}
            } // This is a validation
          },
        };
        break;
      case 'validateSpecifications':
        response['result'] = <String, dynamic>{
          'valid': true,
          'details': <dynamic>[],
          'description': '',
        };
        break;
      default:
        response['result'] = <String, dynamic>{};
        break;
    }
    response['status'] = 200;
    response['error'] = null;
    response['index'] = jsonRequest['index'];
    response['collection'] = jsonRequest['collection'];
    return response;
  }

  Map<String, dynamic> _document(jsonRequest) {
    final response = <String, dynamic>{};
    switch (jsonRequest['action']) {
      case 'count':
        if (imitationDatabase.doesCollectionExist(jsonRequest)) {
          response['result'] = <String, dynamic>{
            'count': imitationDatabase.getCollection(jsonRequest).length,
          };
        }
        break;
      case 'create':
        if (imitationDatabase.doesCollectionExist(jsonRequest)) {
          final String id = Uuid().v1();
          (imitationDatabase.db[jsonRequest['index']][jsonRequest['collection']]
                  as Map<String, dynamic>)
              .addAll(<String, dynamic>{
            id: jsonRequest['body'],
          });
          response['result'] = <String, dynamic>{
            '_id': id,
            '_version': 1,
            '_source': jsonRequest['body'],
          };
        }
        break;
      case 'createOrReplace':
      case 'delete':
        if (imitationDatabase.doesCollectionExist(jsonRequest)) {
          (imitationDatabase.db[jsonRequest['index']][jsonRequest['collection']]
                  as Map<String, dynamic>)
              .remove(jsonRequest['_id']);
          response['result'] = <String, dynamic>{
            '_id': jsonRequest['_id'],
          };
        }
        break;
      case 'deleteByQuery':
      case 'exists':
        response['result'] =
            imitationDatabase.doesCollectionExist(jsonRequest) &&
                (imitationDatabase.db[jsonRequest['index']]
                        [jsonRequest['collection']] as Map<String, dynamic>)
                    .containsKey(jsonRequest['_id']);
        break;
      case 'get':
        if (imitationDatabase.doesCollectionExist(jsonRequest)) {
          final Map<String, dynamic> documentBody = (imitationDatabase
                  .db[jsonRequest['index']][jsonRequest['collection']]
              as Map<String, dynamic>)[jsonRequest['_id']];
          response['result'] = <String, dynamic>{
            '_id': jsonRequest['_id'],
            '_source': documentBody,
            '_version': 1,
          };
        }
        break;
      case 'mCreate':
      case 'mCreateOrReplace':
      case 'mDelete':
      case 'mGet':
      case 'mReplace':
      case 'mUpdate':
      case 'replace':
      case 'scroll':
        response['result'] = <String, dynamic>{
          'hits': <Map<String, dynamic>>[],
        };
        break;
      case 'search':
        response['result'] = <String, dynamic>{
          'hits': <Map<String, dynamic>>[],
        };
        break;
      case 'update':
        if (imitationDatabase.doesCollectionExist(jsonRequest)) {
          (imitationDatabase.db[jsonRequest['index']][jsonRequest['collection']]
                  as Map<String, dynamic>)[jsonRequest['_id']]
              .addAll(jsonRequest['body']);
          response['result'] = <String, dynamic>{
            '_id': jsonRequest['_id'],
            'created': false,
            'result': 'updated',
            '_version': 1,
          };
        }
        break;
      case 'validate':
        response['result'] = <String, dynamic>{
          'errorMessages': emptyMap,
          'valid': true,
        };
        break;
      default:
        response['result'] = <String, dynamic>{};
        break;
    }
    response['status'] = 200;
    response['error'] = null;
    response['index'] = jsonRequest['index'];
    response['collection'] = jsonRequest['collection'];
    return response;
  }

  Map<String, dynamic> _index(jsonRequest) {
    final response = <String, dynamic>{};

    switch (jsonRequest['action']) {
      case 'create':
        imitationDatabase.db[jsonRequest['index']] = <String, dynamic>{};
        response['result'] = <String, dynamic>{
          'acknowledged': true,
          'shards_acknowledged': true,
        };
        break;
      case 'delete':
        imitationDatabase.db.remove(jsonRequest['index']);
        response['result'] = <String, dynamic>{
          'acknowledged': true,
        };
        break;
      case 'exists':
        response['result'] =
            imitationDatabase.doesIndexExist(jsonRequest['index']);
        break;
      case 'getAutoRefresh':
        response['result'] = false;
        break;
      case 'list':
        response['result'] = <String, dynamic>{
          'indexes': imitationDatabase.db.keys.toList(),
        };
        break;
      case 'mDelete':
      case 'refresh':
        response['result'] = <String, dynamic>{
          '_shards': <String, dynamic>{
            'failed': 0,
            'successful': 10,
            'total': 10,
          },
        };
        break;
      case 'refreshInternal':
      case 'setAutoRefresh':
        response['result'] = <String, dynamic>{
          'response': jsonRequest['body']['autoRefresh'],
        };
        break;
      default:
        response['result'] = <String, dynamic>{};
        break;
    }

    return response;
  }

  Map<String, dynamic> _ms(jsonRequest) {
    final response = <String, dynamic>{};

    switch (jsonRequest['action']) {
      case 'append':
        imitationDatabase.cache[jsonRequest['_id']] =
            jsonRequest['body']['value'];
        response['result'] = imitationDatabase.cache[jsonRequest['_id']].length;
        break;
      case 'bitcount':
        final byteString = stringToBytes(
            imitationDatabase.cache[jsonRequest['_id']] as String);
        final count = '1'.allMatches(byteString).length;
        response['result'] = count;
        break;
      case 'bitop':
        final keys = jsonRequest['body']['keys'];
        final List<dynamic> byteValues =
            keys.map((key) => int.parse(imitationDatabase.cache[key])).toList();
        int value;
        switch (jsonRequest['body']['operation']) {
          case 'AND':
            value = byteValues.fold(
                0, (prevValue, curValue) => prevValue & curValue);
            break;
          case 'OR':
            value = byteValues.fold(
                0, (prevValue, curValue) => prevValue | curValue);
            break;
        }
        imitationDatabase.cache[jsonRequest['_id']] = value.toString();
        response['result'] = value.toString().length;
        break;
      case 'bitpos':
        final bytesStr =
            stringToBytes(imitationDatabase.cache[jsonRequest['_id']]);
        response['result'] =
            bytesStr.indexOf(jsonRequest['bit'].toString()) + 1;
        break;
      case 'dbsize':
        response['result'] = imitationDatabase.cache.keys.length;
        break;
      case 'decr':
        final String value = imitationDatabase.cache[jsonRequest['_id']];
        final valueInt = int.parse(value) - 1;
        response['result'] = valueInt;
        imitationDatabase.cache[jsonRequest['_id']] = valueInt.toString();
        break;
      case 'decrby':
        final String value = imitationDatabase.cache[jsonRequest['_id']];
        final valueInt = int.parse(value) - jsonRequest['body']['value'];
        response['result'] = valueInt;
        imitationDatabase.cache[jsonRequest['_id']] = valueInt.toString();
        break;
      case 'del':
        var deletedCount = 0;
        jsonRequest['body']['keys'].forEach((key) {
          if (imitationDatabase.cache.containsKey(key)) {
            imitationDatabase.cache.remove(key);
            deletedCount += 1;
          }
        });
        response['result'] = deletedCount;
        break;
      case 'exists':
        var existsCount = 0;
        jsonRequest['keys'].forEach((key) {
          if (imitationDatabase.cache.containsKey(key)) {
            existsCount += 1;
          }
        });
        response['result'] = existsCount;
        break;
      case 'expire':
        response['result'] = 1;
        break;
      case 'expireat':
        response['result'] = 1;
        break;
      case 'flushdb':
        imitationDatabase.cache.removeWhere((key, value) => true);
        response['result'] = 'OK';
        break;
      case 'geoadd':
      case 'geodist':
      case 'geohash':
      case 'geopos':
      case 'georadius':
      case 'georadiusbymember':
      case 'get':
        response['result'] = imitationDatabase.cache[jsonRequest['_id']];
        break;
      case 'getbit':
      case 'getrange':
      case 'getset':
      case 'hdel':
      case 'hexists':
      case 'hget':
      case 'hgetall':
      case 'hincrby':
      case 'hincrbyfloat':
      case 'hkeys':
      case 'hlen':
      case 'hmget':
      case 'hmset':
      case 'hscan':
      case 'hset':
      case 'hsetnx':
      case 'hstrlen':
      case 'hvals':
      case 'incr':
      case 'incrby':
      case 'incrbyfloat':
      case 'keys':
      case 'lindex':
      case 'linsert':
      case 'llen':
      case 'lpop':
      case 'lpush':
      case 'lpushx':
      case 'lrange':
      case 'lrem':
      case 'lset':
      case 'ltrim':
      case 'mget':
      case 'mset':
      case 'msetnx':
      case 'object':
      case 'persist':
      case 'pexpire':
      case 'pexpireat':
      case 'pfadd':
      case 'pfcount':
      case 'pfmerge':
      case 'ping':
      case 'psetex':
      case 'pttl':
      case 'randomkey':
      case 'rename':
      case 'renamenx':
      case 'rpop':
      case 'rpoplpush':
      case 'rpush':
      case 'rpushx':
      case 'sadd':
      case 'scan':
      case 'scard':
      case 'sdiff':
      case 'sdiffstore':
      case 'set':
        imitationDatabase.cache[jsonRequest['_id']] =
            jsonRequest['body']['value'];
        response['result'] = 'OK';
        break;
      case 'setex':
      case 'setnx':
      case 'sinter':
      case 'sinterstore':
      case 'sismember':
      case 'smembers':
      case 'smove':
      case 'sort':
      case 'spop':
      case 'srandmember':
      case 'srem':
      case 'sscan':
      case 'strlen':
      case 'sunion':
      case 'sunionstore':
      case 'time':
      case 'touch':
      case 'ttl':
      case 'type':
      case 'zadd':
      case 'zcard':
      case 'zcount':
      case 'zincrby':
      case 'zinterstore':
      case 'zlexcount':
      case 'zrange':
      case 'zrangebylex':
      case 'zrangebyscore':
      case 'zrank':
      case 'zrem':
      case 'zremrangebylex':
      case 'zremrangebyrank':
      case 'zremrangebyscore':
      case 'zrevrange':
      case 'zrevrangebylex':
      case 'zrevrangebyscore':
      case 'zrevrank':
      case 'zscan':
      case 'zscore':
      case 'zunionstore':
      default:
        break;
    }

    return response;
  }

  Map<String, dynamic> _realtime(jsonRequest) {
    final response = <String, dynamic>{};

    switch (jsonRequest['action']) {
      case 'count':
      case 'join':
      case 'list':
      case 'publish':
      case 'subscribe':
      case 'unsubscribe':
      case 'validate':
      default:
        break;
    }

    return response;
  }

  Map<String, dynamic> _security(jsonRequest) {
    final response = <String, dynamic>{};

    switch (jsonRequest['action']) {
      case 'createCredentials':
      case 'createFirstAdmin':
      case 'createOrReplaceProfile':
      case 'createOrReplaceRole':
      case 'createProfile':
      case 'createRestrictedUser':
      case 'createRole':
      case 'createUser':
      case 'deleteCredentials':
      case 'deleteProfile':
      case 'deleteRole':
      case 'deleteUser':
      case 'getAllCredentialFields':
      case 'getCredentialFields':
      case 'getCredentials':
      case 'getCredentialsById':
      case 'getProfile':
      case 'getProfileMapping':
      case 'getProfileRights':
      case 'getRole':
      case 'getRoleMapping':
      case 'getUser':
      case 'getUserMapping':
      case 'getUserRights':
      case 'hasCredentials':
      case 'mDeleteProfiles':
      case 'mDeleteRoles':
      case 'mDeleteUsers':
      case 'mGetProfiles':
      case 'mGetRoles':
      case 'replaceUser':
      case 'scrollProfiles':
      case 'scrollUsers':
      case 'searchProfiles':
      case 'searchRoles':
      case 'searchUsers':
      case 'updateCredentials':
      case 'updateProfile':
      case 'updateProfileMapping':
      case 'updateRole':
      case 'updateRoleMapping':
      case 'updateUser':
      case 'updateUserMapping':
      case 'validateCredentials':
      default:
        break;
    }

    return response;
  }

  Map<String, dynamic> _server(jsonRequest) {
    final response = <String, dynamic>{};

    switch (jsonRequest['action']) {
      case 'adminExists':
      case 'getAllStats':
      case 'getConfig':
      case 'getLastStats':
      case 'getStats':
      case 'info':
      case 'now':
      default:
        break;
    }

    return response;
  }
}