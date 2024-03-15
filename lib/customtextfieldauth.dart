import 'package:flutter/material.dart';
class CustomTextFieldAuth extends StatelessWidget {
  final String hinttext;
  final String label;
  final bool isNumber;
  final bool? isPassword;
  final void Function()? ontapicon;
  final IconData icondata;
  final String? Function(String?) valid;
  final TextEditingController mycontroller;
   CustomTextFieldAuth({Key? key, required this.hinttext,this.ontapicon, required this.label, required this.icondata,required this.mycontroller, required this.valid, required this.isNumber, this.isPassword}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Container(
        height: 70,
        child: TextFormField(
          cursorColor:Colors.orangeAccent,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          controller: mycontroller,
          obscureText: isPassword == Null ||isPassword==false ? false : true,
          keyboardType: isNumber?TextInputType.phone:TextInputType.text,
          validator: valid,
          decoration: InputDecoration(
            focusedBorder:OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orangeAccent),
                borderRadius: BorderRadius.circular(30)
            ),
            iconColor: Colors.orangeAccent,
              isDense: true,
              fillColor:Colors.grey,
              filled: true,
              hintText: hinttext,
              hintStyle: TextStyle(color: Color.fromRGBO(75, 72, 72, 1),fontSize: 14,),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
              label: Container(
                padding: EdgeInsets.only(left: 20),
                margin: EdgeInsets.symmetric(horizontal: 3),
                child: Text(label,style: TextStyle(fontSize: 19,color: Colors.orangeAccent,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),),
              suffixIcon: InkWell(

                  child: Icon(icondata,color: Colors.orangeAccent,),
                onTap:ontapicon,
              ),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent),
                borderRadius: BorderRadius.circular(30)
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color:Colors.orangeAccent),
                  borderRadius: BorderRadius.circular(30)
              ),
          ),
        ),
      ),
    );
  }
}
