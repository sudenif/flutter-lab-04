import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/content.dart';
import '../../../../data/repositories/content_repository_interface.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this.contentRepository) : super(HomeInitial()) {
    on<HomeLoad>(_load);
  }
  final ContentRepositoryInterface contentRepository;

  Future<void> _load(HomeLoad event, Emitter<HomeState> emit) async {
    if (state is HomeLoadInProgress) return;
    emit(HomeLoadInProgress());
    try {
      final content = await contentRepository.getContent();
      emit(HomeLoadSuccess(content: content));
    } catch (exception, stackTrace) {
      addError(exception, stackTrace);
      emit(HomeLoadFailure(exception: exception));
    }
  }
}
