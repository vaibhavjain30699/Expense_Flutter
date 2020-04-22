import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ExpenseItem{
  int id;
  int amount;
  String type;
  String date;
  String time;

  ExpenseItem({this.id,@required this.amount,@required this.type,@required this.date,@required this.time});

  Map<String,dynamic> toMap(){
    return {
      'id' : id,
      'amount' : amount,
      'type' : type,
      'date' : date,
      'time' : time,
    };
  }

}

class ExpenseDBManger{
  Database database;
  int total = 0;

  Future<void> openDB() async{
    if(database==null){
      database = await openDatabase(
          join(await getDatabasesPath(),'Expense.db'),
          version: 1,
          onCreate: (db,version){
            return db.execute("CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT,amount INTEGER,type TEXT,date TEXT,time TEXT)");
          }
      );
    }
  }

  Future<int> addTransactions(ExpenseItem item) async{
    await openDB();
    return database.insert('records', item.toMap());
  }

  Future<List<ExpenseItem>> getMonthlyTransactions() async{
    await openDB();
    List<Map<String,dynamic>> result = await database.query('records');
    List<ExpenseItem> ans = List.generate(result.length, (i){
      return ExpenseItem(
          id: result[i]['id'],
          amount: result[i]['amount'],
          type: result[i]['type'],
          date: result[i]['date'],
          time: result[i]['time']
      );
    });

    List<ExpenseItem> ans1 = new List<ExpenseItem>();
    DateTime date = new DateTime.now();
    for(int i=0;i<ans.length;i++){
      DateTime t = new DateFormat("dd-MM-yyyy","en_US").parse(ans[i].date);
      if(t.month == date.month)
        ans1.add(ans[i]);
    }
    print(ans1.length);
    return ans1;
  }

  Future<List<ExpenseItem>> getAllItems() async{
    //  print('aa');
    await openDB();
    List<Map<String,dynamic>> result = await database.query('records');
    result = result.reversed.toList();
    return List.generate(result.length, (i){
      return ExpenseItem(
          id: result[i]['id'],
          amount: result[i]['amount'],
          type: result[i]['type'],
          date: result[i]['date'],
          time: result[i]['time']
      );
    });
  }
  
  Future getTotalExpense() async{
    await openDB();
    return (database.rawQuery('SELECT SUM(amount) as Total FROM records'));
  }

}