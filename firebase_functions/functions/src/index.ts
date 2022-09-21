import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp(functions.config().firebase);

export const generateFirstMixes = functions.https.onRequest(async (req, res)=> {
    let timeRanges = ["short", "medium", "long"];

    for (const timeRange of timeRanges) {
        let targetUserId: string = "ismozirek";
        let following: Array<string> = ["Mikeward", "adibAlkd", "gspStPierre"];
        let playlistSize: number = 30;
        let numOfTracks: number = Math.floor((playlistSize / following.length));
        let tracksItems: Array<Object> = [];

        let db = admin.firestore();

        for (const userId of following) { 
            let userSnap = await db.collection("users").doc(userId).get();
            let userData = userSnap.data();
            let topTracks: Array<String> = userData!["topTracks"][timeRange];

            topTracks = topTracks.slice(0, numOfTracks);

            topTracks.forEach((element) => {
                tracksItems.push({
                    "trackId": element,
                    "userId": userId
                });
            });
        }

        let docRef = db.collection("users").doc(targetUserId);
        let targetUserSnap = await docRef.get();
        let targetUserData = targetUserSnap.data();
        targetUserData!["Mixes"][timeRange] = tracksItems;
        docRef.set(targetUserData!);
    }
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
