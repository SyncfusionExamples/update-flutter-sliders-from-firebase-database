import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SlidersWithFireBaseDemo());
}

class SlidersWithFireBaseDemo extends StatelessWidget {
  const SlidersWithFireBaseDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SlidersDemo(title: 'Sliders with FireBase demo'),
    );
  }
}

class SlidersDemo extends StatefulWidget {
  const SlidersDemo({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SlidersDemo> createState() => _SlidersDemoState();
}

class _SlidersDemoState extends State<SlidersDemo> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  final double _min = 5;
  final double _max = 45;

  @override
  void initState() {
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

// Get the BMI data's from database.
  Future<List<BMIData>> getBMIData() async {
    Future<DataSnapshot> _dbReference =
        FirebaseDatabase.instance.reference().once();
    List<BMIData> _bmiData = <BMIData>[];

    await _dbReference.then(
      (dataSnapShot) async {
        // Access the values from database.
        Map<dynamic, dynamic> jsonData = dataSnapShot.value;

        // Add the data into a local collection and return it.
        jsonData.forEach(
          (key, value) {
            BMIData data = BMIData.fromJson(key, value);
            _bmiData.add(BMIData(
                name: key,
                height: double.parse(data.height.toString()),
                weight: double.parse(data.weight.toString()),
                bmi: double.parse(data.bmi.toString()),
                category: data.category.toString()));
          },
        );
      },
    );
    return _bmiData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder(
            future: getBMIData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<BMIData> data = snapshot.data as List<BMIData>;
                _heightController.text = data[0].height.toString();
                _weightController.text = data[0].weight.toString();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'BMI Calculator',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _heightController,
                      decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Height',
                          suffix: const Text('cm'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _weightController,
                      decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Weight',
                          suffix: const Text('kg'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Your BMI score : ${data[0].bmi}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SfSlider(
                      min: _min,
                      max: _max,
                      interval: 10,
                      value: data[0].bmi,
                      showLabels: true,
                      showTicks: true,
                      onChanged: null,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        data[0].category + " !!!",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ],
                );
              }

              return const Text('Loading...');
            },
          ),
        ),
      ),
    );
  }
}

// Class which parse the data from database
class BMIData {
  String name;
  late double height;
  late double weight;
  late double bmi;
  late String category;

  BMIData(
      {required this.name,
      required this.height,
      required this.weight,
      required this.bmi,
      required this.category});

  BMIData.fromJson(this.name, Map data) {
    height = data['height'];
    weight = data['weight'];
    bmi = data['bmi'];
    category = data['category'];
  }
}
