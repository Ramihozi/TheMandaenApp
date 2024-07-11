import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_mandean_app/screens/user.dart';

class FirebaseService {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('user');

  Future<List<User>> getUsers() async {
    List<User> userList = [];

    try {
      QuerySnapshot querySnapshot = await usersCollection.get();
      querySnapshot.docs.forEach((doc) {
        User user = User.fromSnapshot(doc); // Use fromSnapshot method
        userList.add(user);
      });
    } catch (e) {
      print('Error fetching users: $e');
    }

    return userList;
  }
}
