import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:secured_note_app/api/local_auth_api.dart';
import 'package:secured_note_app/constants.dart';
import 'package:secured_note_app/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  final googleUser = await googleSignIn.signIn();
                  if (googleUser != null) {
                    final googleAuthentication =
                        await googleUser.authentication;
                    final authCredential = GoogleAuthProvider.credential(
                      accessToken: googleAuthentication.accessToken,
                      idToken: googleAuthentication.idToken,
                    );

                    await firebaseAuth
                        .signInWithCredential(authCredential)
                        .then((value) async {
                      final isAuthenticated = await LocalAuthApi.authenticate();
                      if (isAuthenticated) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      }
                    });
                  }
                },
                child: const ListTile(
                  leading: Icon(
                    FontAwesomeIcons.google,
                  ),
                  horizontalTitleGap: 50,
                  title: Text(
                    'Sign in with Google',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
