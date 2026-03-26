const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credentialL: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function testBackendConnection() {
    try {
        console.log("Testing backend connection...");
        const docRef = db.collection('Courts').doc('court_from_vscode_01');
        await docRef.set({
            name: 'Sân Backend Server',
            type: 'VIP',
            pricePerHour: 500000,
            status: "Active",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log("Successfully connected to the backend and added a test document.");
    } catch (error) {
        console.error("Error connecting to the backend:", error);
        }
}
testBackendConnection();