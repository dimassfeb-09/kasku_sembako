import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasirku_sembako/core/error/exceptions.dart';
import 'package:kasirku_sembako/features/auth/data/datasources/store_profile_remote_datasource.dart';

/// Serves a canned response (or error) for GET /api/store-profile without a
/// real socket, so the envelope handling can be asserted directly.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter.body(this.statusCode, String body)
    : _body = body,
      _throw = null;
  _StubAdapter.fails(this._throw) : statusCode = 0, _body = '';

  final int statusCode;
  final String _body;
  final Object? _throw;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_throw != null) throw _throw;
    return ResponseBody.fromString(
      _body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

StoreProfileRemoteDataSourceImpl _dsWith(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = adapter;
  return StoreProfileRemoteDataSourceImpl(dio: dio);
}

void main() {
  group('get', () {
    // The regression: the server answers "no profile yet" with 200
    // {"profile": null}. Reading the envelope as the profile produced an
    // all-blank model, which splash/login mistook for a completed setup.
    test('returns null when the server reports no profile', () async {
      final ds = _dsWith(_StubAdapter.body(200, '{"profile": null}'));

      expect(await ds.get(), isNull);
    });

    test('parses a wrapped profile', () async {
      final ds = _dsWith(
        _StubAdapter.body(
          200,
          '{"profile": {"businessName": "Toko Makmur", "ownerName": "Dimas", "phone": "0812"}}',
        ),
      );

      final profile = await ds.get();

      expect(profile, isNotNull);
      expect(profile!.businessName, 'Toko Makmur');
      expect(profile.ownerName, 'Dimas');
    });

    test('tolerates an unwrapped profile body', () async {
      final ds = _dsWith(
        _StubAdapter.body(200, '{"businessName": "Toko Makmur"}'),
      );

      expect((await ds.get())!.businessName, 'Toko Makmur');
    });

    test('maps a 401 to AuthException rather than letting Dio escape', () async {
      final options = RequestOptions(path: '/api/store-profile');
      final ds = _dsWith(
        _StubAdapter.fails(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'message': 'missing bearer token', 'code': 'TOKEN_MISSING'},
            ),
          ),
        ),
      );

      await expectLater(ds.get(), throwsA(isA<AuthException>()));
    });

    test('maps a connection failure to NetworkException', () async {
      final ds = _dsWith(
        _StubAdapter.fails(
          DioException(
            requestOptions: RequestOptions(path: '/api/store-profile'),
            type: DioExceptionType.connectionError,
          ),
        ),
      );

      await expectLater(ds.get(), throwsA(isA<NetworkException>()));
    });
  });

  group('save', () {
    test('maps errors instead of leaking a raw DioException', () async {
      final options = RequestOptions(path: '/api/store-profile');
      final ds = _dsWith(
        _StubAdapter.fails(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 500,
              data: {'message': 'failed to save profile', 'code': 'INTERNAL'},
            ),
          ),
        ),
      );

      await expectLater(
        ds.save(
          const StoreProfileModel(
            ownerName: 'Dimas',
            businessName: 'Toko Makmur',
            businessCategory: 'Sembako',
            phone: '0812',
            address: 'Jl. Merdeka',
          ),
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
