import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/local_database.dart';
import '../data/shared_prefs.dart';
import 'calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(CalculatorInitial(studentName: 'Урюмцев В.Э.')) {
    _loadSavedData();
  }

  double? _numberA;
  double? _numberB;
  bool _agreementChecked = false;
  String? _errorA;
  String? _errorB;

  // Загрузить сохраненные данные
  Future<void> _loadSavedData() async {
    final savedName = await AppPreferences.getStudentName();
    final savedAgreement = await AppPreferences.getAgreement();
    
    final studentName = savedName ?? 'Урюмцев В.Э.';
    _agreementChecked = savedAgreement;
    
    emit(CalculatorInputState(
      studentName: studentName,
      agreementChecked: _agreementChecked,
    ));
  }

  // Обновить ФИО
  void updateStudentName(String name) {
    AppPreferences.saveStudentName(name);
    
    if (state is CalculatorInputState) {
      final currentState = state as CalculatorInputState;
      emit(CalculatorInputState(
        studentName: name,
        numberA: currentState.numberA,
        numberB: currentState.numberB,
        agreementChecked: currentState.agreementChecked,
        errorA: currentState.errorA,
        errorB: currentState.errorB,
      ));
    } else {
      emit(CalculatorInputState(
        studentName: name,
        agreementChecked: _agreementChecked,
      ));
    }
  }

  void updateNumberA(String value) {
    if (value.isEmpty) {
      _numberA = null;
      _errorA = null;
    } else {
      final parsed = double.tryParse(value);
      if (parsed == null) {
        _errorA = 'Введите корректное число';
      } else {
        _numberA = parsed;
        _errorA = null;
      }
    }
    _emitInputState();
  }

  void updateNumberB(String value) {
    if (value.isEmpty) {
      _numberB = null;
      _errorB = null;
    } else {
      final parsed = double.tryParse(value);
      if (parsed == null) {
        _errorB = 'Введите корректное число';
      } else {
        _numberB = parsed;
        _errorB = null;
      }
    }
    _emitInputState();
  }

  void toggleAgreement(bool value) {
    _agreementChecked = value;
    AppPreferences.saveAgreement(value);
    _emitInputState();
  }

  void _emitInputState() {
    String studentName = 'Урюмцев В.Э.';
    
    // Получаем текущее имя из состояния
    if (state is CalculatorInputState) {
      studentName = (state as CalculatorInputState).studentName;
    } else if (state is CalculatorInitial) {
      studentName = (state as CalculatorInitial).studentName;
    }
    
    emit(CalculatorInputState(
      studentName: studentName,
      numberA: _numberA,
      numberB: _numberB,
      agreementChecked: _agreementChecked,
      errorA: _errorA,
      errorB: _errorB,
    ));
  }

  // Расчет и сохранение
  Future<void> calculate() async {
    if (_numberA == null || _numberB == null || !_agreementChecked) {
      _emitInputState();
      return;
    }

    final a = _numberA!;
    final b = _numberB!;
    final result = (a + b) * (a + b);
    final formula = '($a + $b)² = ${a + b}² = $result';

    // Сохраняем в БД
    final record = CalculationRecord(
      numberA: a,
      numberB: b,
      result: result,
      formula: formula,
      timestamp: DateTime.now(),
    );
    
    try {
      await LocalDatabase.insertCalculation(record);
      
      
      emit(CalculatorResultState(
        numberA: a,
        numberB: b,
        result: result,
        formula: formula,
        isSaved: true,
      ));
    } catch (e) {
      // Если ошибка сохранения
      emit(CalculatorResultState(
        numberA: a,
        numberB: b,
        result: result,
        formula: formula,
        isSaved: false,
      ));
    }
  }

  void reset() {
    _numberA = null;
    _numberB = null;
    _errorA = null;
    _errorB = null;
    
    String studentName = 'Урюмцев В.Э.';
    if (state is CalculatorInputState) {
      studentName = (state as CalculatorInputState).studentName;
    } else if (state is CalculatorResultState) {
      // Можно получить имя из предыдущего состояния или оставить дефолтное
    }
    
    emit(CalculatorInputState(
      studentName: studentName,
      agreementChecked: _agreementChecked,
    ));
  }
}