import 'package:bloc/bloc.dart';
import 'package:shared/main.dart';
import 'package:shared/modules/authentication/resources/authentication_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authentication_bloc_public.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitial());
  final AuthenticationRepository authenticationService =
      AuthenticationRepository();
  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    final SharedPreferences sharedPreferences = await prefs;
    if (event is AppLoadedup) {
      yield* _mapAppSignUpLoadedState(event);
    }

    if (event is UserSignUp) {
      yield* _mapUserSignupToState(event);
    }

    if (event is UserLogin) {
      yield* _mapUserLoginState(event);
    }
    if (event is UserLogOut) {
      await Future.delayed(Duration(milliseconds: 500)); // a simulated delay
      authenticationService.logout();
      sharedPreferences.setString('authtoken', null);
      sharedPreferences.setString('userId', null);
      yield UserLogoutState();
    }
    if (event is GetUserData) {
      final firebaseUser = await authenticationService.getUserData();
      if (firebaseUser != null)
        yield SetUserData(
            email: firebaseUser.email, avatar: firebaseUser.avatar);
      else
        yield AuthenticationStart();
    }
  }

  Stream<AuthenticationState> _mapAppSignUpLoadedState(
      AppLoadedup event) async* {
    yield AuthenticationLoading();
    try {
      await Future.delayed(Duration(milliseconds: 500)); // a simulated delay
      final SharedPreferences sharedPreferences = await prefs;
      if (sharedPreferences.getString('authtoken') != null) {
        yield AppAutheticated();
      } else {
        yield AuthenticationStart();
      }
    } catch (e) {
      yield AuthenticationFailure(
          message: e.message ?? 'An unknown error occurred');
    }
  }

  Stream<AuthenticationState> _mapUserSignupToState(UserSignUp event) async* {
    final SharedPreferences sharedPreferences = await prefs;
    yield AuthenticationLoading();
    try {
      await Future.delayed(Duration(milliseconds: 500)); // a simulated delay
      final firebaseUser = await authenticationService
          .signUpWithEmailAndPassword(event.email, event.password);
      if (firebaseUser != null) {
        sharedPreferences.setString('authtoken', firebaseUser.token);
        sharedPreferences.setString('userId', firebaseUser.uid);
        yield AppAutheticated();
      }
    } catch (e) {
      yield AuthenticationFailure(
          message: e.toString() ?? 'An unknown error occurred');
    }
  }

  Stream<AuthenticationState> _mapUserLoginState(UserLogin event) async* {
    final SharedPreferences sharedPreferences = await prefs;
    yield AuthenticationLoading();
    try {
      await Future.delayed(Duration(milliseconds: 500)); // a simulated delay
      final firebaseUser = await authenticationService
          .loginWithEmailAndPassword(event.email, event.password);
      if (firebaseUser != null) {
        sharedPreferences.setString('authtoken', firebaseUser.token);
        yield AppAutheticated();
      }
    } catch (e) {
      yield AuthenticationFailure(
          message: e.toString() ?? 'An unknown error occurred');
    }
  }
}
