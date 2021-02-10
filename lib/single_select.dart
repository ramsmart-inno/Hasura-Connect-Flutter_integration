import 'package:flutter/material.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:trailz/terms.dart';

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

  int selectedIndex = 0;

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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                width: 400,
                height: 800,
                child: FutureBuilder<List<Map>>(
                    future: repository.getTarefas(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("Erro aconteceu");
                      } else if (snapshot.hasData) {
                        final list = snapshot.data;
                        return GridView.builder(
                            itemCount: list.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemBuilder: (context, index) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = list[index]['id'];
                                      print(selectedIndex);
                                    });
                                  },
                                  child: Container(
                                    width: 150,
                                    child: Card(
                                      shape:
                                          (selectedIndex == list[index]['id'])
                                              ? RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: Colors.green))
                                              : null,
                                      elevation: 5,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Text(list[index]['name'])
                                        ],
                                      ),
                                    ),
                                  ),
                                ));

                        //   itemCount: list.length,
                        // itemBuilder: (context, index) => ListTile(
                        // title: Text(list[index]['name']),
                        // ));
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              ),
            ),
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
        .map((e) => {"name": e['name'], "id": e['id']})
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

class Item {
  String name;
  int id;

  Item(this.name, this.id);
}
