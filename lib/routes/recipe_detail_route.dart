import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class RecipeDetailRoute extends StatelessWidget {
  RecipeDetailRoute({
    Key? key,
    required this.recipeName,
    required this.recipeDescription,
  }) : super(key: key);

  final String recipeName;
  final String recipeDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MarkdownBlock(data: '$recipeName\n$recipeDescription'),
            ],
          ),
        ),
      ),
    );
  }
}