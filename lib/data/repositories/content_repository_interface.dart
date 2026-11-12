import '../models/content.dart';

abstract interface class ContentRepositoryInterface {
  Future<List<Content>> getContent();
}
