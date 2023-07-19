import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Histogram App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<double> speeds = [10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0];
  List<charts.Series<dynamic, String>> seriesList = [];

  @override
  void initState() {
    super.initState();
    processData(); // Process the CSV data here
  }

  Future<void> processData() async {
    // Load CSV data from file
    String csvData = await rootBundle.loadString('assets/data.csv');

    // Parse CSV data
    List<List<dynamic>> rows = const CsvToListConverter(
      shouldParseNumbers: false,
    ).convert(csvData);

    List<double> fiveMinutesSpeeds = [];
    List<double> tenMinutesSpeeds = [];

    for (int i = 0; i < rows.length; i++) {
      double? speed = double.tryParse(rows[i][1]);

      if (speed != null) {
        if (i < 5) {
          fiveMinutesSpeeds.add(speed);
        }

        if (i < 10) {
          tenMinutesSpeeds.add(speed);
        }
      }
    }

    // Calculate average speeds
    double fiveMinutesAverage = calculateAverageSpeed(fiveMinutesSpeeds);
    double tenMinutesAverage = calculateAverageSpeed(tenMinutesSpeeds);

    // Update the 'speeds' list
    speeds = [fiveMinutesAverage, tenMinutesAverage];
  }

  double calculateAverageSpeed(List<double> speeds) {
    if (speeds.isEmpty) {
      return 0.0;
    }

    double sum = speeds.reduce((value, element) => value + element);
    return sum / speeds.length;
  }

  void generatePDFReport() {
    final pdf.Document pdfDoc = pdf.Document();

    pdfDoc.addPage(
      pdf.Page(
        build: (pdf.Context context) {
          return pdfWidgets.Center(
            child: pdfWidgets.Text('PDF'),
          );
        },
      ),
    );

    pdfDoc.save().then((value) {
      print('ПДФ успешно создан');
    });
  }

  @override
  Widget build(BuildContext context) {
    seriesList = [
      charts.Series<double, String>(
        id: '5 минут',
        domainFn: (double speed, _) => '5 Минут',
        measureFn: (double speed, _) => speed,
        data: speeds,
      ),
      charts.Series<double, String>(
        id: '10 Минут',
        domainFn: (double speed, _) => '10 Минут',
        measureFn: (double speed, _) => speed,
        data: speeds,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Тестовое задание'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Тестовое',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 400.0,
              child: charts.BarChart(
                seriesList,
                animate: true,
              ),
            ),
            SizedBox(height: 20.0),
            TextButton(
              onPressed: generatePDFReport,
              child: Text('Создать PDF '),
            ),
          ],
        ),
      ),
    );
  }
}
