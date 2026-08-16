TestCharge — تطبيق إدارة محلات شحن الأجهزة ومبيعاتها
تطبيق Flutter لإدارة محلات شحن الهواتف/الأجهزة المحمولة: تسجيل عمليات الشحن والبيع،
متابعة الرفوف (الشيلفات) المشغولة، إدارة ديون وأرصدة العملاء، وتقارير الدخل اليومية/الأسبوعية/الشهرية.
الباك اند منفصل ومستضاف على Render، والمصادقة عبر Firebase Auth.
> ⚠️ **حالة المشروع:** هذا README مكتوب أثناء معالجة ملاحظات مناقشة التخرج (راجع قسم
> [التغييرات مقابل ملاحظات المناقشة](#التغييرات-مقابل-ملاحظات-المناقشة) بالأسفل). بعض الروابط
> (الباك اند، Figma، التقرير) لسا placeholders لازم الفريق يعبّيها قبل التسليم النهائي.
---
المشكلة
أصحاب محلات شحن الأجهزة المحمولة (وبيع الإكسسوارات المرافقة) كانوا يعتمدون على دفاتر ورقية
أو تطبيقات عامة غير متخصصة لتتبّع:
أي جهاز موجود على أي رف، ومتى استُلم، ومتى يجب تسليمه
كم بقي على كل عميل من دين، وكم دفع، ومتى
الدخل اليومي/الأسبوعي/الشهري من الشحن مقابل البيع المباشر
هذا يؤدي لأخطاء حسابية، ضياع سجلات، وصعوبة في معرفة الوضع المالي للمحل لحظياً.
TestCharge يحل هذا بتطبيق موبايل مخصص لهذا النوع من المحلات تحديداً.
---
أعضاء الفريق وأدوارهم
> ⚠️ **يُرجى تعبئة هذا الجدول بأسماء وأدوار الفريق الحقيقية قبل التسليم.**
> كل عضو من المفترض يشرح بالمناقشة الجزء من الكود الذي نفّذه فعلياً، لذلك الجدول
> يجب أن يعكس المساهمة الحقيقية لكل شخص (راجع قسم [تاريخ التطوير](#تاريخ-التطوير-و-git) بالأسفل).
الاسم	الدور	الأجزاء المسؤول عنها
(اسم العضو 1)	Flutter / Frontend	مثال: شاشات المصادقة، Router
(اسم العضو 2)	Flutter / State Management	مثال: Cubits، ApiClient
(اسم العضو 3)	Backend	مثال: API، قاعدة البيانات، صلاحيات الوصول
(اسم العضو 4)	UI/UX + اختبارات	مثال: Figma، الاختبارات الآلية
---
التقنيات المستخدمة
Frontend (هذا المستودع):
Flutter 3.x / Dart — SDK: `^3.10.7`
flutter_bloc (Cubit) — إدارة الحالة
http — طبقة الاتصال بالشبكة (موحّدة عبر `ApiClient`)
firebase_auth + firebase_core — المصادقة
google_sign_in — تسجيل دخول بحساب Google
flutter_dotenv — إعدادات البيئة (`.env`)
equatable — مقارنة الحالات في Bloc
bloc_test + mocktail — اختبارات (dev)
Backend (مستودع منفصل — راجع روابط المشروع):
API مستضاف على Render: `https://charging-api-tkne.onrender.com/api`
المصادقة: Firebase Auth (Bearer ID Token يُتحقق منه بكل طلب)
---
المعمارية
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
│   └── balance/              # BalanceCalculator — منطق نقي (Pure Dart) قابل للاختبار بمعزل عن الواجهة
│
├── presentation/screens/     # الشاشات، مقسّمة حسب الميزة (auth, debt, devices, history, ...)
│
├── widgets/                  # مكوّنات مشتركة (DepositDialog, BottomSheets, ...)
└── utils/                    # الثيم وأدوات مساعدة عامة
```
تدفق البيانات:
`Screen (UI)` → يستدعي `Cubit` → `Cubit` يستدعي `ApiClient` → `ApiClient` يرفق توكن Firebase
ويتحقق من `statusCode` قبل فك الـ JSON → يرمي استثناء مصنّف (`ApiException` الفرعي المناسب) عند الفشل
→ `Cubit` يلتقطه ويحوّله لـ `State` مناسب → `Screen` يعيد البناء عبر `BlocBuilder/BlocConsumer`.
منطق الحسابات المالية (الدين، الرصيد، الدفع الجزئي، تسوية الدين) مفصول بالكامل في
`lib/logic/balance/balance_calculator.dart` — Pure Dart بدون أي اعتماد على Flutter أو الشبكة،
مما يجعله قابلاً للاختبار مباشرة (راجع `test/logic/balance_calculator_test.dart`).
---
المتطلبات (Prerequisites)
Flutter SDK (قناة stable، تتوافق مع Dart `^3.10.7`)
حساب Firebase مع مشروع مفعّل عليه Authentication (Email/Password + Google Sign-In)
ملف `google-services.json` (Android) و/أو `GoogleService-Info.plist` (iOS) من نفس مشروع Firebase
اتصال بمستودع الباك اند (شغّال أو محلي) — راجع روابط المشروع
---
خطوات التشغيل
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
---
إعداد Firebase
أنشئ مشروع على Firebase Console
فعّل Authentication → طرق تسجيل الدخول: Email/Password و Google
Android: أضف تطبيق Android بنفس `applicationId` الموجود في
`android/app/build.gradle.kts`، وحمّل `google-services.json` وضعه في `android/app/`
iOS: أضف تطبيق iOS بنفس Bundle ID الموجود في `ios/Runner.xcodeproj`، وحمّل
`GoogleService-Info.plist` وضعه في `ios/Runner/`
من إعدادات المشروع (Project Settings → General) انسخ Web API Key وضعه في
`.env` تحت `FIREBASE_WEB_API_KEY` (يُستخدم فقط من واجهة Flutter، وهو مفتاح عام
حسب توثيق Firebase وليس سرّاً حساساً — لكن نخليه بمتغير بيئة بدل تثبيته بالكود)
> **لا تعدّل أو ترفع** `google-services.json` / `GoogleService-Info.plist` الحقيقيين على GitHub
> إذا كان المستودع عاماً وفيه بيانات حساسة إضافية غير مفاتيح Firebase العامة.
---
إعداد الـ API / متغيرات البيئة
انسخ `.env.example` إلى `.env` (الملف الأخير مستثنى من Git عبر `.gitignore`):
```env
API_BASE_URL=https://charging-api-tkne.onrender.com/api
FIREBASE_WEB_API_KEY=REPLACE_WITH_YOUR_FIREBASE_WEB_API_KEY
```
كل طلبات الشبكة بالتطبيق تمر عبر نقطة اتصال واحدة `lib/data/network/api_client.dart`
(بدل تكرار الرابط بعدة ملفات)، وترفق تلقائياً `Authorization: Bearer <Firebase ID Token>`
مع كل طلب محمي.
---
تشغيل الاختبارات
```bash
flutter test
```
الاختبارات الموجودة حالياً في `test/logic/`:
الملف	يغطي
`balance_calculator_test.dart`	حساب الدين/الرصيد، الدفع الجزئي، تسوية الدين (كامل/جزئي/زائد)، رفض القيم السالبة والصفرية
`customers_cubit_test.dart`	أن `payDebt` يرفض المبالغ غير الصالحة قبل أي محاولة اتصال بالسيرفر
`api_client_test.dart`	تمييز 401/403/أخطاء الشبكة/أخطاء التحقق عن بعضها، وعدم انهيار التطبيق عند استجابة غير-JSON
> ملاحظة: عزل بيانات المحلات (منع عميل من رؤية بيانات محل تاني) هو مسؤولية الـ **backend**
> (owner_id من التوكن) بشكل أساسي — راجع `docs/database-schema.md`. اختبارات الفرونت اند هنا
> تتأكد فقط أن كل طلب يرفق التوكن الصحيح، وهو الأساس الذي يعتمد عليه عزل الباك اند.
---
Postman Collection
`docs/TestCharge.postman_collection.json` — يغطي كل نقاط الـ API التي يستهلكها التطبيق فعلياً
(المصادقة، Dashboard، العملاء والدفعات، المنتجات، العمليات، الرفوف). استورده في Postman،
عبّي متغير `firebase_web_api_key`، نفّذ طلب Login، وانسخ `idToken` الناتج لمتغير `firebase_id_token`.
مخطط قاعدة البيانات
`docs/database-schema.md` — مخطط ERD (Mermaid) مُستنتَج من عقود الـ API الفعلية (بما أن
الباك اند بمستودع منفصل)، مع توضيح قاعدة العزل بين المحلات (`owner_id`) التي يجب أن يفرضها الباك اند.
تصميم الواجهات (Figma)
> ⚠️ ضيفوا هون رابط ملف Figma الفعلي (View/Share link)، أو صدّروا نسخة PDF/صور وحطوها بـ `docs/design/`.
---
صور من التطبيق
> ⚠️ ضيفوا هون سكرين شوتس فعلية من التطبيق (مثلاً بمجلد `docs/screenshots/`) بصيغة:
>
> ```markdown
> | تسجيل الدخول | الرئيسية | كشف حساب عميل |
> |---|---|---|
> | ![login](docs/screenshots/login.png) | ![home](docs/screenshots/home.png) | ![customer](docs/screenshots/customer.png) |
> ```
---
بناء التطبيق (Release Build)
```bash
# Android — APK
flutter build apk --release
# الناتج: build/app/outputs/flutter-apk/app-release.apk

# Android — App Bundle (لرفعه على Google Play)
flutter build appbundle --release

# iOS (يتطلب macOS + Xcode + حساب Apple Developer)
flutter build ipa --release
```
APK الإصدار المستقر يُرفع تحت GitHub Releases لهذا المستودع.
---
روابط المشروع
العنصر	الرابط
مستودع الباك اند	⚠️ أضيفوا الرابط هون
الباك اند (بيئة التشغيل)	`https://charging-api-tkne.onrender.com`
تقرير التخرج (PDF/Doc)	⚠️ أضيفوا الرابط هون
ملف Figma	⚠️ أضيفوا الرابط هون
---
تاريخ التطوير و Git
> ⚠️ **ملاحظة صراحة:** تاريخ الـ commits الحالي في هذا المستودع لا يعكس تاريخ التطوير الفعلي
> (المستودع رُفع بـ commit واحد). إذا كان التطوير الفعلي موثّقاً بمكان آخر (مستودع محلي، فرع قديم،
> نسخة احتياطية)، يُرجى دفعه هنا بتاريخه الحقيقي (`git push` بفروع/commits منفصلة لكل عضو)
> **قبل** تسليم التقرير النهائي، أو تصحيح وصف استخدام Git في التقرير ليعكس الواقع بدل الادعاء
> بسير عمل تدريجي لم يحدث. هذا ضروري لتقييم المساهمة الفردية في المناقشة.
---
التغييرات مقابل ملاحظات المناقشة
ملخص أهم ما عولج في هذه المرحلة استجابة لملاحظات الدكتور:
[x] استبدال قالب README الافتراضي بهذا الملف
[x] توحيد الاتصال بالشبكة في `ApiClient` واحد بدل تكرار الرابط بـ 11 ملفاً
[x] التحقق من `statusCode` قبل `jsonDecode`، وتمييز خطأ الشبكة عن 401 عن أخطاء التحقق
[x] حذف ملفات المصادقة القديمة والروابط الوهمية (`your-api.com`)
[x] توحيد Deposit Dialog باستخدام widget واحد بدل 3 نسخ مكررة
[x] رفض القيم السالبة/الصفرية عند الإيداع (بالواجهة + بالـ Cubit)
[x] إضافة اختبارات آلية فعلية (كانت `test/` فاضية من اختبارات حقيقية)
[x] إصلاح خط Tajawal في `pubspec.yaml` (كان مُستخدَماً بالكود بدون تعريف)
[x] ضغط الصور في `assets/` (~14MB → ~3.5MB)
[x] إضافة `.env.example`, Postman collection, مخطط قاعدة بيانات مُستنتَج
[ ] إصلاح التحقق من ملكية العميل في الـ backend (owner_id من التوكن) — يتطلب الوصول
لمستودع الباك اند، غير متاح وقت كتابة هذا الملف
[ ] تصحيح/توثيق تاريخ Git الحقيقي — قرار يعود للفريق
[ ] تعبئة أسماء الفريق، روابط Figma/الباك اند/التقرير أعلاه
