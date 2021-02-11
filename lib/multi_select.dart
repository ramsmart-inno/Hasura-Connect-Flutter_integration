import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import "package:dio/dio.dart" as dio;
import 'package:gql/language.dart' as gqlLang;
import 'package:gql_dio_link/gql_dio_link.dart';
import 'package:gql_exec/gql_exec.dart';
import "package:gql_link/gql_link.dart";
import 'package:async/async.dart';

const query = """{
 dummy {
    id
    name
  }
}""";

const graphqlEndpoint = "https://devmac.herokuapp.com/v1/graphql";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stuart(),
    );
  }
}

class Stuart extends StatefulWidget {
  @override
  _StuartState createState() => _StuartState();
}

class _StuartState extends State<Stuart> {
  // single choice value
  int tag = 1;

  // multiple choice value
  List<String> tags = [];

  String user;
  final usersMemoizer = AsyncMemoizer<List<C2Choice<String>>>();

  Future<List<C2Choice<String>>> getUsers() async {
    final client = dio.Dio();

    final Link link = DioLink(
      graphqlEndpoint,
      client: client,
    );

    final res = await link
        .request(Request(
          operation: Operation(document: gqlLang.parseString(query)),
        ))
        .first;

    return C2Choice.listFrom<String, dynamic>(
      source: res.data["dummy"],
      value: (index, item) => item['id'].toString(),
      label: (index, item) => item['name'],
      meta: (index, item) => item,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
              child: ListView(
            children: <Widget>[
              Container(
                child: FutureBuilder<List<C2Choice<String>>>(
                  initialData: [],
                  future: usersMemoizer.runOnce(getUsers),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              )),
                        ),
                      );
                    } else {
                      if (!snapshot.hasError) {
                        return ChipsChoice<String>.multiple(
                          value: tags,
                          onChanged: (val) {
                            setState(() => tags = val);
                            print(tags);
                          },
                          wrapped: true,
                          textDirection: TextDirection.ltr,
                          choiceItems: snapshot.data,
                          choiceStyle: const C2ChoiceStyle(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
                            labelStyle: TextStyle(color: Colors.blueAccent),
                            color: Colors.white,
                            brightness: Brightness.dark,
                            margin: const EdgeInsets.all(5),
                            showCheckmark: true,
                            borderColor: Colors.blueGrey,
                          ),
                          choiceActiveStyle: const C2ChoiceStyle(
                            color: Colors.greenAccent,
                            brightness: Brightness.dark,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.all(25),
                          child: Text(
                            snapshot.error.toString(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
