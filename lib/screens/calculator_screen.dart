import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/calculator_cubit.dart';
import '../cubit/calculator_state.dart';
import 'history_screen.dart';
import '../cubit/history_cubit.dart';

class CalculatorScreen extends StatelessWidget {
  final TextEditingController _controllerA = TextEditingController();
  final TextEditingController _controllerB = TextEditingController();

  CalculatorScreen({super.key}) {
    _controllerA.addListener(() {});
    _controllerB.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalculatorCubit, CalculatorState>(
      listener: (context, state) {
        if (state is CalculatorInputState) {
          if (state.numberA != null && _controllerA.text != state.numberA.toString()) {
            _controllerA.text = state.numberA.toString();
          }
          if (state.numberB != null && _controllerB.text != state.numberB.toString()) {
            _controllerB.text = state.numberB.toString();
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: _buildBody(context, state),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, CalculatorState state) {
    String title = 'Калькулятор (a+b)²';
    String? studentName;

    if (state is CalculatorInitial) {
      studentName = state.studentName;
    } else if (state is CalculatorInputState) {
      studentName = state.studentName;
      title = 'Ввод данных';
    } else if (state is CalculatorResultState) {
      title = 'Результат';
    }

    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.history),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => HistoryCubit(),
                child: const HistoryScreen(),
              ),
            ),
          );
        },
      ),
      actions: [
        if (studentName != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: GestureDetector(
                onTap: () => _showEditNameDialog(context, studentName!),
                child: Text(
                  studentName,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final nameController = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить ФИО'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'ФИО студента',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                context.read<CalculatorCubit>().updateStudentName(newName);
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, CalculatorState state) {
    if (state is CalculatorInitial || state is CalculatorInputState) {
      return _buildInputScreen(context, state);
    } else if (state is CalculatorResultState) {
      return _buildResultScreen(context, state);
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildInputScreen(BuildContext context, CalculatorState state) {
    final cubit = context.read<CalculatorCubit>();
    final inputState = state is CalculatorInputState ? state : null;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Поле для редактирования имени уже в AppBar
          
          TextField(
            controller: _controllerA,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Число a',
              border: const OutlineInputBorder(),
              errorText: inputState?.errorA,
            ),
            onChanged: cubit.updateNumberA,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controllerB,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Число b',
              border: const OutlineInputBorder(),
              errorText: inputState?.errorB,
            ),
            onChanged: cubit.updateNumberB,
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text('Согласен на обработку данных'),
            value: inputState?.agreementChecked ?? false,
            onChanged: (value) => cubit.toggleAgreement(value ?? false),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (inputState?.errorA == null &&
                  inputState?.errorB == null &&
                  inputState?.numberA != null &&
                  inputState?.numberB != null &&
                  (inputState?.agreementChecked ?? false)) {
                cubit.calculate();
              } else {
                cubit.calculate(); // Покажет ошибки валидации
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text('Рассчитать и сохранить'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, CalculatorResultState state) {
    final cubit = context.read<CalculatorCubit>();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Введённые данные:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('a = ${state.numberA}', style: const TextStyle(fontSize: 16)),
          Text('b = ${state.numberB}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 30),
          const Text(
            'Результат:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            state.formula,
            style: const TextStyle(fontSize: 20, color: Colors.blue),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Результат сохранен в историю',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => HistoryCubit(),
                          child: const HistoryScreen(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Просмотреть историю'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: cubit.reset,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Новый расчет'),
            ),
          ),
        ],
      ),
    );
  }
}