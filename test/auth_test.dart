import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not init to begin with', () {
      expect(provider.isInitialized, false);
    });
    test(
      'Cannot logout if not init',
      () {
        expect(provider.logout(),
            throwsA(const TypeMatcher<NoInitializedException>()));
      },
    );
    test(
      'Should be init now',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
    );
    test(
      'User should be null after init',
      () {
        expect(provider.currentUser, null);
      },
    );
    test('Should be able to init in less than 2 sec', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));
    test(
      'Create user should delegate to login function',
      () async {
        await provider.initialize();

        final badEmailUser =
            provider.createUser(email: 'a@a.com', password: '123456');
        expect(badEmailUser,
            throwsA(const TypeMatcher<UserNotFoundAuthException>()));

        final badPasswordUser =
            provider.createUser(email: 'test@gmail.com', password: '123456');
        expect(badPasswordUser,
            throwsA(const TypeMatcher<WrongPasswordAuthException>()));

        final user = await provider.createUser(
            email: 'test@gmail.com', password: '12345678');
        expect(provider.currentUser, user);
        expect(user.isEmailVerified, false);
      },
    );
    test('Logged in user should be able to email verified', () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test('Should be able to log out and log in again', () async {
      await provider.logout();
      await provider.login(email: 'test@gmail.com', password: '12345678');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NoInitializedException implements Exception {}

class MockAuthProvider extends AuthProvider {
  AuthUser? _user;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) throw NoInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    if (!_isInitialized) throw NoInitializedException();
    if (email == 'a@a.com') throw UserNotFoundAuthException();
    if (password == '123456') throw WrongPasswordAuthException();
    const user = AuthUser(
      id: '1',
      email: 'test@gmail.com',
      isEmailVerified: false,
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!_isInitialized) throw NoInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!_isInitialized) throw NoInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    const user = AuthUser(
      id: '1',
      email: 'test@gmail.com',
      isEmailVerified: true,
    );
    _user = user;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    if (!_isInitialized) throw NoInitializedException();
    await Future.delayed(const Duration(seconds: 1));
  }
}
