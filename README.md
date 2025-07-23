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

 
![ex1](https://github.com/user-attachments/assets/1623bafe-7e47-4710-9bbc-481df6295ac6)



 📊 Bar graph budget overview

 
![ex3](https://github.com/user-attachments/assets/60f32c55-684f-4f37-872c-2248ceb2e89e)


🧿 Pie Chart of expenses


![ex2](https://github.com/user-attachments/assets/4e4ec539-be01-4639-ba10-d3c3509817df)



💵 DashBoard


![ex4](https://github.com/user-attachments/assets/42f799bf-6a7f-4917-9978-4ec3edf7061e)






