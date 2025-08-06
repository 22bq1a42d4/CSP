# CSP – Community Service Project (Personal Budgeting App)

A Flutter mobile application designed to help users manage their budgets and track transactions effectively. It uses Firebase for authentication and Firestore for storing user data in real time.

## ✨ Features

-🔐 Firebase Authentication
Secure user sign-in and registration powered by Firebase.

-📊 Dashboard with Budget Overview
Visual summary of your spending, remaining budgets, and categories.

-💸 Add and Manage Transactions
Record income or expenses and view transaction history with ease.

-📁 Handle Multiple Budgets
Create and manage different budgets for various goals or categories.

-👤 View and Edit User Profile
Update user information and profile details within the app.

-☁️ Real-Time Updates with Cloud Firestore
All data changes reflect instantly across devices with Firestore sync.

-🧠 Smart Spending Suggestions (New)
Get intelligent suggestions based on your latest transactions — like alerting overspending in categories, or recommending budget adjustments.

## 📁 Project Structure

```
assets/
├── 🎨 fonts/
├── 🖼️ icon.png
├── 🖼️ logo.png
└── 🖼️ main_icon.png

lib/
├── 📦 models/
│   ├── 📄 budget.dart
│   └── 📄 transaction.dart
│
├── 🛠️ services/
│   ├── 🔐 firebase_auth.dart
│   └── 🔥 firestore_services.dart
│
├── 🖥️ screens/
│   ├── ➕ add_transaction.dart
│   ├── 💼 budgets_screen.dart
│   ├── 📊 dashboard_screen.dart
│   ├── 🏠 home_screen.dart
│   ├── 👤 profile_screen.dart
│   ├── 💡 suggestions_screen.dart
│   └── 📋 transactions_screen.dart
│
├── ⚙️ firebase_options.dart
├── 🧭 main_screen.dart
└── 🚀 main.dart

```
              


## 🚀 Getting Started
![Getting Started](https://media.giphy.com/media/SWoSkN6DxTszqIKEqv/giphy.gif)
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

This project utilizes the following core Flutter and Firebase packages:

| Package | Description |
|--------|-------------|
| [`firebase_core`](https://pub.dev/packages/firebase_core) | 🔌 Initializes Firebase within the Flutter app |
| [`firebase_auth`](https://pub.dev/packages/firebase_auth) | 🔐 Enables user authentication with email/password or providers |
| [`cloud_firestore`](https://pub.dev/packages/cloud_firestore) | ☁️ Handles real-time database interactions using Firestore |
| [`flutter/material.dart`](https://api.flutter.dev/flutter/material/material-library.html) | 🎨 Provides Material Design components and theming |



## 📷 Screenshots

### These images let u know our UI


| 🔐 Firebase Authentication | 📊 Bar Graph Overview | 🧿 Pie Chart of Expenses |
|:--:|:--:|:--:|
| [![Firebase](https://github.com/user-attachments/assets/b0a09547-03a5-4bb2-b507-488731aa4e28)](https://github.com/user-attachments/assets/b0a09547-03a5-4bb2-b507-488731aa4e28) | [![Bar Graph](https://github.com/user-attachments/assets/7abf09f1-bef0-4946-9d25-4d6e2770647b)](https://github.com/user-attachments/assets/7abf09f1-bef0-4946-9d25-4d6e2770647b) | [![Pie Chart](https://github.com/user-attachments/assets/7693b420-f514-4886-a2c6-324e11ff314f)](https://github.com/user-attachments/assets/7693b420-f514-4886-a2c6-324e11ff314f) |



| 💵 Dashboard | 💡 Smart Suggestions | 📋 Transactions |
|:--:|:--:|:--:|
| [![Dashboard](https://github.com/user-attachments/assets/42f799bf-6a7f-4917-9978-4ec3edf7061e)](https://github.com/user-attachments/assets/42f799bf-6a7f-4917-9978-4ec3edf7061e) | [![Suggestions](https://github.com/user-attachments/assets/11286e02-a251-4f74-bc6d-c7333f93f908)](https://github.com/user-attachments/assets/11286e02-a251-4f74-bc6d-c7333f93f908) | [![Transactions](https://github.com/user-attachments/assets/f87be747-429b-47bb-8840-73a72d6725c9)](https://github.com/user-attachments/assets/f87be747-429b-47bb-8840-73a72d6725c9) |







## 🛠️ Skills & Technologies Used

<p align="left">
  <a href="https://flutter.dev" target="_blank">
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  </a>
  <a href="https://dart.dev" target="_blank">
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  </a>
  <a href="https://firebase.google.com" target="_blank">
    <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  </a>
  <a href="https://firebase.google.com/docs/firestore" target="_blank">
    <img src="https://img.shields.io/badge/Firestore-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white" alt="Firestore" />
  </a>
  <a href="https://developer.android.com" target="_blank">
    <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  </a>
  <a href="https://developer.apple.com/ios/" target="_blank">
    <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS" />
  </a>
</p>



## 📦 Download

You can download the latest APK release of the CSP app from the [Releases](https://github.com/22bq1a42d4/CSP/releases) section.

<p>
  <a href="https://github.com/22bq1a42d4/CSP/releases/latest">
    <img src="https://img.shields.io/github/v/release/22bq1a42d4/CSP?label=Download%20APK&style=for-the-badge&logo=android&logoColor=white" alt="Download APK" />
  </a>
</p>


