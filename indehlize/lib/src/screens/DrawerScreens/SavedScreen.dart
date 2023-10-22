import 'package:flutter/material.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Icon(Icons.arrow_back_ios),
                    onTap: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                  ),
                  Text(
                    'Saved',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        decoration: TextDecoration.none
                    ),
                  ),
                  SizedBox(

                  ),
                ],
              ),
            ),

          ],
        )
    );
  }
}
