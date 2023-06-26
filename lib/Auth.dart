import 'package:flutter/material.dart';
import 'authFunction.dart';
import 'reset_password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';

class AuthUser extends StatefulWidget {
  const AuthUser({Key? key}) : super(key: key);
  static late String sessionemail;
  static late String uid;
  @override
  State<AuthUser> createState() => _AuthUserState();
}

class CheckboxExample extends StatefulWidget {
  const CheckboxExample({super.key});

  @override
  State<CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<CheckboxExample> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }
}

class _AuthUserState extends State<AuthUser> {
  final _formkey = GlobalKey<FormState>();
  bool isLogin = true;
  String email = '';
  String password = '';
  String cPassword = "";
  String username = '';
  bool checkpass = false;
  bool _isChecked = false;

  void loadEmailandPassword() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var _email = _prefs.getString("email") ?? "";
    var _password = _prefs.getString("password") ?? "";
    var _qs = _prefs.getString("QS") ?? "";
    print(_email);
    print(_password);
    print(_qs);
    if (_email != "") {
      print("sign_in intiated");
      signin(_email, _password, context, false);
    }
    ;
  }

  @override
  void initState() {
    loadEmailandPassword();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Authentication'),
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 25, 63, 92),
          centerTitle: true,
          actions: [Icon(Icons.help)],
        ),
        body: SingleChildScrollView(
          child: Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 50.0,
                  width: double.infinity,
                ),
                Container(
                  child: Image.asset('images/l&t-sta logo.jpg'),
                  height: 200.0,
                ),
                Form(
                  key: _formkey,
                  child: Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !isLogin
                            ? TextFormField(
                                key: ValueKey('username'),
                                decoration:
                                    InputDecoration(hintText: "Enter Username"),
                                validator: (value) {
                                  if (value.toString().length < 3) {
                                    return 'Username is so small';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  setState(() {
                                    username = value!;
                                  });
                                },
                              )
                            : Container(),
                        TextFormField(
                          key: ValueKey('email'),
                          decoration: InputDecoration(hintText: "Enter Email"),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (!(value.toString().contains('@'))) {
                              return 'Invalid Email';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            setState(() {
                              email = value!;
                            });
                          },
                        ),
                        TextFormField(
                          obscureText: true,
                          key: ValueKey('password'),
                          decoration:
                              InputDecoration(hintText: "Enter Password"),
                          validator: (value) {
                            if (value.toString().length < 6) {
                              return 'Password is so small';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            setState(() {
                              password = value!;
                            });
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        !isLogin
                            ? TextFormField(
                                obscureText: true,
                                key: ValueKey('confirm password'),
                                decoration: InputDecoration(
                                    hintText: "Confirm Password"),
                                onSaved: (value) {
                                  setState(() {
                                    cPassword = value!;
                                  });
                                })
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: () {
                                  if (_formkey.currentState!.validate()) {
                                    _formkey.currentState!.save();
                                    if (isLogin) {
                                      signin(
                                          email, password, context, _isChecked);
                                    } else {
                                      final snackBar = SnackBar(
                                        content:
                                            EmailValidator.validate(email) ==
                                                    false
                                                ? Text('Email Format not Valid')
                                                : Text('Password Dont Match'),
                                        duration: Duration(
                                            seconds:
                                                5), // Adjust the duration as needed
                                      );
                                      final bool isValid =
                                          EmailValidator.validate(email) &&
                                              (cPassword == password);

                                      if (isValid == true) {
                                        signup(email, password, context,
                                            _isChecked);
                                        setState(() {
                                          isLogin = true;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                        setState(() {});
                                      }
                                    }
                                  }
                                },
                                child: isLogin
                                    ? Text(
                                        'Login',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        'Signup',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold),
                                      ))),
                        SizedBox(
                          height: 10,
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                            child: isLogin
                                ? Text(
                                    "Don't have an account? Signup",
                                    style: TextStyle(color: Colors.blueAccent),
                                  )
                                : Text(
                                    'Already Signed Up? Login',
                                    style: TextStyle(color: Colors.blueAccent),
                                  )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              activeColor: Color(0xff00C8E8),
                              value: _isChecked,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _isChecked = newValue!;
                                  print(_isChecked);
                                });
                              },
                            ),
                            Text(
                              "Keep me signed in",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        forgetPassword(context)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget forgetPassword(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 35,
    alignment: Alignment.bottomRight,
    child: TextButton(
      child: const Text(
        "Forgot Password?",
        style: TextStyle(color: Colors.red),
        textAlign: TextAlign.right,
      ),
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => ResetPassword())),
    ),
  );
}
