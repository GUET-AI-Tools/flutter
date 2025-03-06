import 'package:ai_tool/global/static.dart';
import 'package:sqflite/sqflite.dart';

class DbOperations {


  Future<void> deleteAll() async { // 清空数据
    var db = await openDatabase(
        '${Global.username}_database.db',
        version: 1,
        onCreate: ((Database db, int version) async {
          await db.execute('CREATE TABLE IF NOT EXISTS Food(id INTEGER PRIMARY KEY, name TEXT, value REAL, type TEXT)');
        }
        )
    );

    await db.execute('DROP TABLE IF EXISTS Food');

    await db.close();

    print('删完了');
    return;
  }
}