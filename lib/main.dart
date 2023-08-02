import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'expenses.dart';
import 'login_page.dart';
import 'register_user.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAASKZEv8mPmNetiS2wcJDEMK0t41RUyDA",
            appId: "1:211421562292:web:9c67e2433faa2750a35ee1",
            messagingSenderId: "211421562292",
            projectId: "budget-tracker-8622a"));
  }
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/register',
      routes: {
        '/register': (context) => RegistrationPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Expense> expenses = [
    Expense(name: 'Groceries', amount: -1000),
    Expense(name: 'Salary', amount: 50000),
    Expense(name: 'Water Bill', amount: -1500),
    Expense(name: 'Trip', amount: -5000),
    Expense(name: 'Education', amount: -20000),
  ];

  double totalExpense = 0.00;

  void updateTotalExpenses() {
    totalExpense = expenses.fold(0.0, (sum, Expense) => sum + Expense.amount);
  }

  @override
  void initState() {
    super.initState();
    updateTotalExpenses(); // Calculate total expenses initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              "Budget Tracker",
              style: TextStyle(
                fontFamily: 'Trajan Pro',
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20.0),
                CircleAvatar(
                  radius: 60.0,
                  backgroundImage: AssetImage('assets/user.jpg'),
                ),
                SizedBox(height: 20.0),
                Text(
                  'Welcome Back !',
                  style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 60.0),
                Container(
                  height: 80.0,
                  width: 380.0,
                  color: Colors.blue[300],
                  child: Column(
                    children: [
                      Text(
                        'Total Expense',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30.0,
                            color: Colors.white),
                      ),
                      Text(
                        'RS $totalExpense',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 30.0,
                            color: Colors.white),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ExpenseList(
                                expenses: expenses,
                                onExpenseAdded: (Expense) {
                                  setState(() {
                                    expenses.add(Expense);
                                    updateTotalExpenses(); // Update total expenses
                                  });
                                },
                              )),
                    );
                  },
                  icon: Icon(
                    Icons.double_arrow_outlined,
                    size: 36,
                    color: Colors.black,
                  ),
                )
              ]),
        ));
  }
}
