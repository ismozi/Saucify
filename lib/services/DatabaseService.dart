import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saucify/services/spotifyService.dart';
import '../app/app.locator.dart';

class DatabaseService {  
  Future<List> getAllDocsOfCollection(String collection) async {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection(collection);
    QuerySnapshot querySnapshot = await collectionRef.get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addDocToCollection(String collection, dynamic object) async {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection(collection);
    await collectionRef.add(object);
  }

  Future<void> register(String id, dynamic object) async {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection('users');
    await collectionRef.doc(id).set(object);
  }

  getPostsStream(){
    // TODO: Manage friends list
    return FirebaseFirestore.instance.collection('posts').where('postedBy', whereIn: ['ismozirek']).orderBy('timestamp', descending: true).snapshots();
  }

}