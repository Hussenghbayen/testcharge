# TestCharge — Mobile Device Charging Shop Management App

A Flutter app for managing mobile phone/device charging shops: recording charging and sale transactions, tracking occupied shelves, managing customer debts and balances, and daily/weekly/monthly income reports.

The backend is a separate service hosted on Render, with authentication handled via Firebase Auth.

## The Problem

Owners of mobile device charging shops (which also sell related accessories) used to rely on paper notebooks or generic, non-specialized apps to track:

- Which device is on which shelf, when it was received, and when it's due for pickup
- How much debt each customer has, and how much they've paid
- Daily/weekly/monthly income from charging services versus direct sales

This leads to calculation errors, lost records, and difficulty knowing the shop's real-time financial status. **TestCharge** solves this with a mobile app built specifically for this type of shop.

## What the App Offers

- Recording device charging transactions and tracking their status (in progress / delivered)
- Managing shelves and linking each device to an occupied shelf
- Recording direct sales of products and accessories
- Managing customer debts: recording debt, partial payments, debt settlement
- Daily/weekly/monthly income reports that separate charging income from sales income
- Secure sign-in via Firebase (Email/Password or Google)

## Download the App

The latest APK build is available directly in this repository:

[⬇️ Download the App (APK)](assets/testcharge-release.apk)

## Team Members and Roles

| Name | Role | Areas of Responsibility |
|---|---|---|
| Hussein Ezzat Hussein Ghbayen | Flutter / Frontend | Authentication screens, Router |
| Hussein Ezzat Hussein Ghbayen | Flutter / State Management | Cubits, ApiClient |
| Mahmoud Madi | Backend | API, database, access permissions |
| Mohammad Mahdi | UI/UX + Testing | Figma, automated tests |

## Tech Stack

**Frontend (this repository):**
- Flutter 3.x / Dart — SDK: ^3.10.7
- flutter_bloc (Cubit) — state management
- http — network layer (unified via ApiClient)
- firebase_auth + firebase_core — authentication
- google_sign_in — Google sign-in
- flutter_dotenv — environment configuration (.env)
- equatable — Bloc state comparison
- bloc_test + mocktail — testing (dev)

**Backend (separate repository — see Project Links):**
- API hosted on Render: `https://charging-api-tkne.onrender.com/api`
- Authentication: Firebase Auth (Bearer ID Token verified on every request)

## Architecture

A simple layered architecture within Flutter:

```
lib/
├── main.dart                 # Entry point: load .env, initialize Firebase, MultiBlocProvider
├── app_router.dart           # All routes (onGenerateRoute)
│
├── data/
│   ├── network/
│   │   ├── api_client.dart       # Unified HTTP client (single baseUrl, unified error handling)
│   │   └── api_exceptions.dart   # NetworkException / UnauthorizedException / ValidationException ...
│   └── Models/                   # Data models (Product, DeviceModel)
│
├── logic/                    # Cubits (state management) — one folder per feature
│   ├── auth_cubit/
│   ├── customers/
│   ├── dashboard/
│   ├── devices/
│   ├── products/
│   ├── shelves/
│   ├── transactions/
│   └── balance/               # BalanceCalculator — pure Dart logic, testable in isolation
│
├── presentation/screens/     # Screens, organized by feature (auth, debt, devices, history, ...)
│
├── widgets/                  # Shared components (DepositDialog, BottomSheets, ...)
└── utils/                    # Theme and general helper utilities
```

**Data flow:**
Screen (UI) → calls Cubit → Cubit calls ApiClient → ApiClient attaches the Firebase token and checks statusCode before decoding JSON → throws a classified exception (the appropriate ApiException subclass) on failure → Cubit catches it and maps it to a State → Screen rebuilds via BlocBuilder/BlocConsumer.

Financial calculation logic (debt, balance, partial payments, debt settlement) is fully isolated in `lib/logic/balance/balance_calculator.dart` — pure Dart with no dependency on Flutter or the network, making it directly testable (see `test/logic/balance_calculator_test.dart`).

## Prerequisites

- Flutter SDK (stable channel, compatible with Dart ^3.10.7)
- A Firebase account with a project that has Authentication enabled (Email/Password + Google Sign-In)
- `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) from the same Firebase project
- Access to the backend (running remotely or locally) — see Project Links

## Getting Started

```bash
# 1) Clone the repository
git clone https://github.com/Hussenghbayen/testcharge.git
cd testcharge

# 2) Install dependencies
flutter pub get

# 3) Set up environment variables (see next section)
cp .env.example .env
# then edit .env with the real values

# 4) Set up Firebase (see next section) — google-services.json / GoogleService-Info.plist

# 5) Run
flutter run
```

## Firebase Setup

1. Create a project on Firebase Console
2. Enable Authentication → sign-in methods: Email/Password and Google
3. **Android**: Add an Android app with the same `applicationId` found in `android/app/build.gradle.kts`, download `google-services.json`, and place it in `android/app/`
4. **iOS**: Add an iOS app with the same Bundle ID found in `ios/Runner.xcodeproj`, download `GoogleService-Info.plist`, and place it in `ios/Runner/`
5. From project settings (Project Settings → General), copy the Web API Key and set it in `.env` under `FIREBASE_WEB_API_KEY`

> Do not commit or push the real `google-services.json` / `GoogleService-Info.plist` files to GitHub if the repository is public and contains additional sensitive data beyond the public Firebase keys.

## API / Environment Setup

Copy `.env.example` to `.env` (the latter is excluded from Git via `.gitignore`):

```
API_BASE_URL=https://charging-api-tkne.onrender.com/api
FIREBASE_WEB_API_KEY=REPLACE_WITH_YOUR_FIREBASE_WEB_API_KEY
```

All network requests in the app go through a single entry point, `lib/data/network/api_client.dart`, which automatically attaches `Authorization: Bearer <Firebase ID Token>` to every protected request.

## Running Tests

```bash
flutter test
```

Current tests in `test/logic/`:

| File | Covers |
|---|---|
| `balance_calculator_test.dart` | Debt/balance calculation, partial payments, debt settlement (full/partial/overpaid), rejection of negative and zero values |
| `customers_cubit_test.dart` | That `payDebt` rejects invalid amounts before attempting any server request |
| `api_client_test.dart` | Distinguishing 401/403/network errors/validation errors from one another, and not crashing on a non-JSON response |

> Note: Shop data isolation (preventing one shop's customer from seeing another shop's data) is primarily the backend's responsibility (owner_id from the token) — see `docs/database-schema.md`. The frontend tests here only verify that every request attaches the correct token, which the backend's isolation logic relies on.

## Additional Documentation

- **Postman Collection**: `docs/TestCharge.postman_collection.json` — covers all API endpoints actually consumed by the app (auth, dashboard, customers and payments, products, transactions, shelves). Import it into Postman, fill in the `firebase_web_api_key` variable, run the Login request, and copy the resulting `idToken` into the `firebase_id_token` variable.
- **Database Schema**: `docs/database-schema.md` — an ERD (Mermaid) inferred from the actual API contracts, clarifying the shop isolation rule (owner_id) that must be enforced by the backend.

## Screenshots

| Login | Home | Customer Statement |
|---|---|---|
| ![login](docs/screenshots/login.png) | ![home](docs/screenshots/home.png) | ![customer](docs/screenshots/customer.png) |

Demo video: https://youtu.be/iguguW1MXZ4

## Building the App (Release Build)

```bash
# Android — APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Android — App Bundle (for Google Play)
flutter build appbundle --release

# iOS (requires macOS + Xcode + Apple Developer account)
flutter build ipa --release
```

## Project Links

| Item | Link |
|---|---|
| Backend repository | _add the actual backend repository link here_ |
| Backend (live environment) | https://charging-api-tkne.onrender.com |
| Graduation report (PDF) | [docs/report.pdf](docs/report.pdf) |
| Graduation report (DOCX) | [docs/report.docx](docs/report.docx) |
| Figma file | https://www.figma.com/design/z7EdLLqHxaxUXPiHqY20FK/Untitled |

---
---

# TestCharge — تطبيق إدارة محلات شحن الأجهزة ومبيعاتها

تطبيق Flutter لإدارة محلات شحن الهواتف/الأجهزة المحمولة: تسجيل عمليات الشحن والبيع، متابعة الرفوف (الشيلفات) المشغولة، إدارة ديون وأرصدة العملاء، وتقارير الدخل اليومية/الأسبوعية/الشهرية.

الباك اند منفصل ومستضاف على Render، والمصادقة عبر Firebase Auth.

## المشكلة

أصحاب محلات شحن الأجهزة المحمولة (وبيع الإكسسوارات المرافقة) كانوا يعتمدون على دفاتر ورقية أو تطبيقات عامة غير متخصصة لتتبّع:

- أي جهاز موجود على أي رف، ومتى استُلم، ومتى يجب تسليمه
- كم بقي على كل عميل من دين، وكم دفع
- الدخل اليومي/الأسبوعي/الشهري من الشحن مقابل البيع المباشر

هذا يؤدي لأخطاء حسابية، ضياع سجلات، وصعوبة في معرفة الوضع المالي للمحل لحظياً. **TestCharge** يحل هذا بتطبيق موبايل مخصص لهذا النوع من المحلات تحديداً.

## ماذا يقدّم التطبيق

- تسجيل عمليات شحن الأجهزة ومتابعة حالتها (قيد الشحن / تم التسليم)
- إدارة الرفوف (الشيلفات) وربط كل جهاز برف مشغول
- تسجيل عمليات البيع المباشر للمنتجات والإكسسوارات
- إدارة ديون العملاء: تسجيل الدين، الدفعات الجزئية، تسوية الدين
- تقارير دخل يومية/أسبوعية/شهرية تفصل بين دخل الشحن ودخل البيع
- تسجيل دخول آمن عبر Firebase (Email/Password أو Google)

## تحميل التطبيق

يمكن تحميل آخر نسخة APK مباشرة من هذا المستودع:

[⬇️ تحميل التطبيق (APK)](assets/testcharge-release.apk)

## أعضاء الفريق وأدوارهم

| الاسم | الدور | الأجزاء المسؤول عنها |
|---|---|---|
| حسين عزات حسين غباين | Flutter / Frontend | شاشات المصادقة، Router |
| حسين عزات حسين غباين | Flutter / State Management | Cubits، ApiClient |
| محمود ماضي | Backend | API، قاعدة البيانات، صلاحيات الوصول |
| محمد مهدي | UI/UX + اختبارات | Figma، الاختبارات الآلية |

## التقنيات المستخدمة

**Frontend (هذا المستودع):**
- Flutter 3.x / Dart — SDK: ^3.10.7
- flutter_bloc (Cubit) — إدارة الحالة
- http — طبقة الاتصال بالشبكة (موحّدة عبر ApiClient)
- firebase_auth + firebase_core — المصادقة
- google_sign_in — تسجيل دخول بحساب Google
- flutter_dotenv — إعدادات البيئة (.env)
- equatable — مقارنة الحالات في Bloc
- bloc_test + mocktail — اختبارات (dev)

**Backend (مستودع منفصل — راجع روابط المشروع):**
- API مستضاف على Render: `https://charging-api-tkne.onrender.com/api`
- المصادقة: Firebase Auth (Bearer ID Token يُتحقق منه بكل طلب)

## المعمارية

بنية طبقية بسيطة (Layered Architecture) داخل Flutter:

```
lib/
├── main.dart                 # نقطة الدخول: تحميل .env، تهيئة Firebase، MultiBlocProvider
├── app_router.dart           # كل الـ Routes (onGenerateRoute)
│
├── data/
│   ├── network/
│   │   ├── api_client.dart       # نقطة اتصال HTTP موحّدة (baseUrl واحد، معالجة أخطاء موحّدة)
│   │   └── api_exceptions.dart   # NetworkException / UnauthorizedException / ValidationException ...
│   └── Models/                   # نماذج بيانات (Product, DeviceModel)
│
├── logic/                    # Cubits (State Management) — كل ميزة بمجلدها
│   ├── auth_cubit/
│   ├── customers/
│   ├── dashboard/
│   ├── devices/
│   ├── products/
│   ├── shelves/
│   ├── transactions/
│   └── balance/               # BalanceCalculator — منطق نقي (Pure Dart) قابل للاختبار بمعزل عن الواجهة
│
├── presentation/screens/     # الشاشات، مقسّمة حسب الميزة (auth, debt, devices, history, ...)
│
├── widgets/                  # مكوّنات مشتركة (DepositDialog, BottomSheets, ...)
└── utils/                    # الثيم وأدوات مساعدة عامة
```

**تدفق البيانات:**
Screen (UI) → يستدعي Cubit → Cubit يستدعي ApiClient → ApiClient يرفق توكن Firebase ويتحقق من statusCode قبل فك الـ JSON → يرمي استثناء مصنّف (ApiException الفرعي المناسب) عند الفشل → Cubit يلتقطه ويحوّله لـ State مناسب → Screen يعيد البناء عبر BlocBuilder/BlocConsumer.

منطق الحسابات المالية (الدين، الرصيد، الدفع الجزئي، تسوية الدين) مفصول بالكامل في `lib/logic/balance/balance_calculator.dart` — Pure Dart بدون أي اعتماد على Flutter أو الشبكة، مما يجعله قابلاً للاختبار مباشرة (راجع `test/logic/balance_calculator_test.dart`).

## المتطلبات (Prerequisites)

- Flutter SDK (قناة stable، تتوافق مع Dart ^3.10.7)
- حساب Firebase مع مشروع مفعّل عليه Authentication (Email/Password + Google Sign-In)
- ملف `google-services.json` (Android) و/أو `GoogleService-Info.plist` (iOS) من نفس مشروع Firebase
- اتصال بمستودع الباك اند (شغّال أو محلي) — راجع روابط المشروع

## خطوات التشغيل

```bash
# 1) استنساخ المستودع
git clone https://github.com/Hussenghbayen/testcharge.git
cd testcharge

# 2) تثبيت الحزم
flutter pub get

# 3) إعداد متغيرات البيئة (راجع القسم التالي)
cp .env.example .env
# ثم عدّل .env وحط القيم الحقيقية

# 4) إعداد Firebase (راجع القسم التالي) — google-services.json / GoogleService-Info.plist

# 5) التشغيل
flutter run
```

## إعداد Firebase

1. أنشئ مشروع على Firebase Console
2. فعّل Authentication → طرق تسجيل الدخول: Email/Password و Google
3. **Android**: أضف تطبيق Android بنفس `applicationId` الموجود في `android/app/build.gradle.kts`، وحمّل `google-services.json` وضعه في `android/app/`
4. **iOS**: أضف تطبيق iOS بنفس Bundle ID الموجود في `ios/Runner.xcodeproj`، وحمّل `GoogleService-Info.plist` وضعه في `ios/Runner/`
5. من إعدادات المشروع (Project Settings → General) انسخ Web API Key وضعه في `.env` تحت `FIREBASE_WEB_API_KEY`

> لا تعدّل أو ترفع `google-services.json` / `GoogleService-Info.plist` الحقيقيين على GitHub إذا كان المستودع عاماً وفيه بيانات حساسة إضافية غير مفاتيح Firebase العامة.

## إعداد الـ API / متغيرات البيئة

انسخ `.env.example` إلى `.env` (الملف الأخير مستثنى من Git عبر `.gitignore`):

```
API_BASE_URL=https://charging-api-tkne.onrender.com/api
FIREBASE_WEB_API_KEY=REPLACE_WITH_YOUR_FIREBASE_WEB_API_KEY
```

كل طلبات الشبكة بالتطبيق تمر عبر نقطة اتصال واحدة `lib/data/network/api_client.dart`، وترفق تلقائياً `Authorization: Bearer <Firebase ID Token>` مع كل طلب محمي.

## تشغيل الاختبارات

```bash
flutter test
```

الاختبارات الموجودة حالياً في `test/logic/`:

| الملف | يغطي |
|---|---|
| `balance_calculator_test.dart` | حساب الدين/الرصيد، الدفع الجزئي، تسوية الدين (كامل/جزئي/زائد)، رفض القيم السالبة والصفرية |
| `customers_cubit_test.dart` | أن `payDebt` يرفض المبالغ غير الصالحة قبل أي محاولة اتصال بالسيرفر |
| `api_client_test.dart` | تمييز 401/403/أخطاء الشبكة/أخطاء التحقق عن بعضها، وعدم انهيار التطبيق عند استجابة غير-JSON |

> ملاحظة: عزل بيانات المحلات (منع عميل من رؤية بيانات محل تاني) هو مسؤولية الـ backend (owner_id من التوكن) بشكل أساسي — راجع `docs/database-schema.md`. اختبارات الفرونت اند هنا تتأكد فقط أن كل طلب يرفق التوكن الصحيح، وهو الأساس الذي يعتمد عليه عزل الباك اند.

## مستندات إضافية

- **Postman Collection**: `docs/TestCharge.postman_collection.json` — يغطي كل نقاط الـ API التي يستهلكها التطبيق فعلياً (المصادقة، Dashboard، العملاء والدفعات، المنتجات، العمليات، الرفوف). استورده في Postman، عبّي متغير `firebase_web_api_key`، نفّذ طلب Login، وانسخ `idToken` الناتج لمتغير `firebase_id_token`.
- **مخطط قاعدة البيانات**: `docs/database-schema.md` — مخطط ERD (Mermaid) مُستنتَج من عقود الـ API الفعلية، مع توضيح قاعدة العزل بين المحلات (owner_id) التي يجب أن يفرضها الباك اند.

## صور من التطبيق

| تسجيل الدخول | الرئيسية | كشف حساب عميل |
|---|---|---|
| ![login](docs/screenshots/login.png) | ![home](docs/screenshots/home.png) | ![customer](docs/screenshots/customer.png) |

فيديو عرض توضيحي: https://youtu.be/iguguW1MXZ4

## بناء التطبيق (Release Build)

```bash
# Android — APK
flutter build apk --release
# الناتج: build/app/outputs/flutter-apk/app-release.apk

# Android — App Bundle (لرفعه على Google Play)
flutter build appbundle --release

# iOS (يتطلب macOS + Xcode + حساب Apple Developer)
flutter build ipa --release
```

## روابط المشروع

| العنصر | الرابط |
|---|---|
| مستودع الباك اند | _يُضاف رابط مستودع الباك اند الفعلي هنا_ |
| الباك اند (بيئة التشغيل) | https://charging-api-tkne.onrender.com |
| تقرير التخرج (PDF) | [docs/report.pdf](docs/report.pdf) |
| تقرير التخرج (DOCX) | [docs/report.docx](docs/report.docx) |
| ملف Figma | https://www.figma.com/design/z7EdLLqHxaxUXPiHqY20FK/Untitled |
