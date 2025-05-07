// server.js

const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
const mongoose = require('mongoose');

const app = express();
app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect('mongodb://localhost:27017/food_ordering_app', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const userSchema = new mongoose.Schema({
  email: String,
  password: String,
  cart: Array,
});

const menuItemSchema = new mongoose.Schema({
  id: String,
  name: String,
  image: String,
  price: Number,
  rating: Number,
});

const orderSchema = new mongoose.Schema({
  order_id: String,
  email: String,
  items: Array,
  total: Number,
  payment_method: String,
  status: String,
  created_at: Date,
});

const User = mongoose.model('User', userSchema);
const MenuItem = mongoose.model('MenuItem', menuItemSchema);
const Order = mongoose.model('Order', orderSchema);

// Initialize menu items if empty
const initializeMenuItems = async () => {
  const count = await MenuItem.countDocuments();
  if (count === 0) {
    const menuItems = [
      { id: '1', name: 'Idli', image: '🥥', price: 40, rating: 4.6 },
      { id: '2', name: 'Dosa', image: '🫓', price: 60, rating: 4.8 },
      { id: '3', name: 'Vada', image: '🍩', price: 30, rating: 4.5 },
      { id: '4', name: 'Upma', image: '🍚', price: 50, rating: 4.2 },
      { id: '5', name: 'Pongal', image: '🍲', price: 70, rating: 4.4 },
      { id: '6', name: 'Uttapam', image: '🍕', price: 80, rating: 4.3 },
      { id: '7', name: 'Appam', image: '🥞', price: 65, rating: 4.6 },
      { id: '8', name: 'Puttu', image: '🌾', price: 55, rating: 4.4 },
      { id: '9', name: 'Rava Dosa', image: '🫓', price: 75, rating: 4.7 },
      { id: '10', name: 'Masala Dosa', image: '🥙', price: 90, rating: 4.9 },
      { id: '11', name: 'Medu Vada', image: '🍩', price: 35, rating: 4.5 },
      { id: '12', name: 'Thayir Sadam', image: '🍶', price: 50, rating: 4.6 },
      { id: '13', name: 'Sambar Rice', image: '🍛', price: 70, rating: 4.5 },
      { id: '14', name: 'Lemon Rice', image: '🍋', price: 60, rating: 4.4 },
      { id: '15', name: 'Tamarind Rice', image: '🌰', price: 65, rating: 4.3 },
      { id: '16', name: 'Kootu', image: '🥗', price: 55, rating: 4.2 },
      { id: '17', name: 'Avial', image: '🥦', price: 60, rating: 4.4 },
      { id: '18', name: 'Rasam', image: '🍵', price: 45, rating: 4.6 },
      { id: '19', name: 'Filter Coffee', image: '☕', price: 30, rating: 4.9 },
      { id: '20', name: 'Kesari', image: '🍮', price: 40, rating: 4.7 },
    ];
    await MenuItem.insertMany(menuItems);
  }
};

initializeMenuItems();

// ----------- Routes -----------

// Register
app.post('/api/register', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Email and password are required' });

  const existingUser = await User.findOne({ email });
  if (existingUser) return res.status(409).json({ error: 'User already exists' });

  const user = new User({ email, password, cart: [] });
  await user.save();

  res.status(201).json({ message: 'User registered successfully', email });
});

// Login
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Email and password are required' });

  const user = await User.findOne({ email });
  if (!user || user.password !== password) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  res.json({ message: 'Login successful', email });
});

// Get Menu
app.get('/api/menu', async (req, res) => {
  const menu = await MenuItem.find({}, { _id: 0 });
  res.json({ menu });
});

// Get Cart
app.get('/api/cart', async (req, res) => {
  const { email } = req.query;
  if (!email) return res.status(400).json({ error: 'Email is required' });

  const user = await User.findOne({ email });
  if (!user) return res.status(404).json({ error: 'User not found' });

  res.json({ cart: user.cart });
});

// Add to Cart
app.post('/api/cart/add', async (req, res) => {
  const { email, item_id } = req.body;
  if (!email || !item_id) return res.status(400).json({ error: 'Email and item_id are required' });

  const user = await User.findOne({ email });
  if (!user) return res.status(404).json({ error: 'User not found' });

  const item = await MenuItem.findOne({ id: item_id }, { _id: 0 });
  if (!item) return res.status(404).json({ error: 'Item not found' });

  const existingItem = user.cart.find(i => i.id === item_id);

  if (existingItem) {
    existingItem.quantity += 1;
  } else {
    user.cart.push({ ...item.toObject(), quantity: 1 });
  }

  await user.save();
  res.json({ message: 'Item added to cart', cart: user.cart });
});

// Remove from Cart
app.post('/api/cart/remove', async (req, res) => {
  const { email, item_id } = req.body;
  if (!email || !item_id) return res.status(400).json({ error: 'Email and item_id are required' });

  const user = await User.findOne({ email });
  if (!user) return res.status(404).json({ error: 'User not found' });

  const existingItem = user.cart.find(i => i.id === item_id);

  if (!existingItem) {
    return res.status(404).json({ error: 'Item not in cart' });
  }

  if (existingItem.quantity > 1) {
    existingItem.quantity -= 1;
  } else {
    user.cart = user.cart.filter(i => i.id !== item_id);
  }

  await user.save();
  res.json({ message: 'Item removed from cart', cart: user.cart });
});

// Checkout
app.post('/api/checkout', async (req, res) => {
  const { email, payment_method } = req.body;
  if (!email) return res.status(400).json({ error: 'Email is required' });

  const user = await User.findOne({ email });
  if (!user) return res.status(404).json({ error: 'User not found' });

  if (!user.cart.length) return res.status(400).json({ error: 'Cart is empty' });

  const total = user.cart.reduce((sum, item) => sum + item.price * item.quantity, 0);

  const order = new Order({
    order_id: uuidv4(),
    email,
    items: user.cart,
    total,
    payment_method: payment_method || 'Not specified',
    status: 'completed',
    created_at: new Date(),
  });

  await order.save();

  // Empty the user's cart
  user.cart = [];
  await user.save();

  res.json({ message: 'Order placed successfully', order });
});

// Get Orders
app.get('/api/orders', async (req, res) => {
  const { email } = req.query;
  if (!email) return res.status(400).json({ error: 'Email is required' });

  const orders = await Order.find({ email });
  res.json({ orders });
});

// Start server
const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
