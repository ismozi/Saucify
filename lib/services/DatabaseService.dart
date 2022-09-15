import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saucify/services/spotifyService.dart';
import '../app/app.locator.dart';

class DatabaseService {
  setSearchParam(String username) {
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < username.length; i++) {
      temp = temp + username[i];
      caseSearchList.add(temp.toLowerCase());
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

  Future<void> login(String id, dynamic object) async {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection('users');
    DocumentReference docRef = collectionRef.doc(id);
    DocumentSnapshot docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      object['searchParams'] = setSearchParam(object['username']);
      docRef.set(object);
    } else {
      Map<String, dynamic> userObj = docSnapshot.data() as Map<String, dynamic>;
      userObj['topTracks'] = object['topTracks'];
      userObj['topArtists'] = object['topArtist'];
      docRef.set(userObj);
    }

    // DocumentReference copyFrom = docRef;
    // DocumentReference copyTo = FirebaseFirestore.instance.collection('users').doc('Ye');

    // copyFrom.get().then((value) => {
    //   copyTo.set(value.data())
    // });
  }

  Future<void> signIn(String id, dynamic object) async {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection('users');
    DocumentReference docRef = collectionRef.doc(id);
    DocumentSnapshot docSnapshot = await docRef.get();

    Map<String, dynamic> userObj = docSnapshot.data() as Map<String, dynamic>;
    userObj['topTracks'] = object['topTracks'];
    userObj['topArtists'] = object['topArtist'];
    docRef.set(userObj);
  }

  Future<void> toggleLike(String postId, String userId) async {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection('posts');
    DocumentReference docRef = collectionRef.doc(postId);
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;
      bool isLiked = docData['likedBy'].contains(userId);
      if (isLiked){
        docData['likedBy'].remove(userId);
      } else {
        docData['likedBy'].add(userId);
      }
      docRef.set(docData);
    }
  }

  getPostsStream(List following) {
    // TODO: Manage friends list
    return FirebaseFirestore.instance.collection('posts').where('postedBy', whereIn: following).orderBy('timestamp', descending: true).snapshots();
  }

  getSearchStream(String query) {
    String lowerCaseQuery = query.toLowerCase();
    return FirebaseFirestore.instance.collection('users').where('searchParams', arrayContains: lowerCaseQuery).snapshots();
  }

  getUserDocument(String userId){
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  getUserDocumentStream(String userId){
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  toggleFollow(String userId, String userToFollow) async {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection('users');
    DocumentReference docRef = collectionRef.doc(userToFollow);
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;
      bool isFollowed = docData['followers'].contains(userId);
      if (isFollowed){
        docData['followers'].remove(userId);
      } else {
        docData['followers'].add(userId);
      }
      docRef.set(docData);
    }
  }

  Future<List> getFollowing(String userId) async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance.collection('users').where('followers', arrayContains: userId).get();
    List docList = querySnap.docs;
    List userFollowing = [];
    docList.forEach((element) {
      userFollowing.add(element.id);
    });
    return userFollowing;
  }

  getFollowingSnapshot(String userId) {
    return FirebaseFirestore.instance.collection('users').where('followers', arrayContains: userId).snapshots();
  }

  deletePost(String postId){
    FirebaseFirestore.instance.collection('posts').doc(postId).delete();
  }
}