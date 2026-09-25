import 'package:bloc_clean_arch_flutter/features/login/presentation/bloc/login_bloc.dart';
import 'package:bloc_clean_arch_flutter/features/login/presentation/pages/login_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

void main() {
  late MockLoginBloc bloc;

  setUpAll(
    () => registerFallbackValue(const LoginSubmitted(mobile: '', password: '')),
  );

  setUp(() {
    bloc = MockLoginBloc();
    when(() => bloc.state).thenReturn(const LoginInitial());
  });

  Future<void> pumpView(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<LoginBloc>.value(
        value: bloc,
        child: const LoginView(),
      ),
    ),
  );

  testWidgets('shows inline errors and does not submit invalid input', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.text('Log In'));
    await tester.pump();

    expect(find.text('Enter your mobile number'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('submits valid input to the bloc', (tester) async {
    await pumpView(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mobile'),
      '01700000000',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret123',
    );
    await tester.tap(find.text('Log In'));
    await tester.pump();

    verify(
      () => bloc.add(
        const LoginSubmitted(mobile: '01700000000', password: 'secret123'),
      ),
    ).called(1);
  });

  testWidgets('shows a spinner and disables the button while logging in', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(const LoginInProgress());
    await pumpView(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('shows a snackbar when login fails', (tester) async {
    whenListen(
      bloc,
      Stream.fromIterable(const [LoginInProgress(), LoginFailure('Wrong')]),
      initialState: const LoginInitial(),
    );
    await pumpView(tester);
    await tester.pump();

    expect(find.text('Wrong'), findsOneWidget);
  });
}
