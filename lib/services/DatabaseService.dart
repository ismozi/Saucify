import 'package:cloud_firestore/cloud_firestore.dart';

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

  getCollectionStream(String collection){
    return FirebaseFirestore.instance.collection(collection).orderBy('timestamp', descending: true).snapshots();
  }

}