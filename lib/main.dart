import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(CryptoTrackerApp());
}

class CryptoTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: CryptoHomePage(),
    );
  }
}

class CryptoHomePage extends StatefulWidget {
  @override
  _CryptoHomePageState createState() => _CryptoHomePageState();
}

class _CryptoHomePageState extends State<CryptoHomePage> {
  List<dynamic> cryptoData = [];
  List<FlSpot> priceTrend = [];

  @override
  void initState() {
    super.initState();
    fetchCryptoData();
  }

  Future<void> fetchCryptoData() async {
    final response = await http.get(Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=true'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        cryptoData = data;
        priceTrend = getChartData(data[0]['sparkline_in_7d']['price']);
      });
    } else {
      throw Exception('Failed to load crypto data');
    }
  }

  List<FlSpot> getChartData(List<dynamic> prices) {
    List<FlSpot> spots = [];
    for (int i = 0; i < prices.length; i++) {
      spots.add(FlSpot(i.toDouble(), prices[i].toDouble()));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crypto Price Tracker")),
      body: cryptoData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  height: 300,
                  padding: EdgeInsets.all(16),
                  child: LineChart(LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: priceTrend, // Data points for the line chart
                        isCurved: true, // Makes the line chart curved
                        gradient: LinearGradient(colors: [
                          Colors.blueAccent,
                          Colors.blue
                        ]), // Color of the line
                        dotData: FlDotData(
                            show: false), // Hides the dots on the line
                        belowBarData: BarAreaData(
                            show: false), // Hides the area below the line
                      ),
                    ],
                  )),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cryptoData.length,
                    itemBuilder: (context, index) {
                      var crypto = cryptoData[index];
                      return ListTile(
                        leading: Image.network(crypto['image'], width: 40),
                        title: Text(crypto['name']),
                        subtitle: Text("\$${crypto['current_price']}"),
                        trailing: Text(
                          crypto['price_change_percentage_24h']
                                  .toStringAsFixed(2) +
                              "%",
                          style: TextStyle(
                            color: crypto['price_change_percentage_24h'] > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
