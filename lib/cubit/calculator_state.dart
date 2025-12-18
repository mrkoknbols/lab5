abstract class CalculatorState {}

// Начальное состояние с загрузкой ФИО из SharedPreferences
class CalculatorInitial extends CalculatorState {
  final String studentName;
  
  CalculatorInitial({required this.studentName});
}

// Состояние ввода - основное состояние приложения
class CalculatorInputState extends CalculatorState {
  final String studentName;
  final double? numberA;
  final double? numberB;
  final bool agreementChecked;
  final String? errorA;
  final String? errorB;

  CalculatorInputState({
    required this.studentName,
    this.numberA,
    this.numberB,
    this.agreementChecked = false,
    this.errorA,
    this.errorB,
  });
}

// Результат расчета (после сохранения в БД)
class CalculatorResultState extends CalculatorState {
  final double numberA;
  final double numberB;
  final double result;
  final String formula;
  final bool isSaved; // Флаг, что данные сохранены в БД

  CalculatorResultState({
    required this.numberA,
    required this.numberB,
    required this.result,
    required this.formula,
    this.isSaved = true, // По умолчанию true для ЛР5
  });
}