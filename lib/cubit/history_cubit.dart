import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/local_database.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(HistoryLoading()) {
    loadHistory();
  }

  // Загрузить историю расчетов
  Future<void> loadHistory() async {
    try {
      emit(HistoryLoading());
      final calculations = await LocalDatabase.getAllCalculations();
      emit(HistoryLoaded(calculations: calculations));
    } catch (e) {
      emit(HistoryError(error: 'Ошибка загрузки истории: $e'));
    }
  }

  // Удалить запись из истории
  Future<void> deleteCalculation(int id) async {
    try {
      await LocalDatabase.deleteCalculation(id);
      await loadHistory(); // Перезагружаем историю
    } catch (e) {
      emit(HistoryError(error: 'Ошибка удаления: $e'));
    }
  }

  // Очистить всю историю
  Future<void> clearHistory() async {
    try {
      await LocalDatabase.clearHistory();
      await loadHistory();
    } catch (e) {
      emit(HistoryError(error: 'Ошибка очистки: $e'));
    }
  }
}