const path = require('path');
const admin = require('firebase-admin');

const keyPath = process.argv[2];
if (!keyPath) {
  console.error('Usage: node seed_firestore.js <path-to-service-account.json>');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(require(path.resolve(keyPath))),
});

const db = admin.firestore();
const ts = (y, m, d) => admin.firestore.Timestamp.fromDate(new Date(Date.UTC(y, m - 1, d, 23, 59, 59)));

const coffees = {
  'black-coffee': { name: 'Black Coffee', price: 1.8, rating: 4.7, image: 'assets/images/coffee5.png', order: 1, featured: false, color: 0xff3e2a1e },
  espresso: { name: 'Espresso', price: 1.2, rating: 4.9, image: 'assets/images/coffee4.png', order: 2, featured: false, color: 0xff6e4a35 },
  mocha: { name: 'Mocha', price: 1.6, rating: 4.7, image: 'assets/images/coffee6.png', order: 3, featured: false, color: 0xff5a3a28 },
  americano: { name: 'Americano', price: 1.3, rating: 4.8, image: 'assets/images/coffee2.png', order: 4, featured: false, color: 0xff6e4a35 },
  'matcha-latte': { name: 'Matcha Latte', price: 2.49, rating: 4.5, image: 'assets/images/coffee3.png', order: 5, featured: true, color: 0xff4b5e23 },
  'milk-coffee': { name: 'Milk Coffee', price: 2.2, rating: 4.6, image: 'assets/images/coffee1.png', order: 6, featured: false, color: 0xffcbbf8f },
  'milk-latte': { name: 'Milk Latte', price: 2.39, rating: 4.5, image: 'assets/images/coffee1.png', order: 7, featured: true, color: 0xffcbbf8f },
  'iced-cappuccino': { name: 'Iced Cappuccino', price: 2.0, rating: 4.5, image: 'assets/images/coffee2.png', order: 8, featured: true, color: 0xff6e4a35 },
  'caramel-latte': { name: 'Caramel Latte Ice Cream', price: 2.99, rating: 4.8, image: 'assets/images/coffee6.png', order: 9, featured: false, color: 0xff8a5a3c },
};

const featuredOrder = ['milk-latte', 'iced-cappuccino', 'matcha-latte'];

const promos = {
  'caramel-latte': { title: 'Caramel Latte Ice Cream', price: 2.99, image: 'assets/images/ad.png', coffeeId: 'caramel-latte', order: 1 },
};

const discounts = {
  'off-70': { type: 'percent', value: 70, validUntil: ts(2027, 7, 4), order: 1 },
  'off-30': { type: 'percent', value: 30, validUntil: ts(2027, 7, 4), order: 2 },
  'off-40': { type: 'percent', value: 40, validUntil: ts(2027, 7, 4), order: 3 },
  'buy1get2': { type: 'bogo', value: 0, buy: 1, get: 2, validUntil: ts(2027, 7, 4), order: 4 },
};

const settings = {
  deliveryFee: 1.4,
  addInPrice: 0.8,
  sizeM: 0.3,
  sizeL: 0.6,
  customBase: 1.5,
  customSizeM: 0.15,
  customSizeL: 0.3,
  toppingPrice: 0.2,
  pointsPerDollar: 1000,
};

async function main() {
  const batch = db.batch();
  for (const [id, data] of Object.entries(coffees)) {
    const fi = featuredOrder.indexOf(id);
    batch.set(db.collection('coffees').doc(id), { ...data, order: fi >= 0 ? 100 + fi : data.order });
  }
  for (const [id, data] of Object.entries(promos)) batch.set(db.collection('promos').doc(id), data);
  for (const [id, data] of Object.entries(discounts)) batch.set(db.collection('discounts').doc(id), data);
  batch.set(db.collection('settings').doc('app'), settings);
  await batch.commit();
  console.log('Seed complete');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
