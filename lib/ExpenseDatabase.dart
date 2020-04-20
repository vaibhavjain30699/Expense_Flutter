import 'dart:async';
import 'package:flutter/cupertino.dart';
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

  Future<List<ExpenseItem>> getAllItems() async{
    //  print('aa');
    await openDB();
    final List<Map<String,dynamic>> result = await database.query('records');
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