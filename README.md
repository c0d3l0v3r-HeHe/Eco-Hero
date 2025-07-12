# 🌱 EcoHero - Environmental Impact Tracker

**EcoHero** is a gamified Flutter application designed to encourage eco-conscious behavior. Users can perform environment-friendly tasks, calculate their carbon footprint, classify waste using AI, stay updated on environmental news, and redeem rewards using the points they earn.

---

## 📱 Features

### 📝 Tasks  
- Users submit environment-friendly activities they've completed.  
- An AI evaluates the impact of each task and awards eco-points (in-app currency) based on positivity.

### 🌍 Carbon Calculator  
- Helps users estimate their carbon footprint based on lifestyle data.

### 🧠 Waste Classifier  
- Users upload images of waste.  
- AI automatically detects the type of waste: e-waste, biodegradable, plastic, etc.

### 📰 News  
- Curated list of recent government/environmental initiatives.  
- Users can summarize lengthy articles using AI.

### 🛍️ Rewards  
- Users can redeem eco-points to unlock virtual rewards (e.g., potions, tree tokens).
- Promotes environmental healing and digital collectibles.

---

## 🛠 Tech Stack

### 🔧 Frontend
- **Flutter**
- **Dart**

### ☁️ Backend (via Firebase Studio)
- **Firebase Authentication** (Google & Email)
- **Cloud Firestore** (for user data, tasks, news, etc.)
- **Firebase Storage** (for uploading waste images)
- **Firebase Functions/Extensions**:
  - AI task evaluator
  - Image classifier
  - News summarizer (OpenAI API)

---

## 📦 Firebase Data Model

| Collection             | Description |
|------------------------|-------------|
| `users`                | User profile and eco-points |
| `tasks`                | Environment-friendly tasks submitted by users |
| `carbon_calculations`  | Carbon footprint entries |
| `waste_classifications`| AI-based classification results of uploaded waste images |
| `news`                 | News articles and their AI-generated summaries |
| `rewards`              | Redeemable digital rewards |
| `user_rewards`         | Rewards redeemed by users |

---

## 🔐 Authentication
- Users can log in using:
  - Google Sign-In
  - Email & Password

---

## 🧠 AI Integrations

| Integration         | Trigger Type        | Description |
|---------------------|---------------------|-------------|
| Task Evaluation AI  | On `tasks` create   | Evaluates user input and assigns impact score & points |
| Waste Classifier    | On image upload     | Classifies type of waste using a custom model |
| News Summarizer     | On `news` create    | Summarizes news content using OpenAI API |

---

## 📂 Folder Structure (Recommended Flutter App)

```
lib/
├── main.dart
├── screens/
│ ├── tasks_screen.dart
│ ├── carbon_calculator_screen.dart
│ ├── waste_classifier_screen.dart
│ ├── news_screen.dart
│ └── rewards_screen.dart
├── models/
├── services/
├── widgets/
├── firebase_options.dart

```
## 🚀 Getting Started

1. **Clone the Repo**
   ```bash
   git clone https://github.com/yourusername/ecohero.git
   cd ecohero