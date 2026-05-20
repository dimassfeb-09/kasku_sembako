import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_home_metrics_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeMetricsUseCase getHomeMetricsUseCase;

  HomeBloc({required this.getHomeMetricsUseCase}) : super(HomeInitial()) {
    on<LoadHomeMetricsEvent>(_onLoadHomeMetrics);
  }

  Future<void> _onLoadHomeMetrics(
    LoadHomeMetricsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeMetricsLoading());
    final result = await getHomeMetricsUseCase(
      isAdmin: event.isAdmin,
      userId: event.userId,
    );
    result.fold(
      (failure) => emit(HomeMetricsError(failure.message)),
      (metrics) => emit(HomeMetricsLoaded(metrics)),
    );
  }
}
