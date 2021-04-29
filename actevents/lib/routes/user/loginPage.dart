import 'package:flutter/material.dart';
// import 'package:flutter_login/flutter_login.dart';
import '../../helpers/primaryButton.dart';
import '../../services/auth.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title, this.auth, this.onSignIn}) : super(key: key);

  final String title;
  final BaseAuth auth;
  final VoidCallback onSignIn;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  _LoginPageState() {
   _passwordController = TextEditingController(); 
  }

  static final formKey = new GlobalKey<FormState>();
  TextEditingController _passwordController;
  String _email;
  String _password;
  FormType _formType = FormType.login;
  String _authHint = '';

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          await widget.auth.signIn(_email, _password);
        } else {
          await widget.auth.createUser(_email, _password);
        }
        setState(() {
          _authHint = 'Signed In\n\nUser id: To be defined';
        });
        widget.onSignIn();
      } catch (e) {
        setState(() {
          _authHint = 'Sign In Error\n\n${e.toString()}';
        });
        print(e);
      }
    } else {
      setState(() {
        _authHint = '';
      });
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _authHint = '';
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _authHint = '';
    });
  }

  List<Widget> usernameAndPassword() {
    switch (_formType) {
      case FormType.login:
        return [
          padded(
              child: new TextFormField(
            key: new Key('email'),
            decoration: new InputDecoration(labelText: 'Email'),
            autocorrect: false,
            validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
            onSaved: (val) => _email = val,
          )),
          padded(
              child: new TextFormField(
            key: new Key('password'),
            decoration: new InputDecoration(labelText: 'Password'),
            obscureText: true,
            autocorrect: false,
            validator: (val) =>
                val.isEmpty ? 'Password can\'t be empty.' : null,
            onSaved: (val) => _password = val,
          )),
        ];
      case FormType.register:
        return [
          padded(
              child: new TextFormField(
            key: new Key('email'),
            decoration: new InputDecoration(labelText: 'Email'),
            autocorrect: false,
            validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
            onSaved: (val) => _email = val,
          )),
          padded(
              child: new TextFormField(
            key: new Key('password'),
            controller: _passwordController,
            decoration: new InputDecoration(labelText: 'Password'),
            obscureText: true,
            autocorrect: false,
            validator: (val) =>
                val.isEmpty ? 'Password can\'t be empty.' : null,
            onSaved: (val) => _password = val,
          )),
          padded(
              child: new TextFormField(
            key: new Key('passwordConfirm'),
            decoration: new InputDecoration(labelText: 'Password wiederholen'),
            obscureText: true,
            autocorrect: false,
            validator: (val) => 
            val != _passwordController.text ? "Passwörter müssen gleich sein" : null,
          )),
        ];
    }
  }

  List<Widget> submitWidgets() {
    switch (_formType) {
      case FormType.login:
        return [
          new PrimaryButton(
              key: new Key('login'),
              text: 'Login',
              height: 44.0,
              onPressed: validateAndSubmit),
          new TextButton(
              key: new Key('need-account'),
              child: new Text("Need an account? Register"),
              onPressed: moveToRegister),
        ];
      case FormType.register:
        return [
          new PrimaryButton(
              key: new Key('register'),
              text: 'Create an account',
              height: 44.0,
              onPressed: validateAndSubmit),
          new TextButton(
              key: new Key('need-login'),
              child: new Text("Have an account? Login"),
              onPressed: moveToLogin),
        ];
    }
    return null;
  }

  Widget hintText() {
    return new Container(
        //height: 80.0,
        padding: const EdgeInsets.all(32.0),
        child: new Text(_authHint,
            key: new Key('hint'),
            style: new TextStyle(fontSize: 18.0, color: Colors.grey),
            textAlign: TextAlign.center));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        backgroundColor: Colors.grey[300],
        body:

            // SafeArea(
            //   child: FlutterLogin(
            //       onLogin: _signIn,
            //       onSignup: _registerUser,
            //       onRecoverPassword: (_) => null,
            //       title: 'Flutter Amplify'),
            // ));

            new SingleChildScrollView(
                child: new Container(
                    padding: const EdgeInsets.all(16.0),
                    child: new Column(children: [
                      new Card(
                          child: new Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                            new Container(
                                padding: const EdgeInsets.all(16.0),
                                child: new Form(
                                    key: formKey,
                                    child: new Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: usernameAndPassword() +
                                          submitWidgets(),
                                    ))),
                          ])),
                      hintText()
                    ]))));
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}