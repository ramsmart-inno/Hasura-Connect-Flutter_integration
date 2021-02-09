import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Terms extends StatefulWidget {
  @override
  _TermsState createState() => _TermsState();
}

class _TermsState extends State<Terms> {
  // By defaut, the checkbox is unchecked and "agree" is "false"
  bool agree = false;

  // This function is triggered when the button is clicked
  void _doSomething() {
    // Do something
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms & Conditions'),
      ),
      body: Column(children: [
        Center(
          child: Container(
            width: 400,
            height: 400,
            child: WebView(
              initialUrl: 'http://enunui.com/privacy-policy.html',
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
        ),
        Center(
          child: Row(
            children: [
              Material(
                child: Checkbox(
                  value: agree,
                  onChanged: (value) {
                    setState(() {
                      agree = value;
                    });
                  },
                ),
              ),
              InkWell(
                child: Text(
                  'I have read and accept terms and conditions',
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
        ElevatedButton(
            onPressed: agree ? _doSomething : null,
            child: Text('SignUp with Google')),
        ElevatedButton(
            onPressed: agree ? _doSomething : null,
            child: Text('SignUp with Twitter')),
      ]),
    );
  }
}
