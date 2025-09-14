import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );
  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
  // static _googleAuth = await _googleSignIn.authentication;

  static Future signOut = _googleSignIn.disconnect();
}
