const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Firebase Admin SDK
const serviceAccount = require('./firebase-service-account.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://${process.env.FIREBASE_PROJECT_ID}.firebaseio.com`
});

const db = admin.firestore();

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'Court Booking IoT Server' });
});

// Auth routes
app.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const userRecord = await admin.auth().getUserByEmail(email);
    // Trong thực tế, cần verify password, nhưng Firebase Admin không hỗ trợ trực tiếp
    // Sử dụng Firebase Auth SDK ở client hoặc custom auth
    res.json({ uid: userRecord.uid, email: userRecord.email });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.post('/auth/register', async (req, res) => {
  try {
    const { email, password, name, phone } = req.body;
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: name,
    });
    // Lưu thêm info vào Firestore
    await db.collection('users').doc(userRecord.uid).set({
      email,
      name,
      phone,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    res.json({ uid: userRecord.uid, email: userRecord.email });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.post('/auth/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    await admin.auth().generatePasswordResetLink(email);
    res.json({ message: 'Password reset email sent' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Booking routes
app.post('/bookings', async (req, res) => {
  try {
    const { userId, courtId, date, time } = req.body;
    const bookingRef = await db.collection('bookings').add({
      userId,
      courtId,
      date,
      time,
      status: 'pending',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    res.json({ id: bookingRef.id, message: 'Booking created' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.get('/bookings', async (req, res) => {
  try {
    const { userId } = req.query;
    let query = db.collection('bookings');
    if (userId) {
      query = query.where('userId', '==', userId);
    }
    const snapshot = await query.get();
    const bookings = [];
    snapshot.forEach(doc => {
      bookings.push({ id: doc.id, ...doc.data() });
    });
    res.json(bookings);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.put('/bookings/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;
    await db.collection('bookings').doc(id).update(updateData);
    res.json({ message: 'Booking updated' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.delete('/bookings/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await db.collection('bookings').doc(id).update({ status: 'cancelled' });
    res.json({ message: 'Booking cancelled' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Courts routes
app.get('/courts', async (req, res) => {
  try {
    const snapshot = await db.collection('courts').get();
    const courts = [];
    snapshot.forEach(doc => {
      courts.push({ id: doc.id, ...doc.data() });
    });
    res.json(courts);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});