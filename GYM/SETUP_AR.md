# تشغيل الـ Backend بتاع FitBody

الـ backend فيه 3 functions:
- `sendVerificationCode`: يبعت كود 6 أرقام على إيميل المستخدم
- `verifyCode`: يتأكد من الكود ويفعّل الإيميل في Firebase
- `analyzeInBody`: يقرأ صور/PDF التقرير بالـ AI ويطلع خطة تمرين وأكل (5-7 تمارين لكل يوم، 4-5 وجبات)

مفاتيح الـ APIs (Gmail و Claude) بتتخزن على السيرفر كـ Secrets، مش جوه التطبيق.

## المطلوب قبل ما تبدأ
1. خطة **Blaze** في Firebase (Functions مش بتشتغل على Spark). لازم كارت دفع. فعّل Budget alert (مثلاً 5$).
2. **Node 22**: من nodejs.org أو `brew install node`
3. **App Password** من حساب Gmail اللي هيبعت الأكواد: Google Account > Security > 2-Step Verification (لازم يكون شغال) > App passwords > اعمل واحد اسمه FitBody (16 حرف).
4. **مفتاح Claude جديد** من console.anthropic.com وانسخه فوراً وقت الإنشاء (بيظهر مرة واحدة). وامسح المفاتيح القديمة اللي اتبعتت في المحادثات.
5. **Firestore**: Firebase Console > Build > Firestore Database > Create database.

## الأوامر (Terminal)
```bash
npm install -g firebase-tools
firebase login
cd fitbody-backend/functions && npm install && cd ..

firebase functions:secrets:set GMAIL_USER          # إيميل Gmail اللي هيبعت
firebase functions:secrets:set GMAIL_APP_PASSWORD  # الـ 16 حرف
firebase functions:secrets:set ANTHROPIC_API_KEY   # مفتاح Claude الجديد

firebase deploy --only functions,firestore:rules
```
اكتب القيم لما الـ Terminal يسألك. ما تكتبهاش في أي ملف ولا تبعتها في شات.

## بعد الـ deploy
- لو الـ URL اللي اتطبع للـ functions مختلف عن `https://us-central1-fitbody-55288.cloudfunctions.net` غيّر `functionsBase` في `FirebaseAuthService.swift`.
- الاختبارات: `cd functions && npm test` (16 اختبار، بدون إنترنت).

## حدود الأمان المدمجة
- الكود: صالح 10 دقايق، كود واحد كل 60 ثانية، 5 أكواد في الساعة، 5 محاولات غلط ويتحرق.
- التحليل: 10 تحليلات في اليوم لكل مستخدم (غيّر `MAX_ANALYSES_PER_DAY` في index.js).
- Gmail العادي بيبعت لحد حوالي 500 إيميل في اليوم. لو التطبيق كبر استخدم خدمة إيميل مخصصة بدومين.
