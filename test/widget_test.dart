// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class LoginPage extends StatefulWidget {
  final Database database;

  const LoginPage({required this.database, super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final List<Map<String, dynamic>> result = await widget.database.query(
      'users',
      where: "username = ? AND password = ?",
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登录成功')),
      );
      Navigator.pushReplacementNamed(context, 'homepage');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无效的凭据')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: '用户名'),
              key: Key('username_field'), // 添加键
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '密码'),
              key: Key('password_field'), // 添加键
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('登录'),
              key: Key('login_button'), // 添加键
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'register');
              },
              child: Text('注册'),
            ),
          ],
        ),
      ),
    );
  }
}