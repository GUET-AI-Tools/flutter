import 'package:ai_tool/global/static.dart';
import 'package:flutter/material.dart';

class InputRoute extends StatefulWidget {
  const InputRoute({super.key});


  @override
  State<StatefulWidget> createState() => _InputRouteState();
}


// TODO 这个页面现在约等于废弃，可用作添加其他功能
class _InputRouteState extends State<InputRoute> with AutomaticKeepAliveClientMixin {

  // String text = ''; // 你的输入文字
  // String reply = ''; // ai回复
  //
  // String base64Image = ''; // base64图片
  // File? _image; // 图片

  String username = Global.username;



  // List recordAllFoodList = []; // 处理完后的所有所有食物以及它们的数量


  // Future<void> startDatabase(String username) async {
  //   var db = await openDatabase('${username}_database');
  // }


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('食材我来辣'),
      // ),

      body: Scrollbar(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 20,
                  ),


                ],
              ),
            ),
          )
      )
    );
  }

  @override
  bool get wantKeepAlive => true;


}