import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'expenses.dart';
import 'login_page.dart';
import 'register_user.dart';
import 'package:fl_chart/fl_chart.dart';

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
    Expense(id: '1', name: 'Groceries', amount: -1000),
    Expense(id: '2', name: 'Salary', amount: 50000),
    Expense(id: '3', name: 'Water Bill', amount: -1500),
    Expense(id: '4', name: 'Trip', amount: -5000),
    Expense(id: '5', name: 'Education', amount: -20000),
  ];

  double totalExpense = 0.00;

  void updateTotalExpenses() {
    totalExpense = expenses.fold(0.0, (sum, Expense) => sum + Expense.amount);
  }

  // Function to calculate the distribution of expenses across categories
  Map<String, double> calculateExpenseDistribution() {
    Map<String, double> distribution = {};
    for (var expense in expenses) {
      if (distribution.containsKey(expense.name)) {
        distribution.update(expense.name, (value)  => value + expense.amount.abs());
      } else {
        distribution[expense.name] = expense.amount.abs();
      }
    }
    return distribution;
  }

  // Function to calculate spending trends over time
  List<FlSpot> calculateSpendingTrends() {
    List<FlSpot> spendingTrends = [];
    double cumulativeTotal = 0.0;
    for (var expense in expenses) {
      cumulativeTotal += expense.amount;
      spendingTrends.add(FlSpot(spendingTrends.length.toDouble(), cumulativeTotal));
    }
    return spendingTrends;
  }

  @override
  void initState() {
    super.initState();
    updateTotalExpenses(); // Calculate total expenses initially
  }

  void _editExpense(Expense expense) {
    // TODO: Handle editing the expense
    print('Editing expense: ${expense.name}');
  }

  @override
  Widget build(BuildContext context) {
    final expenseDistribution = calculateExpenseDistribution();
    final spendingTrends = calculateSpendingTrends();

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
        body: SingleChildScrollView(
          child: Center(
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
                                  onExpenseEdited: _editExpense,
                                )),
                      );
                    },
                    icon: Icon(
                      Icons.double_arrow_outlined,
                      size: 36,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    height: 200,
                    width: 200,
                    child: PieChart(
                      PieChartData(
                        sections: expenseDistribution.entries.map((entry) {
                          return PieChartSectionData(
                            title: entry.key,
                            value: entry.value,
                            color: getRandomColor(), // Helper function to get random colors
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                ]),
          ),
        ));
  }
  Color getRandomColor() {
    return Color.fromRGBO(
      100 + (DateTime.now().millisecondsSinceEpoch % 155),
      100 + (DateTime.now().millisecondsSinceEpoch % 155),
      100 + (DateTime.now().millisecondsSinceEpoch % 155),
      1,
    );
  }
}
