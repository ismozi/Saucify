import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp(functions.config().firebase);

export const generateFirstMixes = functions.https.onRequest(async (req, res)=> {
    let body = JSON.parse(req.body)
    let timeRanges = ["short", "medium", "long"];
    let db = admin.firestore();
    let docRef = db.collection("users").doc(body.targetUserId);
    let targetUserSnap = await docRef.get();
    let targetUserData = targetUserSnap.data();
    let following: Array<string> = body.following;
    let playlistSize: number = body.size;
    let numOfTracks: number = Math.floor((playlistSize / following.length));
    let remaining: number = playlistSize - (numOfTracks * following.length);

    for (const timeRange of timeRanges) {
        let tracksItems: Array<Object> = [];

        for (const [index, userId] of following.entries()) { 
            let userSnap = await db.collection("users").doc(userId).get();
            let userData = userSnap.data();
            let topTracks: Array<String> = userData!["topTracks"][timeRange];

            if (index == following.length - 1)
                topTracks = topTracks.slice(0, numOfTracks + remaining);
            else 
                topTracks = topTracks.slice(0, numOfTracks);

            topTracks.forEach((element) => {
                tracksItems.push({
                    "trackId": element,
                    "userId": userId
                });
            });
        }

        targetUserData!["Mixes"][timeRange] = tracksItems;
        docRef.set(targetUserData!);
    }

    res.send("done");
});

export const onFollowingChange = functions.https.onRequest((req, res) => {

});

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript

export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  functions.config().firestore;
  response.send("Hello from Firebase!");
});
