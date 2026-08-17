# TestCharge

نظام موبايل لإدارة محلات شحن الأجهزة المحمولة — يساعد أصحاب المحلات على متابعة عمليات الشحن،
الرفوف المشغولة، المبيعات، ديون العملاء، الدفعات، والتقارير المالية من تطبيق واحد.

**مشروع تخرج** — الجامعة الإسلامية بغزة، كلية تكنولوجيا المعلومات، تخصص الحوسبة المتنقلة وتطبيقات
الأجهزة الذكية.
المشرف/المناقش: د. رائد بلبل.

---

## Demo Video و APK

- فيديو عرض توضيحي: https://youtu.be/iguguW1MXZ4
- تحميل آخر نسخة APK: من [GitHub Releases](../../releases) لهذا المستودع

---

## Problem Statement

بعض محلات شحن الأجهزة المحمولة الصغيرة تعتمد على التسجيل الورقي أو حلول عامة غير متخصصة لمتابعة:

- أي جهاز موجود على أي رف، ومتى استُلم، ومتى يجب تسليمه
- ديون العملاء والدفعات الجزئية
- الدخل اليومي/الأسبوعي/الشهري من الشحن مقابل البيع المباشر

هذا النوع من الحلول يزيد احتمال الأخطاء الحسابية وضياع السجلات، ويصعّب معرفة الوضع المالي للمحل
لحظياً. *(ملاحظة: هذا وصف لمشكلة شائعة في هذا النوع من المحلات بناءً على الملاحظة العامة للفريق،
وليس نتيجة استبيان أو مقابلات ميدانية موثّقة رسمياً — إذا أُجريت مقابلات فعلية مع أصحاب محلات، يجب
ذكر ذلك هنا وبالتقرير مع تفاصيلها.)*

## Proposed Solution

**TestCharge** تطبيق موبايل مخصص لهذا النوع من المحلات تحديداً، يوفّر:

- تسجيل عمليات شحن الأجهزة ومتابعة حالتها (قيد الشحن / تم التسليم)
- إدارة الرفوف (الشيلفات) وربط كل جهاز برف مشغول
- تسجيل عمليات البيع المباشر للمنتجات والإكسسوارات
- إدارة ديون العملاء: تسجيل الدين، الدفعات الجزئية، تسوية الدين
- تقارير دخل يومية/أسبوعية/شهرية تفصل بين دخل الشحن ودخل البيع
- تسجيل دخول آمن عبر Firebase (Email/Password أو Google)

---



## System Architecture

```
Flutter UI
    ↓
Cubit / State Management   (flutter_bloc)
    ↓
Data / API Layer            (ApiClient — نقطة اتصال HTTP موحّدة)
    ↓
REST API                    (Backend منفصل، Node/Express على Render)
    ↓
Database
```

كل الوصول للبيانات معزول حسب المحل (`owner_id` مستخرج من Firebase ID Token يتحقق منه الباك اند
بكل طلب — راجع `docs/database-schema.md`). التفاصيل الكاملة لتدفق البيانات موجودة بـ
[`docs/architecture.md`](docs/architecture.md).

---

## Tech Stack

- **Flutter / Dart** — الواجهة
- **Firebase Authentication** — تسجيل الدخول (Email/Password + Google)
- **Flutter Bloc / Cubit** — إدارة الحالة
- **REST API** (HTTP) — الاتصال بالباك اند، موحّد عبر `ApiClient` واحد
- **Render** — استضافة الباك اند

<details>
<summary>حزم إضافية (تفاصيل تقنية)</summary>

- `flutter_dotenv` — إعدادات البيئة (`.env`)
- `equatable` — مقارنة حالات Bloc
- `bloc_test` + `mocktail` — اختبارات (dev)

</details>

---

## Project Structure

```
lib/
├── main.dart              # نقطة الدخول
├── app_router.dart        # كل الـ Routes
├── data/network/          # ApiClient موحّد + الاستثناءات المصنّفة
├── data/Models/           # نماذج البيانات
├── logic/                 # Cubits لكل ميزة + BalanceCalculator (منطق نقي قابل للاختبار)
├── presentation/screens/  # الشاشات حسب الميزة
├── widgets/                # مكوّنات مشتركة (DepositDialog, ...)
└── utils/                  # الثيم وأدوات عامة
```

تفاصيل أكثر (تدفق البيانات خطوة بخطوة): [`docs/architecture.md`](docs/architecture.md)

---

## Backend / API

- الباك اند مستودع منفصل: https://github.com/MohammEdeyad2001/Final-report-.git
- بيئة التشغيل (Render): `https://charging-api-tkne.onrender.com/api`
- المصادقة: Firebase Auth — كل طلب محمي يحمل `Authorization: Bearer <Firebase ID Token>`
- توثيق كامل لنقاط الـ API: [`docs/TestCharge.postman_collection.json`](docs/TestCharge.postman_collection.json) (Postman)
- مخطط قاعدة بيانات مُستنتَج من عقود الـ API: [`docs/database-schema.md`](docs/database-schema.md)

---

## Installation

# 1) استنساخ المستودع
git clone https://github.com/Hussenghbayen/testcharge.git
cd testcharge

# 2) تثبيت الحزم
flutter pub get

# 3) إعداد متغيرات البيئة (راجع القسم التالي)
cp .env.example .env

# 4) إعداد Firebase — راجع القسم التالي

# 5) التشغيل
flutter run
```

### إعداد Firebase

1. أنشئ مشروع على [Firebase Console](https://console.firebase.google.com/)
2. فعّل **Authentication** → Email/Password و Google
3. **Android**: أضف تطبيق بنفس `applicationId` من `android/app/build.gradle.kts`، حمّل
   `google-services.json` وضعه في `android/app/`
4. **iOS**: أضف تطبيق بنفس Bundle ID من `ios/Runner.xcodeproj`، حمّل `GoogleService-Info.plist`
   وضعه في `ios/Runner/`

> لا تعدّل/ترفع الملفين الحقيقيين على GitHub إذا كان المستودع عاماً.

### Building the App

```bash
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android App Bundle (Google Play)
flutter build ipa --release        # iOS (يتطلب macOS + Xcode)
```

---

## Environment Variables

انسخ `.env.example` إلى `.env` (مستثنى من Git):

```env
API_BASE_URL=https://charging-api-tkne.onrender.com/api
FIREBASE_WEB_API_KEY=REPLACE_WITH_YOUR_FIREBASE_WEB_API_KEY
```

---

## Testing

flutter test
```

| الملف | يغطي |
|---|---|
| `test/logic/balance_calculator_test.dart` | حساب الدين/الرصيد، الدفع الجزئي، تسوية الدين، رفض القيم السالبة/الصفرية |
| `test/logic/customers_cubit_test.dart` | `payDebt` يرفض المبالغ غير الصالحة قبل أي اتصال بالسيرفر |
| `test/logic/api_client_test.dart` | تمييز 401/403/أخطاء الشبكة/أخطاء التحقق عن بعضها |

عزل بيانات المحلات هو مسؤولية الـ backend أساساً (`owner_id` من التوكن) — راجع `docs/database-schema.md`.

---

## Team Members

| الاسم | الدور |
|---|---|
| حسين عزات حسين غباين | Flutter (Frontend + State Management: شاشات، Router، Cubits، ApiClient) |
| محمود ماضي | Backend (API، قاعدة البيانات، صلاحيات الوصول) |
| محمد مهدي | UI/UX + اختبارات (Figma، الاختبارات الآلية) |

---

## Project Documentation

| العنصر | الرابط |
|---|---|
| تقرير التخرج | ⚠️لملف هنا_ |
| ملف Figma | https://www.figma.com/design/z7EdLLqHxaxUXPiHqY20FK/Untitled |
| Postman Collection | [`docs/TestCharge.postman_collection.json`](docs/TestCharge.postman_collection.json) |
| مخطط قاعدة البيانات | [`docs/database-schema.md`](docs/database-schema.md) |
| المعمارية التفصيلية | [`docs/architecture.md`](docs/architecture.md) |

---

## Limitations

- تحقق ملكية العميل بالباك اند (`owner_id` من التوكن) قيد المعالجة — راجع قسم Git والتغييرات بالأسفل.
- لا توجد اختبارات end-to-end/واجهة (Widget/Integration Tests)، فقط اختبارات منطق (Unit Tests).
- لا يدعم التطبيق حالياً العمل بدون اتصال إنترنت (Offline mode).

## Future Work

- إضافة اختبارات Widget/Integration للشاشات الرئيسية
- دعم أوضاع دفع/عملات متعددة
- تحسين الأداء عند عدد كبير من العملاء/العمليات (Pagination)

## License

## ملاحظة حول تاريخ Git

المستودع يحتوي حالياً commits منفصلة توثّق مراحل معالجة ملاحظات المناقشة، لكن التاريخ الكامل
للتطوير الأصلي (قبل هذه المرحلة) رُفع بـ commit واحد. إذا كان تاريخ التطوير الفعلي موثّقاً بمكان آخر
(مستودع محلي/فرع قديم)، يُفضّل الإشارة له بالتقرير، أو توضيح أن سير العمل بالفريق لم يعتمد على Git
بشكل تدريجي أثناء التطوير الأساسي.
