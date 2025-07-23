# CSP – Personal Budgeting App

CSP is a Flutter mobile application designed to help users manage their budgets and track transactions effectively. It uses Firebase for authentication and Firestore for storing user data in real time.

## ✨ Features

- 🔐 Firebase Authentication
- 📊 Dashboard with budget overview
- 💸 Add and manage transactions
- 📁 Handle multiple budgets
- 👤 View and edit user profile
- ☁️ Real-time updates with Cloud Firestore

## 📁 Project Structure

lib/
├── models/
│ ├── budget.dart
│ └── transaction.dart
├── services/
│ ├── firestore_services.dart
│ └── firebase_auth.dart
├── screens/
│ ├── add_transaction.dart
│ ├── budgets_screen.dart
│ ├── dashboard_screen.dart
│ ├── home_screen.dart
│ ├── profile_screen.dart
│ └── transactions_screen.dart
├── firebase_options.dart
└── main.dart
## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/22bq1a42d4/CSP.git
   cd CSP
2. **Install Dependencies**
   ```bash
   flutter pub get
3. **Configure Firestore :**
   > Follow the Firebase setup instructions for Flutter.
   > Replace firebase_options.dart with your own Firebase config file.
4. **Run the App**
      ```bash
   flutter run
## 🧰 Dependencies
.firebase_core
.firebase_auth
.cloud_firestore
.flutter/material
## 📷 Screenshots
 🔐 Firebase Authentication
![exe1](https://github.com/user-attachments/assets/ed29cb40-c1a2-4b86-ad44-2a882b239b99)


 📊 Dashboard with budget overview
![exe2](https://github.com/user-attachments/assets/20ea90d5-149f-45b6-ab30-e050acfea5a3)



