import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scanner/provider/app_provider.dart';
import 'package:scanner/ui/initialize.dart';
import 'package:scanner/utilities/constants.dart';
import 'package:scanner/utilities/shared_pref.dart';
import 'package:scanner/utilities/textfieldStyle.dart';
import 'package:scanner/widgets/button.dart';
import 'package:scanner/widgets/snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Map<String, dynamic> loginDetails = {"username": "", "password": ""};

  void _login() {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username == "user" && password == "pass") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Credentials')),
      );
    }
  }

  void handleLogin() {
    if (formKey.currentState!.validate()) {
      Provider.of<AppProvider>(context, listen: false).login(
          payload: loginDetails,
          callback: (code, message, id) {
            launchSnackbar(
                context: context,
                mode: code != 200 ? "ERROR" : "SUCCESS",
                message: message);

            if (code == 200) {
              setKeyValue('isLoggedIn', 'true');
              setKeyValue('userId', id);
              context.goNamed('init');
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Broiler Counter App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextFormField(
                onChanged: (val) =>
                    setState(() => loginDetails["username"] = val),
                style: const TextStyle(fontSize: 21),
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Username is required";
                  }
                  return null;
                },
                decoration: textFieldStyle(
                    labelStyle: const TextStyle(fontSize: 21),
                    label: 'Username',
                    contentPadding: const EdgeInsets.all(10.0),
                    backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                onChanged: (val) =>
                    setState(() => loginDetails["password"] = val),
                style: const TextStyle(fontSize: 21),
                obscureText: true,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Password is required";
                  }
                  return null;
                },
                decoration: textFieldStyle(
                    labelStyle: const TextStyle(fontSize: 21),
                    label: 'Password',
                    contentPadding: const EdgeInsets.all(10.0),
                    backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
              ),
              const SizedBox(height: 20),
              Button(
                label: "LOGIN",
                onPress: handleLogin,
                textColor: Colors.white,
                backgroundColor: ACCENT_PRIMARY,
              )
            ],
          ),
        ),
      ),
    );
  }
}
