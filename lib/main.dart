//Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  //WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();                                             //Process never completes, fails to load app
  print("init");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainWidget(),
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  //FirebaseFirestore db = FirebaseFirestore.instance;
  //Initialising variables
  var sliderValue = 200.0;
  List _loadedData = [];
  var friendState = [];
  List localdata = [];
  final List<Color> stateColors = [
    Colors.white,
    Colors.amber
  ]; //Colors for friend selection

  Future<void> _fetchData() async {
    //fetch from API
    const apiUrl = 'https://jsonplaceholder.typicode.com/users';

    final response = await http.get(Uri.parse(apiUrl));
    final data = json.decode(response.body);

    setState(() {
      _loadedData = data;
    });

    localdata = _loadedData;

    // for (int i = 0; i < _loadedData.length; i++) {                           //Possible approach for adding friends
    //   localdata[i]["friend"] = 0;
    // }
    //print(localdata);                                                         //Debug
  }

  @override
  Widget build(BuildContext context) {
    //_fetchData();                                                             //Debug

    if (_loadedData.isEmpty) {
      //Data from API is fetched only once since it is static
      _fetchData();
    }
    if (friendState.isEmpty) {
      //Alternate approach for adding friends
      for (int i = 0; i < _loadedData.length; i++) {
        friendState += [0];
      }
    }

    // db                                                                       //Firestore trial
    //     .collection("user")
    //     .add(_loadedData[0])
    //     .then((DocumentReference doc) => {});

    setState(() {
      localdata = _loadedData.toList();
      //print("-");                                                             //Debug
      //var len = localdata.length;
      localdata.removeWhere((element) => //Filter list based on slider value
          (double.parse(element["address"]["geo"]["lng"]) >
              sliderValue)); //Show only those values less than slider value
      // localdata.removeWhere((element) =>
      //     (double.parse(element["address"]["geo"]["lng"]) - sliderValue) > 50 ||     //Show values around slider value
      //     (double.parse(element["address"]["geo"]["lng"]) - sliderValue) < -50);

      // for (var element in localdata) {                                       //Unsuccessful approach for filter
      //   if (double.parse(element["address"]["geo"]["lng"]) > sliderValue) {
      //     localdata.remove(element);
      //     break;
      //   }
      //print(double.parse(localdata[i]["address"]["geo"]["lng"]));
      // }
    });
    //print(sliderValue);                                                       //Debug
    //print(localdata);

    //print(_loadedData);

    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(fit: StackFit.expand, children: [
          //Stack containing bg image + remaining stuff
          Padding(
            padding: const EdgeInsets.only(bottom: 500),
            child: Image.asset(
              'assets/images/bg_old.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            //Column containing main widgets
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 28, top: 69, bottom: 100),
                child: Text(
                  //Text
                  'Users',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Slider(
                  //Slider
                  value: sliderValue,
                  min: -200,
                  max: 200,
                  onChanged: (newValue) {
                    setState(() {
                      //Allows slider to move and refresh instantly
                      sliderValue = newValue;
                    });
                  }),
              Expanded(
                child: ListView.separated(
                  //List starts
                  itemCount: localdata.length,
                  //physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 46),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          setState(() {
                            friendState[localdata[index]["id"] -
                                    1] = //Adding friend
                                1 - friendState[localdata[index]["id"] - 1];
                            //Change value in firebase
                          });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: const LinearGradient(
                                    //Gradient
                                    colors: [
                                      Color.fromARGB(255, 75, 59, 0),
                                      Color.fromARGB(255, 30, 23, 0)
                                    ],
                                    begin: Alignment.bottomRight,
                                    end: Alignment.center)),
                            child: ListTile(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              contentPadding: const EdgeInsets.all(20),
                              visualDensity: VisualDensity.compact,
                              textColor: Colors.white,
                              title: Text(
                                localdata[index]
                                    ["name"], //User's name from data
                                style: TextStyle(
                                    color: stateColors[friendState[localdata[
                                            index]["id"] -
                                        1]], //Text colour depending on friend status
                                    fontWeight: FontWeight.w500,
                                    fontSize: 22),
                              ),
                              subtitle: Column(
                                //Column containing other user details
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 7),
                                  Text(
                                    localdata[index]["email"],
                                    style: const TextStyle(color: Colors.amber),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(localdata[index]["address"]["street"] +
                                      " - " +
                                      localdata[index]["address"]["suite"]),
                                  Text(localdata[index]["address"]["city"] +
                                      " - " +
                                      localdata[index]["address"]["zipcode"]),
                                  const SizedBox(height: 7),
                                  Row(
                                    children: [
                                      Image.asset("assets/images/lng.png"),
                                      Expanded(
                                        //Shifts latitude to the right
                                        flex: 2,
                                        child: Text("   " +
                                            localdata[index]["address"]["geo"]
                                                ["lng"]),
                                      ),
                                      Image.asset("assets/images/lat.png"),
                                      Text("   " +
                                          localdata[index]["address"]["geo"]
                                              ["lat"]),
                                    ],
                                  )
                                ],
                              ),
                            )));
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    //Separation between users
                    return const SizedBox(height: 17);
                  },
                ),
              )
            ],
          ),
        ]));
  }
}
