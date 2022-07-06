import 'package:flutter/material.dart';
import 'package:memri/cvu/constants/cvu_font.dart';

class SimpleTextEditor extends StatelessWidget {
  const SimpleTextEditor({
    Key? key,
    required this.controller,
    required this.title,
    this.hintText = '',
  }) : super(key: key);

  final TextEditingController controller;
  final String title;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 632,
      height: 51,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      color: Color(0xffF0F0F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: CVUFont.smallCaps.copyWith(color: Color(0xff828282))),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            decoration: InputDecoration.collapsed(
              border: InputBorder.none,
              hintText: hintText,
            ),
            style: TextStyle(color: Color(0xffFE570F), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
