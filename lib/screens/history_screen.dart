import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История расчетов'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Очистить историю'),
                  content: const Text('Вы уверены, что хотите удалить всю историю расчетов?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<HistoryCubit>().clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('Очистить', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is HistoryError) {
            return Center(child: Text(state.error));
          }
          
          if (state is HistoryLoaded) {
            final calculations = state.calculations;
            
            if (calculations.isEmpty) {
              return const Center(
                child: Text(
                  'История расчетов пуста',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: calculations.length,
              itemBuilder: (context, index) {
                final record = calculations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      record.formula,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('a = ${record.numberA}, b = ${record.numberB}'),
                        Text(
                          'Результат: ${record.result}',
                          style: const TextStyle(color: Colors.blue),
                        ),
                        Text(
                          'Время: ${record.timestamp.toString().substring(0, 16)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Удалить запись'),
                            content: Text('Удалить расчет: ${record.formula}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<HistoryCubit>().deleteCalculation(record.id!);
                                  Navigator.pop(context);
                                },
                                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}