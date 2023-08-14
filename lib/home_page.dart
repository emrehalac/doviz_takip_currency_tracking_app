import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'currency.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Dio? dio;
  late List<String> currencies;
  String? selectedCurrency;
  bool isLoading = false;
  bool isCurrencyLoading = false;
  Currency? currentCurrency;
  @override
  void initState() {
    super.initState();
    BaseOptions options = BaseOptions();
    options.baseUrl = 'https://api.frankfurter.app/';
    dio = new Dio(options);
    currencies = [];
    getCurrencies();
  }

  Future<void> getCurrency(String code) async {
    setState(() {
      isCurrencyLoading = true;
    });
    final response = await dio!.get("latest?from=$code");
    if (response.statusCode == 200) {
      currentCurrency = Currency.fromJson(response.data);
    }
    setState(() {
      isCurrencyLoading = false;
    });
  }

  Future<List> getCurrencies() async {
    setState(() {
      isLoading = true;
    });
    final response = await dio!.get("currencies");
    if (response.statusCode == 200) {
      (response.data as Map).forEach((key, value) {
        currencies.add(key);
      });
    }
    setState(() {
      isLoading = false;
    });
    selectedCurrency = currencies[0];
    return currencies;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

          appBar: AppBar(title: Text('Canlı Döviz Takibi'),
              backgroundColor: Colors.black, centerTitle: true, ),
          body: Container(
            color: Colors.grey,
            alignment: Alignment.topCenter,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Text('Para Birimini Seçiniz : '),
                  isLoading
                      ? CircularProgressIndicator()
                      : DropdownButton<String>(
                      value: selectedCurrency,
                      onChanged: (value) async {
                        setState(() {
                          selectedCurrency = value!;
                        });
                        await getCurrency(value!);
                      },
                      items: currencies
                          .map((value) => DropdownMenuItem<String>(
                          value: value, child: Text(value)))
                          .toList()),
                  SizedBox(height: 40),
                  _buildItems,
                ],
              ),
            ),
          )),
    );
  }

  Widget get _buildItems => currentCurrency != null
      ? isCurrencyLoading
      ? CircularProgressIndicator()
      : Column(

    children: [

      Text(' Para Birimi : ${currentCurrency!.base} ',
        style: TextStyle(color: Colors.black,
            fontWeight: FontWeight.bold ) ,),

      ListView.separated(

        separatorBuilder: (_, ind) => Divider(color: Colors.black54),
        padding: EdgeInsets.all(10),
        controller: ScrollController(),
        shrinkWrap: true,
        itemCount: currentCurrency!.rates.entries.length,
        itemBuilder: (_, index) => ListTile(
          tileColor: Colors.red,
          trailing: Text(currentCurrency!.rates.entries
              .toList()[index]
              .value
              .toString(),
            style: TextStyle( fontWeight: FontWeight.bold) ,),
          leading:
          Text(currentCurrency!.rates.entries.toList()[index].key,
            style: TextStyle(color: Colors.red.shade700) ,),

        ),
      )
    ],
  )
      : Container();
}
