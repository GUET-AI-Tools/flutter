import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ai_tool/routes/display_route.dart';
import 'package:ai_tool/routes/input_route.dart';
import 'package:flutter/material.dart';
import 'package:ai_tool/routes/login_route.dart'; // 登录页面
import 'package:ai_tool/routes/tabs.dart'; // 导入 tabs.dart 文件
import 'package:fluttertoast/fluttertoast.dart'; 


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openDatabase(
    join(await getDatabasesPath(), 'user_database.db'),
    onCreate: (db, version){
      return db.execute("CREATE TABLE user(id INTEGER PRIMARY KEY, username TEXT, password TEXT)",
      );
    },
    version: 1,
  );
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final Database database;

  const MyApp({required this.database});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 149, 83)),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'login':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => LoginPage(database: database),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case 'homepage':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => TabsPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case 'input':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => InputRoute(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          case 'display':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => DisplayRoute(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          default:
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => LoginPage(database: database),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
        }
      },
      initialRoute: 'login',

    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    // Navigator.of(context).removeRoute(LoginPage() as Route);

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () {
            Fluttertoast.showToast(
              msg: '你这个人，真的满脑子都是自己呢',
            );
            Navigator.pushReplacementNamed(context, 'login');
          },
              icon: Icon(Icons.exit_to_app)
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('现在这里还什么都没有'),



            // ElevatedButton(onPressed: () {
            //   Navigator.pushNamed(context, 'input');
            // },
            //     child: Text('去添加食材')
            // ),
            //
            // ElevatedButton(onPressed: () {
            //   Navigator.pushNamed(context, 'display');
            // },
            //     child: Text('我有什么吃的')
            // ),
          ],
        ),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

