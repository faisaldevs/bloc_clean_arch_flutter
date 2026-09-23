import 'package:bloc_clean_arch_flutter/features/counter/presentation/bloc/counter_bloc.dart';
import 'package:bloc_clean_arch_flutter/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Creates and provides the bloc. Kept separate from [CounterView] so the
/// view can be widget-tested with a mock bloc and no service locator.
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CounterBloc>()..add(const CounterStarted()),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: const Text('Counter'),
      ),
      body: Center(
        // `listener` handles one-off side effects, `builder` renders state.
        // A SnackBar belongs in the listener: builder runs on every rebuild.
        child: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            if (state is CounterLoadFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return switch (state) {
              CounterLoadSuccess(:final counter) => Text(
                  '${counter.value}',
                  style: theme.textTheme.displayLarge,
                ),
              CounterLoadFailure(:final message) => Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              _ => const SizedBox.square(
                  dimension: 48,
                  child: CircularProgressIndicator(),
                ),
            };
          },
        ),
      ),
      floatingActionButton: const _CounterActions(),
    );
  }
}

class _CounterActions extends StatelessWidget {
  const _CounterActions();

  @override
  Widget build(BuildContext context) {
    // `context.read`, not `watch`: these buttons dispatch events but do not
    // need to rebuild when the state changes.
    final bloc = context.read<CounterBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'decrement',
          tooltip: 'Decrement',
          onPressed: () => bloc.add(const CounterDecrementPressed()),
          child: const Icon(Icons.remove),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          heroTag: 'reset',
          tooltip: 'Reset',
          onPressed: () => bloc.add(const CounterResetPressed()),
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          heroTag: 'increment',
          tooltip: 'Increment',
          onPressed: () => bloc.add(const CounterIncrementPressed()),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
