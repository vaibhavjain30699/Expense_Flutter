import 'package:expense2/ExpenseDatabase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoCondensedTextTheme(),
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final ExpenseDBManger _expenseDBManger = new ExpenseDBManger();
  List<ExpenseItem> _transactions = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _dropDownButtonValue = null;
  int totalAmount = 0;

  void getTotalAmount(){
    _expenseDBManger.getTotalExpense().then((value){
      //print(value[0]['Total']);
      setState(() {
        if(value[0]['Total']!=null)
          totalAmount = value[0]['Total'];
        else
          totalAmount = 0;
      });
    });
  }
  void getTransaction(){
    _expenseDBManger.getAllItems().then((list){
      setState(() {
        _transactions = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    //print(AppBar().preferredSize);
    double height = MediaQuery.of(context).size.height - 56.0;
    //height -= double.parse(AppBar().preferredSize.toString());
//    print(height);
    getTotalAmount();
    getTransaction();

    Widget listBody(){
      if(_transactions.length>0){
        return ListView.builder(
          itemCount: _transactions.length,
          itemBuilder: (BuildContext context,int index){
            Color background,textColor;
            Widget logo;
            if(_transactions[index].type=="Shopping"){
              logo = Icon(Icons.shopping_cart,color: Colors.purple,size: 35,);
              background = Colors.purple.shade100;
              textColor = Colors.purple.shade900;
            }
            else if(_transactions[index].type=="Food"){
              logo = Icon(Icons.fastfood,color: Colors.orange,size: 35,);
              background = Colors.orange.shade100;
              textColor = Colors.orange.shade900;
            }
            else if(_transactions[index].type=='Transportation'){
              logo = Icon(Icons.directions_transit,color: Colors.green,size: 35,);
              background = Colors.green.shade100;
              textColor = Colors.green.shade900;
            }
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: background,
              child: new ListTile(
                leading: logo,
                title: Column(
                  children: <Widget>[
                    Text(
                      _transactions[index].type,
                      style: TextStyle(
                        fontSize: 25,
                        color: textColor,
                      ),
                    ),
                    Text(_transactions[index].date,style: TextStyle(color: textColor),)
                  ],
                ),
                trailing: Column(
                  children: <Widget>[
                    Text(
                      _transactions[index].amount.toString(),
                      style: TextStyle(
                        fontSize: 25,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
      else{
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 125,
              ),
              Text(
                'No Transactions\nClick on + icon to add transactions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: new AppBar(
        title: Center(child: Text("Expense")),
        backgroundColor: Colors.grey.shade900,
      ),
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.cyan.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                height: height*0.2,
//                color: Colors.cyan.shade100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.cyan.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.attach_money,
                          size: 50,
                          color: Colors.cyan.shade700,
                        ),
                        Text(
                            (totalAmount==0)?'0':totalAmount.toString(),
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.cyan.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,11.6,0,0),
                child: Container(
                  height: height*0.75,
                  child: listBody(),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade500,
        child: Icon(Icons.add),
        onPressed: (){
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context){
              return StatefulBuilder(
                builder: (BuildContext context,StateSetter setState){
                  return Dialog(
                    elevation: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: "Amount"),
                                  controller: _amountController,
                                  validator: (val)=>val.isNotEmpty?null:"Empty",
                                ),
                                DropdownButtonFormField(
                                  decoration: InputDecoration(labelText: "Type"),
                                  validator: (val)=>val == null?"Empty":null,
                                  value: _dropDownButtonValue,
                                  onChanged: (value){
                                    setState(() {
                                      this._dropDownButtonValue = value;
                                      print(_dropDownButtonValue);
                                    });
                                  },
                                  onSaved: (value){
                                    setState(() {
                                      this._dropDownButtonValue = value;
                                      print(_dropDownButtonValue);
                                    });
                                  },
                                  items: <DropdownMenuItem>[
                                    DropdownMenuItem(
                                      value: "Shopping",
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(width: 5,),
                                          Icon(Icons.shopping_cart,color: Colors.purple,),
                                          SizedBox(width: 5,),
                                          Text("Shopping"),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: "Food",
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(width: 5,),
                                          Icon(Icons.fastfood,color: Colors.orange,),
                                          SizedBox(width: 5,),
                                          Text("Food"),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: "Transportation",
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(width: 5,),
                                          Icon(Icons.directions_transit,color: Colors.green,),
                                          SizedBox(width: 5,),
                                          Text("Transportation"),
                                        ],
                                      ),
                                    ),
                                  ].toList(),
                                ),
                                SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    FlatButton(
                                      child: Text("CANCEL"),
                                      onPressed: (){
                                        Navigator.pop(context);
                                      },
                                    ),
                                    RaisedButton(
                                      color: Colors.lightBlue,
                                      child: Text("ADD"),
                                      onPressed: (){
                                        _insertTransaction();
                                        getTotalAmount();
                                      },
                                    ),
                                    SizedBox(width: 5,)
                                  ],
                                ),
                                SizedBox(height: 10,)
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _insertTransaction(){
    if(_formKey.currentState.validate()){
      var _dateTime = new DateTime.now();
      ExpenseItem temp = new ExpenseItem(amount: int.parse(_amountController.text), type: _dropDownButtonValue, date: new DateFormat("dd-MM-yyyy").format(_dateTime), time: new DateFormat("H:m:s").format(_dateTime));
      _expenseDBManger.addTransactions(temp).then((id){
        print("Id = $id");
        _amountController.clear();
        _dropDownButtonValue = null;
        _expenseDBManger.getAllItems().then((list){
          setState(() {
            _transactions = list;
          });
        });
      });
      Navigator.of(context,rootNavigator: true).pop();
    }
  }
}


//
//FutureBuilder(
//future: _expenseDBManger.getAllItems(),
//builder: (context,snapshot){
//if(snapshot.hasData){
//print(snapshot.data);
////print('List length is $_transactions.length');
//_transactions = snapshot.data;
//return ListView.builder(
//itemCount: _transactions.length,
//itemBuilder: (BuildContext context,int index){
//Color background,textColor;
//Widget logo;
//if(_transactions[index].type=="Shopping"){
//logo = Icon(Icons.shopping_cart,color: Colors.purple,size: 35,);
//background = Colors.purple.shade100;
//textColor = Colors.purple.shade900;
//}
//else if(_transactions[index].type=="Food"){
//logo = Icon(Icons.fastfood,color: Colors.orange,size: 35,);
//background = Colors.orange.shade100;
//textColor = Colors.orange.shade900;
//}
//else if(_transactions[index].type=='Transportation'){
//logo = Icon(Icons.directions_transit,color: Colors.green,size: 35,);
//background = Colors.green.shade100;
//textColor = Colors.green.shade900;
//}
//return Card(
//shape: RoundedRectangleBorder(
//borderRadius: BorderRadius.circular(15.0),
//),
//color: background,
//child: new ListTile(
//leading: logo,
//title: Column(
//children: <Widget>[
//Text(
//_transactions[index].type,
//style: TextStyle(
//fontSize: 25,
//color: textColor,
//),
//),
//Text(_transactions[index].date,style: TextStyle(color: textColor),)
//],
//),
//trailing: Column(
//children: <Widget>[
//Text(
//_transactions[index].amount.toString(),
//style: TextStyle(
//fontSize: 25,
//color: textColor,
//fontWeight: FontWeight.bold,
//),
//),
//],
//),
//),
//);
//},
//);
//}else{
//return Center(
//child: Column(
//mainAxisSize: MainAxisSize.min,
//children: <Widget>[
//Icon(
//Icons.account_balance_wallet,
//color: Colors.white,
//size: 125,
//),
//Text(
//'No Transactions\nClick on + icon to add transactions.',
//textAlign: TextAlign.center,
//style: TextStyle(
//color: Colors.white,
//fontSize: 15,
//),
//),
//],
//),
//);
//}
//},
//),