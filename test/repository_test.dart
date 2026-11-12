import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_catalog/data/repositories/content_repository.dart';

final recipeJson = <String, dynamic>{
  'id': 3,
  'name': 'Cookies',
  'ingredients': ['Flour'],
  'instructions': ['Bake'],
  'prepTimeMinutes': 15,
  'cookTimeMinutes': 10,
  'servings': 24,
  'difficulty': 'Easy',
  'cuisine': 'American',
  'caloriesPerServing': 150,
  'rating': 4.9,
  'image': '',
};

class TestAdapter implements HttpClientAdapter {
  TestAdapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object body, [int status = 200]) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ContentRepository repository(ResponseBody Function(RequestOptions) respond) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.org'));
  dio.httpClientAdapter = TestAdapter(respond);
  return ContentRepository(dio: dio);
}

void main() {
  test('list endpoint parses recipes envelope', () async {
    final repo = repository((request) {
      expect(request.path, '/recipes');
      expect(request.queryParameters['limit'], 10);
      return jsonResponse({
        'recipes': [recipeJson],
      });
    });
    final items = await repo.getContent();
    expect(items.single.id, 3);
    expect(items.single.title, 'Cookies');
  });

  test('empty list is a valid successful response', () async {
    final repo = repository((_) => jsonResponse({'recipes': []}));
    expect(await repo.getContent(), isEmpty);
  });

  test('malformed envelope does not silently become an empty list', () async {
    final repo = repository((_) => jsonResponse({'unexpected': []}));
    await expectLater(repo.getContent(), throwsA(isA<ContentException>()));
  });

  test('connection failure is translated into a readable error', () async {
    final repo = repository(
      (r) => throw DioException(
        requestOptions: r,
        type: DioExceptionType.connectionError,
      ),
    );
    await expectLater(repo.getContent(), throwsA(isA<ContentException>()));
  });
}
