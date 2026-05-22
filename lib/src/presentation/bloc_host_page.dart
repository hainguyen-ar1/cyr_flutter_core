import 'package:cyr_flutter_core/src/bloc/app_bloc.dart';
import 'package:cyr_flutter_core/src/bloc/app_cubit.dart';
import 'package:cyr_flutter_core/src/bloc/bloc_event.dart';
import 'package:cyr_flutter_core/src/presentation/error_dialog_mixin.dart';
import 'package:flutter/material.dart';

/// Base page for screens driven by an [AppBloc].
abstract class BlocHostPage extends StatefulWidget {
  const BlocHostPage({super.key});
}

/// State for [BlocHostPage]. Provide [errorStream] and implement [buildPage].
abstract class BlocHostPageState<T extends BlocHostPage> extends State<T>
    with ErrorDialogMixin<T> {
  Stream<String> get errorStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) listenErrors(errorStream);
    });
  }

  Widget buildPage(BuildContext context);

  @override
  Widget build(BuildContext context) => buildPage(context);
}

/// Base page for screens driven by an [AppCubit].
abstract class CubitHostPage extends StatefulWidget {
  const CubitHostPage({super.key});
}

/// State for [CubitHostPage]. Provide [errorStream] and implement [buildPage].
abstract class CubitHostPageState<T extends CubitHostPage> extends State<T>
    with ErrorDialogMixin<T> {
  Stream<String> get errorStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) listenErrors(errorStream);
    });
  }

  Widget buildPage(BuildContext context);

  @override
  Widget build(BuildContext context) => buildPage(context);
}

/// Convenience type aliases for custom page hierarchies.
typedef AppBlocPage<B extends AppBloc<BlocEvent, dynamic>> = BlocHostPage;
typedef AppCubitPage<C extends AppCubit<dynamic>> = CubitHostPage;
