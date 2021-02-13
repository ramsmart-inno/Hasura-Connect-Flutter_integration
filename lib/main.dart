import 'package:flutter/material.dart';

import 'package:hasura_connect/hasura_connect.dart';
//import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:trailz/terms.dart';

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyAppp(),
    );
  }
}

class MyAppp extends StatefulWidget {
  @override
  _MyApppState createState() => _MyApppState();
}

class _MyApppState extends State<MyAppp> {
  TextEditingController myController = TextEditingController();

  final repository = HomeRepositoryImpl();

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 5));

    setState(() {
      repository.getTarefas();
      repository.streamTarefas();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo'),
        actions: [
          InkWell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.search),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Terms()));
            },
          ),
        ],
      ),
      body: LiquidPullToRefresh(
          animSpeedFactor: 4.0,
          color: Colors.deepOrange,
          backgroundColor: Colors.white,
          showChildOpacityTransition: false,
          child:
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: <Widget>[
              // new TextField(
              //   maxLines: 2,
              //   textAlign: TextAlign.center,
              //   textAlignVertical: TextAlignVertical.center,
              //   controller: myController,
              //   decoration: InputDecoration(
              //     border: InputBorder.none,
              //     hintText: 'Write your thoughts here',
              //   ),
              //   //showCursor: false,
              //   enableInteractiveSelection: true,
              // ),
              // RaisedButton(
              //   onPressed: () {
              //     repository.add(myController.text.toString());
              //   },
              //   child: Text("Submit"),
              // ),

              Container(
            child: FutureBuilder<List<Map>>(
                future: repository.getTarefas(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error Fetching Data");
                  } else if (snapshot.hasData) {
                    final list = snapshot.data;
                    return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) => ListTile(
                              title: Text(list[index]['name']),
                            ));
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
          // Container(
          //   width: 400,
          //   height: 200,
          //   child: StreamBuilder<List<Map>>(
          //       stream: repository.streamTarefas(),
          //       builder: (context, snapshot) {
          //         if (snapshot.hasError) {
          //           return Text("Error Fetching Data");
          //         } else if (snapshot.hasData) {
          //           final list = snapshot.data;
          //           return ListView.builder(
          //               itemCount: list.length,
          //               itemBuilder: (context, index) => ListTile(
          //                     title: Text(list[index]['name']),
          //                   ));
          //         } else {
          //           return Center(
          //             child: CircularProgressIndicator(),
          //           );
          //         }
          //       }),
          // )
          //   ],
          // ),
          onRefresh: refreshList),
    );
  }
}

class HomeRepositoryImpl implements HomeRepository {
  static String url = 'https://devmac.herokuapp.com/v1/graphql';
  final _client = HasuraConnect(url);

  @override
  Future<List<Map>> getTarefas() async {
    final response = await _client.query('''
    query {
        dummy {
          id
          name
        
        }
    }
    ''');
    return (response['data']['dummy'] as List)
        .map((e) => {"name": e['name']})
        .toList();
    //{"name": e.data['name']}
  }

  @override
  Stream<List<Map>> streamTarefas() {
    return _client.subscription('''
      subscription{
  dummy{
    id
    name
  }
}
''').map((e) => (e['data']['dummy']
            as List)
        .map((e) => {"name": e['name']})
        .toList());
  }

  Future<bool> add(textee) async {
    String mutation = r""" 
                  mutation MyMutation ($name : String!){
  insert_dummy(objects: {name: $name}) {
    affected_rows
  }
}""";
    print("do");
    var snapshot =
        await _client.mutation(mutation, variables: {"name": textee});
    print("dooo");
    return snapshot['data']['insert_dummy']['affected_rows'] > 0;
  }
}

abstract class HomeRepository {
  Future getTarefas();
  Stream streamTarefas();
}
