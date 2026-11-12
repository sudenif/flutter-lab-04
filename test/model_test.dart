import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_catalog/data/models/content.dart';

void main() {
  test('JSON name maps to title and numeric rating accepts an integer', () {
    final recipe = Content.fromJson({
      'id': 3,
      'name': 'Chocolate Chip Cookies',
      'ingredients': ['Flour', 'Chocolate'],
      'instructions': ['Mix', 'Bake'],
      'prepTimeMinutes': 15,
      'cookTimeMinutes': 10,
      'servings': 24,
      'difficulty': 'Easy',
      'cuisine': 'American',
      'caloriesPerServing': 150,
      'rating': 5,
      'image': 'https://example.org/3.webp',
    });
    expect(recipe.title, 'Chocolate Chip Cookies');
    expect(recipe.rating, 5.0);
    expect(recipe.totalMinutes, 25);
    expect(recipe.toJson()['name'], 'Chocolate Chip Cookies');
    expect(recipe.instructions, ['Mix', 'Bake']);
  });
}
