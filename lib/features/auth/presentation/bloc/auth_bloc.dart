import 'package:blog_app/core/usecase/usecase.dart';
import 'package:blog_app/features/auth/domain/entities/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/current_user.dart';
import '../../domain/usecases/user_login.dart';
import '../../domain/usecases/user_sign_up.dart';

part 'auth_state.dart';

part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;

  AuthBloc(
      {required UserSignUp userSignUp,
      required UserLogin userLogin,
      required CurrentUser currentUser})
      : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _currentUser(NoParams());
    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => emit(AuthSuccess(r)),
    );
  }

  void _onAuthSignUp(AuthSignUp event, Emitter emit) async {
    emit(AuthLoading());
    final response = await _userSignUp(UserSignUpParams(
      email: event.email,
      password: event.password,
      name: event.name,
    ));
    response.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final res = await _userLogin(UserLoginParams(
      email: event.email,
      password: event.password,
    ));

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthSuccess(r)));
  }
}
