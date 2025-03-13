import 'package:ai_tool/global/static.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';

//登录页面
class LoginPage extends StatefulWidget {
  final Database database;

  const LoginPage({super.key, required this.database});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberPassword = false; // 记住密码状态
  final TextEditingController _usernameController = TextEditingController(); // 账号输入框控制器
  final TextEditingController _passwordController = TextEditingController(); // 密码输入框控制器
  String _errorMessage = ''; // 错误消息

  // 登录验证方法
  Future<bool> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = '请输入账号和密码';
      });
      return false;
    }

    // 查询数据库验证账号和密码
    final List<Map<String, dynamic>> user = await widget.database.query(
      'user',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (user.isNotEmpty) {
      // 登录成功
      Fluttertoast.showToast(msg: '登录成功');
      return true;

    } else {
      // 登录失败
      setState(() {
        _errorMessage = '账号或密码错误';
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "登录注册页面",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.lightGreen[100],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.android,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                'AI-Tool',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 40),
              // 账号输入框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: '请输入账号',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 密码输入框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '请输入密码',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // 显示错误消息
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _rememberPassword,
                    onChanged: (value) {
                      setState(() {
                        _rememberPassword = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const Text('记住密码'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 处理注册逻辑
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage(database: widget.database)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      '注册',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:() async {
                      if(await _login()) {
                        // TODO 同步全局用户名与配置信息保存
                        Global.username = _usernameController.text;

                        Navigator.pushReplacementNamed(context, 'homepage');
                      }
                    }, // 调用登录验证方法
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      '登录',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}







// 注册页面
class RegisterPage extends StatefulWidget {
  final Database database;

  const RegisterPage({super.key, required this.database});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<bool> _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "账号和密码不能为空");
      return false;
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: "密码不一致");
      return false;
    }

    // 插入到数据库
    await widget.database.insert(
      'user',
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    Fluttertoast.showToast(msg: "注册成功");

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("注册页面", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.lightGreen[100],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.app_registration, size: 100, color: Colors.green),
              const SizedBox(height: 30),
              const Text(
                '用户注册',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 40),
              // 账号输入框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: '请输入账号',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 密码输入框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '请输入密码',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 重复密码输入框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '请重复输入密码',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 返回按钮（已添加导航功能）
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      '返回',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  // 确认按钮
                  ElevatedButton(
                    onPressed:() async {
                      if(await _register()){
                        Navigator.pop(context);
                      };
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      '确认',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// 点击提示消息
class ClickedMessage {
  const ClickedMessage({required this.content});
  final String content;

  void show(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// 账号类
class Account {
  final int id;
  final String account;
  final String password;
  Account({required this.id, required this.account, required this.password});
}


