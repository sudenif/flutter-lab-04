import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'content.g.dart';

/// Одна модель используется в карточке списка и на подробном экране.
@JsonSerializable()
class Content extends Equatable {
  const Content({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.cuisine,
    required this.caloriesPerServing,
    required this.rating,
    required this.image,
  });

  final int id;
  @JsonKey(name: 'name')
  final String title;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisine;
  final int caloriesPerServing;
  final double rating;
  final String image;

  int get totalMinutes => prepTimeMinutes + cookTimeMinutes;
  String get description => '$cuisine • $totalMinutes мин • $servings порц.';

  factory Content.fromJson(Map<String, dynamic> json) =>
      _$ContentFromJson(json);
  Map<String, dynamic> toJson() => _$ContentToJson(this);

  @override
  List<Object?> get props => [
    id,
    title,
    ingredients,
    instructions,
    prepTimeMinutes,
    cookTimeMinutes,
    servings,
    difficulty,
    cuisine,
    caloriesPerServing,
    rating,
    image,
  ];
}
