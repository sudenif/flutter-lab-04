import 'package:dio/dio.dart';

import '../endpoints.dart';
import '../models/content.dart';
import 'content_repository_interface.dart';

class ContentException implements Exception {
  const ContentException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Репозиторий скрывает транспорт и структуру JSON от экранов и BLoC.
class ContentRepository implements ContentRepositoryInterface {
  ContentRepository({required this.dio});
  final Dio dio;

  @override
  Future<List<Content>> getContent() async {
    try {
      final response = await dio.get<dynamic>(
        Endpoints.recipes,
        queryParameters: {'limit': 10},
      );
      final data = response.data;
      if (data is! Map<String, dynamic> || data['recipes'] is! List) {
        throw const FormatException('recipes must be a list');
      }
      return (data['recipes'] as List)
          .map((item) => Content.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (e) {
      throw _networkError(e);
    } on FormatException {
      throw const ContentException(
        'Сервер вернул некорректный список рецептов.',
      );
    } on TypeError {
      throw const ContentException(
        'Формат данных рецепта не соответствует модели.',
      );
    }
  }

  ContentException _networkError(DioException error) {
    if (error.response?.statusCode == 404) {
      return const ContentException('Рецепт не найден. Проверьте его номер.');
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ContentException(
        'Сервер не ответил вовремя. Повторите запрос.',
      );
    }
    if (error.response != null) {
      return ContentException(
        'Ошибка сервера HTTP ${error.response!.statusCode}. Повторите запрос.',
      );
    }
    return const ContentException(
      'Нет соединения с сервером. Проверьте интернет и повторите запрос.',
    );
  }
}
