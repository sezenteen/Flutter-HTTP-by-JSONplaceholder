import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD with HTTP',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiUrl = 'https://jsonplaceholder.typicode.com/users';

  List users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // Read: Fetch all users
  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    }
  }

  // Create: Add a new user
Future<void> addUser(String name, String email) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'name': name, 'email': email}),
  );
  if (response.statusCode == 201) {
    setState(() {
      // Simulate adding a user locally
      users.add({'id': users.length + 1, 'name': name, 'email': email});
    });
  }
}

// Update: Edit a user
Future<void> editUser(int id, String name, String email) async {
  final response = await http.put(
    Uri.parse('$apiUrl/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'name': name, 'email': email}),
  );
  if (response.statusCode == 200) {
    setState(() {
      // Simulate editing a user locally
      final userIndex = users.indexWhere((user) => user['id'] == id);
      if (userIndex != -1) {
        users[userIndex]['name'] = name;
        users[userIndex]['email'] = email;
      }
    });
  }
}

// Delete: Remove a user
Future<void> deleteUser(int id) async {
  final response = await http.delete(Uri.parse('$apiUrl/$id'));
  if (response.statusCode == 200) {
    setState(() {
      // Simulate deleting a user locally
      users.removeWhere((user) => user['id'] == id);
    });
  }
}


  // UI to display and manage users
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD with HTTP')),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['name']),
            subtitle: Text(user['email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => editUser(user['id'], 'Updated Name', 'updated@email.com'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteUser(user['id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addUser('New User', 'newuser@email.com'),
        child: const Icon(Icons.add),
      ),
    );
  }
}