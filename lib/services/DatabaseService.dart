import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saucify/services/spotifyService.dart';
import '../app/app.locator.dart';

class DatabaseService {
  setSearchParam(String username) {
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < username.length; i++) {
      temp = temp + username[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
}

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
    object['searchParams'] = setSearchParam(object['username']);
    await collectionRef.doc(id).set(object);
  }

  getPostsStream(){
    // TODO: Manage friends list
    return FirebaseFirestore.instance.collection('posts').where('postedBy', whereIn: ['ismozirek']).orderBy('timestamp', descending: true).snapshots();
  }

  getSearchStream(String query) {
    return FirebaseFirestore.instance.collection('users').where('searchParams', arrayContains: query).snapshots();
  }

  getUserDocument(String userId){
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }
}