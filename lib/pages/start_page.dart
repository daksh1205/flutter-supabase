import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _signInLoading = false;
  bool _signUpLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _googleSignInLoading = false;

  // Sign Up functionality
  // Syntax : supabase.auth.signup(email:'',password:'');
  // Sign In functionality
  // Syntax : supabase.auth.signInWithPassword(email:'',password:'');

  @override
  void dispose() {
    supabase.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    "assets/supabase.png",
                    height: 150,
                  ),
                  const SizedBox(height: 25),

                  // Email Field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field is required";
                      }
                      return null;
                    },
                    controller: _emailController,
                    decoration: const InputDecoration(
                      label: Text('Email'),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  // Password Field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field is required";
                      }
                      return null;
                    },
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      label: Text("Password"),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  _signInLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            final isValid = _formKey.currentState?.validate();
                            if (isValid != true) {
                              return;
                            }
                            setState(() {
                              _signInLoading = true;
                            });
                            try {
                              await supabase.auth.signInWithPassword(
                                  password: _passwordController.text,
                                  email: _emailController.text);
                              setState(() {
                                _signInLoading = false;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: const Text(
                                    "Sign In Failed",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              setState(() {
                                _signInLoading = false;
                              });
                            }
                          },
                          child: Text('Sign In'),
                        ),
                  const Divider(),
                  _signUpLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : OutlinedButton(
                          onPressed: () async {
                            final isValid = _formKey.currentState?.validate();
                            if (isValid != true) {
                              return;
                            }
                            setState(() {
                              _signUpLoading = true;
                            });
                            try {
                              await supabase.auth.signUp(
                                  password: _passwordController.text,
                                  email: _emailController.text);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: const Text(
                                    "Success! Confirmation Email Sent",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              setState(() {
                                _signUpLoading = false;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: const Text(
                                    "Sign Up Failed",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              setState(() {
                                _signUpLoading = false;
                              });
                            }
                          },
                          child: const Text('Sign Up'),
                        ),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Text("OR"),
                      ),
                      Expanded(
                        child: Divider(),
                      ),
                    ],
                  ),
                  _googleSignInLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : OutlinedButton.icon(
                          onPressed: () async {
                            setState(() {
                              _googleSignInLoading = true;
                            });
                            try {
                              // Syntax for Google Sign In
                              await supabase.auth.signInWithOAuth(
                                  OAuthProvider.google,
                                  redirectTo: kIsWeb
                                      ? null
                                      : "io.supabase.myflutterapp://login-callback");
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sign In Failed'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              setState(() {
                                _googleSignInLoading = false;
                              });
                            }
                          },
                          label: Text("Continue with Google"),
                          icon: Image.network(
                            "https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png",
                            height: 20,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
