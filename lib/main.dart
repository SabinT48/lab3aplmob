import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wine App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WineHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WineHomePage extends StatefulWidget {
  @override
  _WineHomePageState createState() => _WineHomePageState();
}

class _WineHomePageState extends State<WineHomePage> {
  List<dynamic> winesBy = [];
  List<dynamic> carouselItems = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      final String response = await rootBundle.loadString('assets/json/v3.json');
      final data = json.decode(response);
      setState(() {
        winesBy = data['wines_by'];
        carouselItems = data['carousel'];
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to load data: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Vinodiversity Drive', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {},
              ),
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text('1', style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Shop wines by',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: winesBy.map((category) {
                return _buildChip(category['name']);
              }).toList(),
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: carouselItems.map((wine) {
                return _buildWineTypeCard(wine);
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Wine',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...carouselItems.map((wine) {
            return _buildWineItem(wine);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Widget _buildWineTypeCard(Map<String, dynamic> wine) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: NetworkImage(wine['image']),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${wine['critic_score']}', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wine_bar, size: 50, color: wine['type'] == 'red' ? Colors.red : Colors.yellow[700]),
                SizedBox(height: 8),
                Text(wine['name'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWineItem(Map<String, dynamic> wine) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        height: 50,
        child: Image.network(wine['image'], fit: BoxFit.cover),
      ),
      title: Text(wine['name']),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${wine['type']} • ${wine['from']['country']} • ${wine['from']['city']}'),
          Text('\$ ${wine['price_usd']}', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      trailing: Icon(Icons.favorite_border),
    );
  }
}
