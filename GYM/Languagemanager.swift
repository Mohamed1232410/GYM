//
//  Languagemanager.swift
//  GYM
//
//  Created by Mohamed ahmed on 23/05/2026.
//



import SwiftUI
import Combine

// MARK: - Language Manager
class LanguageManager: ObservableObject {
    @Published var isArabic: Bool

    var layoutDirection: LayoutDirection { isArabic ? .rightToLeft : .leftToRight }
    var locale: Locale { isArabic ? Locale(identifier: "ar") : Locale(identifier: "en") }

    init() {
        self.isArabic = UserDefaults.standard.bool(forKey: "appLanguageArabic")
    }

    func toggle() {
        isArabic.toggle()
        UserDefaults.standard.set(isArabic, forKey: "appLanguageArabic")
    }

    func t(_ key: LocalizationKey) -> String {
        isArabic ? key.arabic : key.english
    }
}

// MARK: - All App Strings
enum LocalizationKey {
    // Onboarding
    case welcomeTitle
    case welcomeSubtitle
    case letsGetStarted
    case aboutYou
    case aboutYouSubtitle
    case yourName
    case age
    case weight
    case height
    case years
    case yourGoal
    case whatToAchieve
    case dietaryPreference
    case customizeMealPlan
    case letsGo
    case continueText

    // Goals
    case loseWeight
    case buildMuscle
    case improveEndurance
    case stayFit

    // Activity
    case sedentary
    case lightlyActive
    case moderatelyActive
    case veryActive
    case extraActive

    // Diet
    case standard
    case vegetarian
    case vegan
    case keto
    case paleo

    // Home
    case goodMorning
    case goodAfternoon
    case goodEvening
    case athlete
    case todaysWorkout
    case restDay
    case recoveryKey
    case exercises
    case min
    case todaysCalories
    case weekStreak
    case keepItUp

    // Workouts
    case workouts
    case activePlan
    case weeks
    case daysPerWeek
    case exerciseLibrary
    case startThisPlan
    case currentPlan
    case howToPerform
    case proTip
    case sets
    case reps
    case rest
    case muscles
    case equipment
    case startWorkout
    case finishWorkout
    case cancelWorkout
    case previous
    case next
    case finish
    case finishWorkoutQ
    case greatWork

    // Diet
    case diet
    case chooseMealPlan
    case logged
    case markAsEaten
    case ingredients
    case preparation
    case prepTime
    case protein
    case carbs
    case fats
    case kcalDay
    case todayConsumed

    // Progress
    case progress
    case totalWorkouts
    case hoursTrained
    case caloriesBurned
    case weeklyStreak
    case last7Days
    case weightProgress
    case recentSessions
    case noSessionsYet
    case logMeasurement
    case logBodyMeasurement
    case bodyWeight
    case optional
    case sessions
    case hours

    // Profile
    case profile
    case edit
    case bodyStats
    case bmi
    case dailyCalories
    case fitnessProfile
    case goal
    case activityLevel
    case dietPreference
    case subscription
    case manageSub
    case restorePurchases
    case appInfo
    case version
    case privacyPolicy
    case termsOfService
    case logOut
    case logOutTitle
    case logOutMessage
    case logOutConfirm
    case cancel
    case save
    case editProfile
    case personalInfo

    // Paywall
    case unlockFitPro
    case fitnessCompanion
    case allWorkoutPlans
    case personalizedDietPlans
    case exerciseLibraryFull
    case progressTracking
    case activeWorkoutTracker
    case bodyMeasurements
    case monthly
    case quarterly
    case annual
    case billedMonthly
    case billedQuarterly
    case billedAnnually
    case save17
    case save50
    case startPlan
    case legalText

    // Language
    case language
    case switchLanguage
    case english
    case arabic

    var english: String {
        switch self {
        case .welcomeTitle: return "Welcome to FitPro"
        case .welcomeSubtitle: return "Your personalized fitness journey starts here. We'll set up your profile so you get the best experience."
        case .letsGetStarted: return "Let's Get Started"
        case .aboutYou: return "About You"
        case .aboutYouSubtitle: return "Help us personalize your experience"
        case .yourName: return "Your name"
        case .age: return "Age"
        case .weight: return "Weight"
        case .height: return "Height"
        case .years: return "years"
        case .yourGoal: return "Your Goal"
        case .whatToAchieve: return "What do you want to achieve?"
        case .dietaryPreference: return "Dietary Preference"
        case .customizeMealPlan: return "We'll customize your meal plan"
        case .letsGo: return "Let's Go! 🚀"
        case .continueText: return "Continue"
        case .loseWeight: return "Lose Weight"
        case .buildMuscle: return "Build Muscle"
        case .improveEndurance: return "Improve Endurance"
        case .stayFit: return "Stay Fit"
        case .sedentary: return "Sedentary"
        case .lightlyActive: return "Lightly Active"
        case .moderatelyActive: return "Moderately Active"
        case .veryActive: return "Very Active"
        case .extraActive: return "Extra Active"
        case .standard: return "Standard"
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .keto: return "Keto"
        case .paleo: return "Paleo"
        case .goodMorning: return "Good Morning"
        case .goodAfternoon: return "Good Afternoon"
        case .goodEvening: return "Good Evening"
        case .athlete: return "Athlete"
        case .todaysWorkout: return "Today's Workout"
        case .restDay: return "Rest Day"
        case .recoveryKey: return "Recovery is key to progress"
        case .exercises: return "exercises"
        case .min: return "min"
        case .todaysCalories: return "Today's Calories"
        case .weekStreak: return "Week Streak"
        case .keepItUp: return "Keep it up! Don't break the chain."
        case .workouts: return "Workouts"
        case .activePlan: return "Active Plan"
        case .weeks: return "weeks"
        case .daysPerWeek: return "days/week"
        case .exerciseLibrary: return "Exercise Library"
        case .startThisPlan: return "Start This Plan"
        case .currentPlan: return "Current Plan"
        case .howToPerform: return "How To Perform"
        case .proTip: return "Pro Tip"
        case .sets: return "Sets"
        case .reps: return "Reps"
        case .rest: return "Rest"
        case .muscles: return "Muscles Targeted"
        case .equipment: return "Equipment"
        case .startWorkout: return "Start Workout"
        case .finishWorkout: return "Finish Workout"
        case .cancelWorkout: return "Cancel"
        case .previous: return "Previous"
        case .next: return "Next"
        case .finish: return "Finish"
        case .finishWorkoutQ: return "Finish Workout?"
        case .greatWork: return "Great work! Save this workout session?"
        case .diet: return "Diet"
        case .chooseMealPlan: return "Choose Meal Plan"
        case .logged: return "Logged"
        case .markAsEaten: return "Mark as Eaten"
        case .ingredients: return "Ingredients"
        case .preparation: return "Preparation"
        case .prepTime: return "Prep"
        case .protein: return "Protein"
        case .carbs: return "Carbs"
        case .fats: return "Fats"
        case .kcalDay: return "kcal/day"
        case .todayConsumed: return "Today's consumed"
        case .progress: return "Progress"
        case .totalWorkouts: return "Total Workouts"
        case .hoursTrained: return "Hours Trained"
        case .caloriesBurned: return "Calories Burned"
        case .weeklyStreak: return "Weekly Streak"
        case .last7Days: return "Last 7 Days"
        case .weightProgress: return "Weight Progress"
        case .recentSessions: return "Recent Sessions"
        case .noSessionsYet: return "No sessions yet. Complete a workout to see stats."
        case .logMeasurement: return "Log Measurement"
        case .logBodyMeasurement: return "Log Body Measurement"
        case .bodyWeight: return "Body Weight"
        case .optional: return "Optional"
        case .sessions: return "sessions"
        case .hours: return "hours"
        case .profile: return "Profile"
        case .edit: return "Edit"
        case .bodyStats: return "Body Stats"
        case .bmi: return "BMI"
        case .dailyCalories: return "Daily Calories"
        case .fitnessProfile: return "Fitness Profile"
        case .goal: return "Goal"
        case .activityLevel: return "Activity Level"
        case .dietPreference: return "Diet Preference"
        case .subscription: return "Subscription"
        case .manageSub: return "Manage Subscription"
        case .restorePurchases: return "Restore Purchases"
        case .appInfo: return "App Info"
        case .version: return "Version"
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfService: return "Terms of Service"
        case .logOut: return "Log Out & Register New User"
        case .logOutTitle: return "Log Out?"
        case .logOutMessage: return "This will erase your profile and workout history. A new user can then register."
        case .logOutConfirm: return "Log Out & Start Fresh"
        case .cancel: return "Cancel"
        case .save: return "Save"
        case .editProfile: return "Edit Profile"
        case .personalInfo: return "Personal Info"
        case .unlockFitPro: return "Unlock FitPro"
        case .fitnessCompanion: return "Your complete fitness companion"
        case .allWorkoutPlans: return "All Workout Plans"
        case .personalizedDietPlans: return "Personalized Diet Plans"
        case .exerciseLibraryFull: return "Exercise Library (50+ moves)"
        case .progressTracking: return "Progress Tracking & Charts"
        case .activeWorkoutTracker: return "Active Workout Tracker"
        case .bodyMeasurements: return "Body Measurements Log"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .annual: return "Annual"
        case .billedMonthly: return "Billed monthly"
        case .billedQuarterly: return "Billed every 3 months"
        case .billedAnnually: return "Billed annually"
        case .save17: return "Save 17%"
        case .save50: return "Save 50%"
        case .startPlan: return "Start Plan"
        case .legalText: return "Subscriptions auto-renew. Cancel anytime in App Store settings."
        case .language: return "Language"
        case .switchLanguage: return "Switch Language"
        case .english: return "English"
        case .arabic: return "العربية"
        }
    }

    var arabic: String {
        switch self {
        case .welcomeTitle: return "مرحباً بك في FitPro"
        case .welcomeSubtitle: return "رحلتك الصحية الشخصية تبدأ هنا. سنقوم بإعداد ملفك الشخصي لتحصل على أفضل تجربة."
        case .letsGetStarted: return "لنبدأ الآن"
        case .aboutYou: return "معلوماتك"
        case .aboutYouSubtitle: return "ساعدنا في تخصيص تجربتك"
        case .yourName: return "اسمك"
        case .age: return "العمر"
        case .weight: return "الوزن"
        case .height: return "الطول"
        case .years: return "سنة"
        case .yourGoal: return "هدفك"
        case .whatToAchieve: return "ماذا تريد أن تحقق؟"
        case .dietaryPreference: return "النظام الغذائي"
        case .customizeMealPlan: return "سنخصص خطة وجباتك"
        case .letsGo: return "هيا بنا! 🚀"
        case .continueText: return "متابعة"
        case .loseWeight: return "خسارة الوزن"
        case .buildMuscle: return "بناء العضلات"
        case .improveEndurance: return "تحسين التحمّل"
        case .stayFit: return "الحفاظ على اللياقة"
        case .sedentary: return "خامل"
        case .lightlyActive: return "نشاط خفيف"
        case .moderatelyActive: return "نشاط متوسط"
        case .veryActive: return "نشاط عالٍ"
        case .extraActive: return "نشاط مكثف جداً"
        case .standard: return "عادي"
        case .vegetarian: return "نباتي"
        case .vegan: return "نباتي صرف"
        case .keto: return "كيتو"
        case .paleo: return "باليو"
        case .goodMorning: return "صباح الخير"
        case .goodAfternoon: return "مساء الخير"
        case .goodEvening: return "مساء النور"
        case .athlete: return "رياضي"
        case .todaysWorkout: return "تمرين اليوم"
        case .restDay: return "يوم راحة"
        case .recoveryKey: return "الراحة أساس التقدم"
        case .exercises: return "تمرين"
        case .min: return "دقيقة"
        case .todaysCalories: return "سعرات اليوم الحرارية"
        case .weekStreak: return "أسابيع متتالية"
        case .keepItUp: return "استمر! لا تكسر السلسلة."
        case .workouts: return "التمارين"
        case .activePlan: return "الخطة النشطة"
        case .weeks: return "أسابيع"
        case .daysPerWeek: return "أيام/أسبوع"
        case .exerciseLibrary: return "مكتبة التمارين"
        case .startThisPlan: return "ابدأ هذه الخطة"
        case .currentPlan: return "الخطة الحالية"
        case .howToPerform: return "طريقة الأداء"
        case .proTip: return "نصيحة احترافية"
        case .sets: return "المجموعات"
        case .reps: return "التكرارات"
        case .rest: return "الراحة"
        case .muscles: return "العضلات المستهدفة"
        case .equipment: return "المعدات"
        case .startWorkout: return "ابدأ التمرين"
        case .finishWorkout: return "إنهاء التمرين"
        case .cancelWorkout: return "إلغاء"
        case .previous: return "السابق"
        case .next: return "التالي"
        case .finish: return "إنهاء"
        case .finishWorkoutQ: return "إنهاء التمرين؟"
        case .greatWork: return "عمل رائع! هل تحفظ جلسة التمرين؟"
        case .diet: return "التغذية"
        case .chooseMealPlan: return "اختر خطة الوجبات"
        case .logged: return "تم التسجيل"
        case .markAsEaten: return "سجّل كوجبة مأكولة"
        case .ingredients: return "المكونات"
        case .preparation: return "طريقة التحضير"
        case .prepTime: return "الوقت"
        case .protein: return "بروتين"
        case .carbs: return "كربوهيدرات"
        case .fats: return "دهون"
        case .kcalDay: return "سعرة/يوم"
        case .todayConsumed: return "ما تناولته اليوم"
        case .progress: return "التقدم"
        case .totalWorkouts: return "إجمالي التمارين"
        case .hoursTrained: return "ساعات التدريب"
        case .caloriesBurned: return "السعرات المحروقة"
        case .weeklyStreak: return "السلسلة الأسبوعية"
        case .last7Days: return "آخر ٧ أيام"
        case .weightProgress: return "تقدم الوزن"
        case .recentSessions: return "الجلسات الأخيرة"
        case .noSessionsYet: return "لا توجد جلسات بعد. أكمل تمريناً لرؤية الإحصائيات."
        case .logMeasurement: return "تسجيل القياسات"
        case .logBodyMeasurement: return "تسجيل قياسات الجسم"
        case .bodyWeight: return "وزن الجسم"
        case .optional: return "اختياري"
        case .sessions: return "جلسة"
        case .hours: return "ساعة"
        case .profile: return "الملف الشخصي"
        case .edit: return "تعديل"
        case .bodyStats: return "قياسات الجسم"
        case .bmi: return "مؤشر كتلة الجسم"
        case .dailyCalories: return "السعرات اليومية"
        case .fitnessProfile: return "الملف الرياضي"
        case .goal: return "الهدف"
        case .activityLevel: return "مستوى النشاط"
        case .dietPreference: return "النظام الغذائي"
        case .subscription: return "الاشتراك"
        case .manageSub: return "إدارة الاشتراك"
        case .restorePurchases: return "استعادة المشتريات"
        case .appInfo: return "معلومات التطبيق"
        case .version: return "الإصدار"
        case .privacyPolicy: return "سياسة الخصوصية"
        case .termsOfService: return "شروط الخدمة"
        case .logOut: return "تسجيل الخروج وتسجيل مستخدم جديد"
        case .logOutTitle: return "تسجيل الخروج؟"
        case .logOutMessage: return "سيتم مسح ملفك الشخصي وسجل التمارين. يمكن لمستخدم جديد التسجيل بعد ذلك."
        case .logOutConfirm: return "خروج وبداية جديدة"
        case .cancel: return "إلغاء"
        case .save: return "حفظ"
        case .editProfile: return "تعديل الملف الشخصي"
        case .personalInfo: return "المعلومات الشخصية"
        case .unlockFitPro: return "افتح FitPro"
        case .fitnessCompanion: return "رفيقك الرياضي الشامل"
        case .allWorkoutPlans: return "جميع خطط التمارين"
        case .personalizedDietPlans: return "خطط غذائية مخصصة"
        case .exerciseLibraryFull: return "مكتبة تمارين (+٥٠ حركة)"
        case .progressTracking: return "تتبع التقدم والرسوم البيانية"
        case .activeWorkoutTracker: return "متتبع التمرين الحي"
        case .bodyMeasurements: return "سجل قياسات الجسم"
        case .monthly: return "شهري"
        case .quarterly: return "ربع سنوي"
        case .annual: return "سنوي"
        case .billedMonthly: return "يُفوتر شهرياً"
        case .billedQuarterly: return "يُفوتر كل ٣ أشهر"
        case .billedAnnually: return "يُفوتر سنوياً"
        case .save17: return "وفّر ١٧٪"
        case .save50: return "وفّر ٥٠٪"
        case .startPlan: return "ابدأ الخطة"
        case .legalText: return "يتجدد الاشتراك تلقائياً. يمكن الإلغاء في أي وقت من إعدادات App Store."
        case .language: return "اللغة"
        case .switchLanguage: return "تغيير اللغة"
        case .english: return "English"
        case .arabic: return "العربية"
        }
    }
}
