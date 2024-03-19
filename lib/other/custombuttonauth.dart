import 'package:flutter/material.dart';

class CustomButtonAuth extends StatelessWidget {
  final String text;
  final Function()? onpressed;
  final double widthh;
  const CustomButtonAuth(
      {Key? key, required this.text, this.onpressed, required this.widthh})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthh * 0.8,
      margin: EdgeInsets.only(top: 25),
      child: MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
          color: const Color.fromARGB(255, 83, 179, 168),
          child: Text(
            text,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins'),
          ),
          onPressed: onpressed),
    );
  }
}
