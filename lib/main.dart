import 'package:flutter/material.dart';

import 'package:hasura_connect/hasura_connect.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new TextField(
              maxLines: 5,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              controller: myController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Write your thoughts here',
              ),
              //showCursor: false,
              enableInteractiveSelection: true,
            ),
            RaisedButton(
              onPressed: () {
                repository.add(myController.text.toString());
              },
              child: Text("Submit"),
            ),
            SingleChildScrollView(
              child: Container(
                width: 400,
                height: 200,
                child: FutureBuilder<List<Map>>(
                    future: repository.getTarefas(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("Erro aconteceu");
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
            ),
            Container(
              width: 400,
              height: 200,
              child: StreamBuilder<List<Map>>(
                  stream: repository.streamTarefas(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text("Erro aconteceu");
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
            )
          ],
        ),
      ),
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
