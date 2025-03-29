import 'package:flutter/material.dart';
import 'package:hello_world/services/apiService.dart';
import 'package:hello_world/main.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';


class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  ApiService apiService = ApiService();
  late Future<List<dynamic>> users;

  @override
  void initState() {
    super.initState();
    users = apiService.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAuthedAppBar(context),
      bottomNavigationBar: buildStandardBottomAppBar(context),
      body: FutureBuilder<List<dynamic>>(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                final name = user['username'] ?? 'No Name.';
                final password = user['password'] ?? 'No Password.';
                final emailAddress = user['email'] ?? 'No Password.';

                return ListTile(
                  title: Text(name),  // Show username
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Password: $password'),
                      Text('Password: $emailAddress')
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
