import '../data/local_database.dart';

abstract class HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<CalculationRecord> calculations;
  
  HistoryLoaded({required this.calculations});
}

class HistoryError extends HistoryState {
  final String error;
  
  HistoryError({required this.error});
}