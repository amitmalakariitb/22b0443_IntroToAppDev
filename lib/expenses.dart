import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String name;
  double amount;

  Expense(
      {required this.name,
      required this.amount}); //with curly bracket means named parameter , without curly bracket = positional parameter
}

class ExpenseList extends StatefulWidget {
  final List<Expense> expenses;
  final void Function(Expense) onExpenseAdded;

  const ExpenseList(
      {super.key, required this.expenses, required this.onExpenseAdded});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60.0,
        title: Container(
            child: Row(
          children: [
            SizedBox(width: 70.0),
            Text(
              'Expenses',
              style: TextStyle(
                backgroundColor: Colors.blueAccent,
                fontFamily: 'Trajan Pro',
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
          ],
        )),
      ),
      body: ListView.builder(
        itemCount: widget.expenses.length,
        itemBuilder: (context, index) {
          final Expense = widget.expenses[index];
          return Container(
            color: Colors.greenAccent,
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Expense.name,
                    style: TextStyle(
                      fontFamily: 'Trajan Pro',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10.0)
                ],
              ),
              subtitle: Text(
                'Rs ${Expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Trajan Pro',
                  fontWeight: FontWeight.w800,
                  fontSize: 15.0,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddExpenseDialog(context);
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }

  // void _saveExpenseToFirestore(Expense expense) {
  //   final collectionReference =
  //       FirebaseFirestore.instance.collection('expenses');
  //   collectionReference.add({
  //     'name': expense.name,
  //     'amount': expense.amount,
  //     'timestamp': FieldValue.serverTimestamp(), // Optional: Add a timestamp
  //   }).then((_) {
  //     print('Expense added to Firestore!');
  //   }).catchError((error) {
  //     print('Error adding expense to Firestore: $error');
  //   });
  // }

  void _saveExpenseToFirestore(Expense expense) {
    FirebaseFirestore.instance.collection('expenses').add({
      'name': expense.name,
      'amount': expense.amount,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((docRef) {
      print('Expense added to Firestore with ID: ${docRef.id}');
    }).catchError((error) {
      print('Error adding expense to Firestore: $error');
    });
  }


  void _showAddExpenseDialog(context) {
    String expenseName = '';
    double expenseAmount = 0.0;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text(
                'Add Expense',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  onChanged: (value) {
                    expenseName = value;
                  },
                  decoration: InputDecoration(labelText: 'Expense Name:'),
                ),
                SizedBox(height: 16.0),
                TextField(
                  onChanged: (value) {
                    expenseAmount = double.tryParse(value) ?? 0.0;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price:'),
                )
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                      context); // Close the dialog box without adding the expense
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (expenseName.isNotEmpty && expenseAmount != 0.0) {
                    final newExpense =
                        Expense(name: expenseName, amount: expenseAmount);
                    setState(() {
                      widget.onExpenseAdded(newExpense);
                      _saveExpenseToFirestore(newExpense);
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        });
  }
}
