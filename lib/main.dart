import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=0b93a156";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.black45,
        primaryColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colors.black45)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.black45)),
          hintStyle: TextStyle(color: Colors.black45),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final pesoController = TextEditingController();

  double _dolar;
  double _euro;
  double _peso;

  void _resetFields() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    pesoController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _resetFields();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / _dolar).toStringAsFixed(2);
    euroController.text = (real / _euro).toStringAsFixed(2);
    pesoController.text = (real / _peso).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _resetFields();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * _dolar).toStringAsFixed(2);
    euroController.text = ((dolar * _dolar) / _euro).toStringAsFixed(2);
    pesoController.text = ((dolar * _dolar) / _peso).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _resetFields();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * _euro).toStringAsFixed(2);
    dolarController.text = ((euro * _euro) / _dolar).toStringAsFixed(2);
    pesoController.text = ((euro * _euro) / _peso).toStringAsFixed(2);
  }

  void _pesoChanged(String text) {
    if (text.isEmpty) {
      _resetFields();
      return;
    }
    double peso = double.parse(text);
    double real = peso * _peso;
    double dolar = real / _dolar;
    double euro = real / _euro;
    realController.text =
        (real < 0.1) ? real.toStringAsFixed(3) : real.toStringAsFixed(2);
    dolarController.text =
        (dolar < 0.1) ? dolar.toStringAsFixed(3) : dolar.toStringAsFixed(2);
    euroController.text =
        (euro < 0.1) ? euro.toStringAsFixed(3) : euro.toStringAsFixed(3);
  }

  void _setData(data) async {
    _dolar = data["results"]["currencies"]["USD"]["buy"];
    _euro = data["results"]["currencies"]["EUR"]["buy"];
    _peso = data["results"]["currencies"]["ARS"]["buy"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Conversor Monetário"),
          backgroundColor: Colors.amber,
          actions: [
            IconButton(icon: Icon(Icons.refresh), onPressed: _resetFields)
          ],
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text("Carregando Dados...",
                        style: TextStyle(fontSize: 20)),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Falha ao Carregar Dados... :(",
                          style: TextStyle(fontSize: 20)),
                    );
                  } else {
                    _setData(snapshot.data);
                    return SingleChildScrollView(
                        padding: EdgeInsets.all(15.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Text("Cotação",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Divider(),
                              Table(
                                children: [
                                  TableRow(children: [
                                    builderContainerCotacao(
                                        "Dolar", "US\$ ", _dolar),
                                    builderContainerCotacao(
                                        "Euro", "€ ", _euro),
                                    builderContainerCotacao(
                                        "Peso", "\$ ", _peso),
                                  ])
                                ],
                              ),
                              SizedBox(height: 20),
                              Column(children: [
                                builderTextField("Real", "R\$ ", realController,
                                    _realChanged),
                                SizedBox(height: 25),
                                builderTextField("Dolar", "US\$ ",
                                    dolarController, _dolarChanged),
                                SizedBox(height: 25),
                                builderTextField(
                                    "Euro", "€ ", euroController, _euroChanged),
                                SizedBox(height: 25),
                                builderTextField("Peso", "\$  ", pesoController,
                                    _pesoChanged)
                              ])
                            ]));
                  }
              }
            }));
  }
}

Widget builderTextCotacao(String label, [double valor, int fixed]) {
  if (valor == null) {
    return Text(
      "$label",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.left,
    );
  } else {
    return Text(
      "$label" + valor.toStringAsFixed(fixed),
      style: TextStyle(fontSize: 20),
      textAlign: TextAlign.left,
    );
  }
}

Widget builderContainerCotacao(String label, String prefix, [double valor]) {
  var fixed = label == "Peso" ? 3 : 2;
  return Container(
      child: Card(
          child: Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [builderTextCotacao(label)],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [builderTextCotacao(prefix, valor, fixed)],
      ),
    ],
  )));
}

Widget builderTextField(String label, String prefix,
    TextEditingController controller, Function func) {
  return TextField(
    controller: controller,
    style: TextStyle(fontSize: 20),
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        prefixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        prefixText: prefix),
    onChanged: func,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
