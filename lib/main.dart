import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'interface/proxylist.dart';
import 'dart:async';
import 'dart:convert';



void main() {
  runApp(const ProxyApp());
}


class ProxyApp extends StatefulWidget {
  const ProxyApp({super.key});

  @override
  State<ProxyApp> createState() => _ProxyAppState(); 
}

class _ProxyAppState extends State<ProxyApp> {
  
  Future fetchProxylist() async {
    final response = await http
        .get(Uri.parse('http://192.168.144.30:8000/proxylist/serverlist.json'));

    if (response.statusCode == 200) {
      List<dynamic> list = jsonDecode(response.body);
      setState(() {
        proxysvlist = (list).map((e) => ProxyItem.fromJson(e)).toList();
      });
    } else {
      throw Exception('Failed to load Proxylist');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProxylist();
  }

  List<ProxyItem> proxysvlist = [];
  bool _inActive = true;

  void _manageStateForChildWidget(bool newValue) {
    setState(() {
      _inActive = newValue;
      
    });
  }

  void recvDeleteItem(int index){
    setState(() {
      proxysvlist.removeAt(index);
    });
  }

 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ListTileExample(
        inActive: _inActive,
        proxylist:  proxysvlist,
        notifyParent: _manageStateForChildWidget,
        notifyDeleteItme: recvDeleteItem,
        ),
    );
  }

}

class ListTileExample extends StatelessWidget  {

  const ListTileExample({Key? key, this.inActive = true, this.index=-1, this.proxylist = const [] , required this.notifyParent, required this.notifyDeleteItme})
      : super(key: key);
      
  final bool inActive;
  final int index;
  
  final ValueChanged<int> notifyDeleteItme;
  final ValueChanged<bool> notifyParent;
  void manageState() {  
    notifyParent(!inActive);
    notifyDeleteItme(index);
  }

  final List<ProxyItem> proxylist;

  void _pressMyAction() {
      notifyParent(!inActive);
      
  }

  void DeleteItem(int index){
    notifyDeleteItme(index);
  }

  void EditItem(int index){
    print("on Edit Item");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proxy Server List'), backgroundColor: Colors.pinkAccent,),
      // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Card(
            color:Colors.deepOrangeAccent,
            child: ListView.builder(
              // shrinkWrap: true,
              itemCount: proxylist.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(proxylist[index].flag)
                  ),
                  // title: Text(proxylist[index].country),
                  // subtitle: Text(proxylist[index].ip),
                  subtitle: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 130,
                        child: Text(
                            proxylist[index].ip, 
                            style: const TextStyle(
                              color: Colors.white,                          
                            ),
                        ),
                      ),

                      SizedBox(
                        width: 130,
                        child: Row(
                          children: <Widget>
                          [
                            TextButton(                 
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                                backgroundColor: const Color.fromARGB(255, 6, 130, 247),      
                                side: const BorderSide(color: Color.fromARGB(255, 104, 193, 253), width: 2),  
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                ) 
                              ),                      
                              child: const Text('Edit'),
                              onPressed: () { print("On Edit"); },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                                backgroundColor: const Color.fromARGB(255, 6, 130, 247),    
                                side: const BorderSide(color: Color.fromARGB(255, 104, 193, 253), width: 2),  
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                ) 
                              ), 
                              child: const Text('Delete'), 
                              onPressed: () { DeleteItem(index); },
                            ),
                          ],
                        ),
                      ),
                      
                    ],
                  ),
                  trailing: SizedBox(
                              width: 23,
                              child: Text(
                                  proxylist[index].price,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 247, 200, 32),                          
                                  ),
                              )
                            ),

                  // shape: const Border(bottom: BorderSide(), ),
                  tileColor: Colors.blueAccent,
                  onTap: (){
                    print("On Tap is fired");
                  },
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.cyanAccent, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  
                );
              },
            ),
          ),
     

      ),
            
      floatingActionButton: const FractionallySizedBox(
        widthFactor: 0.5,
        heightFactor: 0.1,                
        alignment: FractionalOffset.bottomCenter,
        child: Row(          
          children: <Widget>[
            SizedBox(
              width: 100,
              child: Text(
                            "",
                            style: TextStyle(
                              color: Color.fromARGB(255, 247, 200, 32),                          
                            ),
                        )                 
            ),
          ],
          
        ),

      ),

      bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.thumb_up),
              label: "Like",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.thumb_down),
              label: "Dislike",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.comment),
              label: "Add",
              
            )
          ],
        ),
      
    );
  }
}