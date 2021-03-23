import 'package:flutter/material.dart';

class Stat extends StatelessWidget {
  final String name, val;

  Stat(this.name, this.val);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$name:',
          style: TextStyle(
            color: Color(0xFFAAAAAA),
            fontSize: 20.0,
            fontFamily: 'Minecraft',
          ),
        ),
        Expanded(child: SizedBox(), flex: 1),
        Text(
          val,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontFamily: 'Minecraft',
          ),
        ),
      ],
    );
  }
}
