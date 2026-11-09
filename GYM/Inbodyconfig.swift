//
//  Inbodyconfig.swift
//  GYM
//
//  Created by Mohamed ahmed on 31/10/2026.


//import Foundation
//
//// Put your Anthropic API key here.
//// Warning: a key bundled inside the app can be extracted by anyone who installs it.
//// For a public release, call Claude from your own backend instead.
//enum InBodyConfig {
//    static let apiKey = "PASTE_YOUR_NEW_API_KEY_HERE"
//    static let model = "claude-sonnet-5-5"
//}
//



import Foundation

enum InBodyConfig {
    // ضع مفتاحك الحقيقي هنا (تأكد من عدم وجود مسافات فارغة في البداية أو النهاية)
    private static let rawApiKey = "sk-ant-api03-YOUR_ACTUAL_API_KEY_HERE"
    
    // دالة لتنظيف المفتاح تلقائياً من أي مسافات أو رموز مخفية قد تسبب خطأ invalid x-api-key
    static var apiKey: String {
        return rawApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static let model = "claude-3-5-sonnet-20241022"
    static let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    
    // دالة جاهزة لإعداد طلب الـ API بالهيدرز الصحيحة تماماً لمنع ظهور الخطأ
    static func configureRequest(for request: inout URLRequest) {
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
    }
}




