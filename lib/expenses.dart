import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String name;
  double amount;

  Expense(
      {  required this.id, required this.name, required this.amount}); //with curly bracket means named parameter , without curly bracket = positional parameter
}

class ExpenseList extends StatefulWidget {
  final List<Expense> expenses;
  final void Function(Expense) onExpenseAdded;
  final void Function(Expense) onExpenseEdited;

  const ExpenseList(
      {super.key, required this.expenses, required this.onExpenseAdded,required this.onExpenseEdited});

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
          final expense = widget.expenses[index];
          return Dismissible(
            key: Key(expense.id), // Unique key for each expense
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            onDismissed: (direction) {
              // Remove the expense from the list and Firestore
              setState(() {
                widget.expenses.removeAt(index);
                _deleteExpenseFromFirestore(expense.id);
              });
            },
           child:Container(
            color: Colors.greenAccent,
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              trailing: IconButton(
              onPressed: () => _editExpense(expense),
              icon: Icon(Icons.edit),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.name,
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
                'Rs ${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Trajan Pro',
                  fontWeight: FontWeight.w800,
                  fontSize: 15.0,
                ),
              ),
            )
          )
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


  void _deleteExpenseFromFirestore(String expenseId) {
    final collectionReference = FirebaseFirestore.instance.collection('expenses');
    collectionReference
        .doc(expenseId) // Use the 'id' to delete the expense
        .delete()
        .then((_) {
      print('Expense deleted from Firestore!');
    })
        .catchError((error) {
      print('Error deleting expense from Firestore: $error');
    });
  }



  void _saveExpenseToFirestore(Expense expense) {
    final collectionReference = FirebaseFirestore.instance.collection('expenses');
      collectionReference.add({
      'name': expense.name,
      'amount': expense.amount,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((docRef) {
      print('Expense added to Firestore with ID: ${docRef.id}');
      expense.id = docRef.id;
    }).catchError((error) {
      print('Error adding expense to Firestore: $error');
    });
  }

  void _updateExpenseInFirestore(Expense expense) {
    final collectionReference = FirebaseFirestore.instance.collection('expenses');
    collectionReference
        .doc(expense.id) // Use the 'id' to update the existing expense
        .update({
      'name': expense.name,
      'amount': expense.amount,
    })
        .then((_) {
      print('Expense updated in Firestore!');
    })
        .catchError((error) {
      print('Error updating expense in Firestore: $error');
    });
  }

  void _editExpense(Expense expense) async {
    TextEditingController nameController = TextEditingController(text: expense.name);
    TextEditingController amountController = TextEditingController(text: expense.amount.toString());

    // Show a dialog to allow the user to edit the expense details
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                onChanged: (value) {
                  expense.name = value;
                },
                decoration: InputDecoration(labelText: 'Expense Name:'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: amountController,
                onChanged: (value) {
                  expense.amount = double.tryParse(value) ?? 0.0;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price:'),
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog box without saving changes
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save the changes and update the expense in the widget's state
                if (expense.name.isNotEmpty && expense.amount != 0.0) {
                  setState(() {
                    widget.onExpenseEdited(expense); // Call the onExpenseEdited callback to update the expense
                    _updateExpenseInFirestore(expense); // Update the expense in Firestore (if necessary)
                  });
                  Navigator.pop(context); // Close the dialog box after saving changes
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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
                        Expense(id: '', name: expenseName, amount: expenseAmount);
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
