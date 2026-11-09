//
//  Untitled.swift
//  GYM
//
//  Created by Mohamed ahmed on 13/10/2026.

//كود cloude بس لازم اضيف Api الحقيقي الخاص بيا عشان يشتغل ال ذكاء الاصطناعي


//import SwiftUI
//import Combine
//import PDFKit
//import UniformTypeIdentifiers
//
//// MARK: - Result model
//struct InBodyAnalysis: Codable, Identifiable {
//    var id: String = UUID().uuidString
//    var date: Date = Date()
//    var weightKg: Double?
//    var bodyFatPercent: Double?
//    var muscleMassKg: Double?
//    var bmi: Double?
//    var summary: String = ""
//}
//
//// MARK: - Attachment (photo or PDF)
//enum InBodyAttachmentKind { case image, pdf }
//
//struct InBodyAttachment: Identifiable {
//    let id = UUID()
//    let name: String
//    let kind: InBodyAttachmentKind
//    let data: Data
//    let thumbnail: UIImage?
//}
//
//// MARK: - ViewModel
//@MainActor
//final class InBodyViewModel: ObservableObject {
//    @Published var attachments: [InBodyAttachment] = []
//    @Published var isAnalyzing = false
//    @Published var analysis: InBodyAnalysis?
//    @Published var errorMessage = ""
//
//    let maxAttachments = 5
//    private let maxPDFBytes = 15 * 1024 * 1024
//    private let maxTotalBytes = 20 * 1024 * 1024
//
//    private var totalBytes: Int { attachments.reduce(0) { $0 + $1.data.count } }
//
//    // MARK: Add / remove
//    func addImage(_ image: UIImage, name: String = "InBody.jpg") {
//        guard canAdd() else { return }
//        let resized = image.fbResized(maxDimension: 1600)
//        guard let data = resized.jpegData(compressionQuality: 0.75) else { return }
//        guard totalBytes + data.count <= maxTotalBytes else {
//            errorMessage = "حجم الملفات كبير جداً · Files are too large"
//            return
//        }
//        attachments.append(InBodyAttachment(name: name, kind: .image, data: data, thumbnail: resized))
//        analysis = nil
//        errorMessage = ""
//    }
//
//    func addFiles(_ urls: [URL]) {
//        for url in urls {
//            guard canAdd() else { break }
//            let scoped = url.startAccessingSecurityScopedResource()
//            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
//
//            guard let data = try? Data(contentsOf: url) else {
//                errorMessage = "تعذر قراءة الملف · Couldn't read the file"
//                continue
//            }
//
//            if url.pathExtension.lowercased() == "pdf" {
//                guard data.count <= maxPDFBytes, totalBytes + data.count <= maxTotalBytes else {
//                    errorMessage = "ملف PDF كبير جداً (الحد 15MB) · PDF too large (max 15MB)"
//                    continue
//                }
//                let thumb = PDFDocument(data: data)?.page(at: 0)?
//                    .thumbnail(of: CGSize(width: 220, height: 300), for: .mediaBox)
//                attachments.append(InBodyAttachment(name: url.lastPathComponent, kind: .pdf, data: data, thumbnail: thumb))
//                analysis = nil
//                errorMessage = ""
//            } else if let image = UIImage(data: data) {
//                addImage(image, name: url.lastPathComponent)
//            } else {
//                errorMessage = "نوع الملف غير مدعوم · Unsupported file type"
//            }
//        }
//    }
//
//    func remove(_ item: InBodyAttachment) {
//        attachments.removeAll { $0.id == item.id }
//        analysis = nil
//    }
//
//    private func canAdd() -> Bool {
//        if attachments.count >= maxAttachments {
//            errorMessage = "الحد الأقصى \(maxAttachments) ملفات · Max \(maxAttachments) files"
//            return false
//        }
//        return true
//    }
//
//    // MARK: Analyze
//    func analyze(arabic: Bool) async {
//        guard !attachments.isEmpty, !isAnalyzing else { return }
//
//        guard !InBodyConfig.apiKey.hasPrefix("PASTE") else {
//            errorMessage = arabic ? "ضع مفتاح Claude في ملف InBodyConfig.swift"
//                                  : "Add your Claude API key in InBodyConfig.swift"
//            return
//        }
//
//        isAnalyzing = true
//        errorMessage = ""
//        defer { isAnalyzing = false }
//
//        do {
//            var blocks: [[String: Any]] = []
//            for item in attachments {
//                let base64 = item.data.base64EncodedString()
//                switch item.kind {
//                case .image:
//                    blocks.append(["type": "image",
//                                   "source": ["type": "base64", "media_type": "image/jpeg", "data": base64]])
//                case .pdf:
//                    blocks.append(["type": "document",
//                                   "source": ["type": "base64", "media_type": "application/pdf", "data": base64]])
//                }
//            }
//            blocks.append(["type": "text", "text": buildPrompt(arabic: arabic)])
//
//            let body: [String: Any] = [
//                "model": InBodyConfig.model,
//                "max_tokens": 3000,
//                "messages": [["role": "user", "content": blocks]]
//            ]
//
//            var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue(InBodyConfig.apiKey, forHTTPHeaderField: "x-api-key")
//            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//            request.timeoutInterval = 120
//
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
//                var detail = String(data: data, encoding: .utf8) ?? ""
//                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                   let err = json["error"] as? [String: Any],
//                   let message = err["message"] as? String {
//                    detail = message
//                }
//                throw NSError(domain: "InBodyAPI", code: http.statusCode,
//                              userInfo: [NSLocalizedDescriptionKey: detail])
//            }
//
//            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//            let content = json?["content"] as? [[String: Any]]
//            let text = content?.compactMap { $0["text"] as? String }.joined(separator: "\n") ?? ""
//
//            var result = InBodyAnalysis()
//            result.weightKg = extractValue(from: text, key: "WEIGHT:")
//            result.bodyFatPercent = extractValue(from: text, key: "FATPCT:")
//            result.muscleMassKg = extractValue(from: text, key: "MUSCLE:")
//            result.bmi = extractValue(from: text, key: "BMI:")
//            result.summary = cleanedSummary(text)
//            analysis = result
//        } catch {
//            errorMessage = (arabic ? "حدث خطأ: " : "Error: ") + error.localizedDescription
//        }
//    }
//
//    private func buildPrompt(arabic: Bool) -> String {
//        let language = arabic ? "Arabic" : "English"
//        return """
//You are a professional fitness coach and InBody report analyst.
//The user attached \(attachments.count) file(s) (photos or PDFs) of their InBody body composition report. If there are several, they belong to the same person. If they are from different dates, compare them and mention the progress.
//
//First extract these values and put each on its own line exactly in this format (numbers only, no units):
//WEIGHT: <weight in kg>
//FATPCT: <body fat percentage>
//MUSCLE: <skeletal muscle mass in kg>
//BMI: <BMI>
//If a value is not visible, leave it empty after the colon.
//
//Then write, in \(language):
//1. Body assessment based on the numbers (strengths and areas to improve).
//2. A weekly workout plan (5 days) with exercises, sets and reps tailored to this body.
//3. A daily nutrition plan: daily calories, macros in grams, and 5 meals with portions.
//4. Five key recommendations.
//
//Use clear headings with emojis. Be specific and practical. End with one short line saying this is general guidance, not medical advice.
//"""
//    }
//
//    private func extractValue(from text: String, key: String) -> Double? {
//        guard let range = text.range(of: key) else { return nil }
//        let after = String(text[range.upperBound...].prefix(20)).trimmingCharacters(in: .whitespaces)
//        let digits = after.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).first ?? ""
//        return Double(digits)
//    }
//
//    private func cleanedSummary(_ text: String) -> String {
//        let hidden = ["WEIGHT:", "FATPCT:", "MUSCLE:", "BMI:"]
//        return text
//            .split(separator: "\n", omittingEmptySubsequences: false)
//            .filter { line in
//                let trimmed = line.trimmingCharacters(in: .whitespaces)
//                return !hidden.contains { trimmed.hasPrefix($0) }
//            }
//            .joined(separator: "\n")
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//}
//
//private extension UIImage {
//    func fbResized(maxDimension: CGFloat) -> UIImage {
//        let longest = max(size.width, size.height)
//        guard longest > maxDimension else { return self }
//        let scale = maxDimension / longest
//        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
//        let format = UIGraphicsImageRendererFormat.default()
//        format.scale = 1
//        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
//            self.draw(in: CGRect(origin: .zero, size: newSize))
//        }
//    }
//}
//
//// MARK: - Screen
//struct InBodyScannerView: View {
//    @StateObject private var vm = InBodyViewModel()
//    @EnvironmentObject var lm: LanguageManager
//
//    @State private var showSourceDialog = false
//    @State private var showImagePicker = false
//    @State private var showFileImporter = false
//    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 24) {
//                    header
//                    if vm.attachments.isEmpty {
//                        emptyUploadCard
//                    } else {
//                        attachmentsStrip
//                    }
//                    if !vm.errorMessage.isEmpty { errorRow }
//                    if !vm.attachments.isEmpty { analyzeButton }
//                    if let analysis = vm.analysis {
//                        InBodyResultsView(analysis: analysis, lm: lm)
//                            .padding(.horizontal)
//                    }
//                    Spacer(minLength: 30)
//                }
//                .padding(.top)
//            }
//            .background(Color(.systemGroupedBackground))
//            .navigationTitle(lm.isArabic ? "تحليل InBody" : "InBody Analysis")
//            .fileImporter(isPresented: $showFileImporter,
//                          allowedContentTypes: [.pdf, .image],
//                          allowsMultipleSelection: true) { result in
//                switch result {
//                case .success(let urls): vm.addFiles(urls)
//                case .failure(let error): vm.errorMessage = error.localizedDescription
//                }
//            }
//        }
//        .confirmationDialog(lm.isArabic ? "إضافة ملف" : "Add a file",
//                            isPresented: $showSourceDialog,
//                            titleVisibility: .visible) {
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                Button(lm.isArabic ? "الكاميرا" : "Camera") { openPicker(.camera) }
//            }
//            Button(lm.isArabic ? "مكتبة الصور" : "Photo Library") { openPicker(.photoLibrary) }
//            Button(lm.isArabic ? "ملفات (PDF / صور)" : "Files (PDF / images)") { openFiles() }
//            Button(lm.isArabic ? "إلغاء" : "Cancel", role: .cancel) {}
//        }
//        .sheet(isPresented: $showImagePicker) {
//            LegacyImagePicker(sourceType: pickerSource, allowsEditing: false) { image in
//                vm.addImage(image)
//            }
//        }
//    }
//
//    // MARK: Pieces
//    private var header: some View {
//        VStack(spacing: 10) {
//            ZStack {
//                Circle()
//                    .fill(LinearGradient(colors: [.green.opacity(0.2), .mint.opacity(0.1)],
//                                         startPoint: .topLeading, endPoint: .bottomTrailing))
//                    .frame(width: 90, height: 90)
//                Image(systemName: "waveform.path.ecg.rectangle.fill")
//                    .font(.system(size: 40))
//                    .foregroundStyle(LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom))
//            }
//            Text(lm.isArabic ? "محلل InBody بالذكاء الاصطناعي" : "InBody AI Analyzer")
//                .font(.title2).bold()
//            Text(lm.isArabic
//                 ? "ارفع صور أو ملفات PDF لتقريرك واحصل على خطة تمرين وغذاء مخصصة"
//                 : "Upload photos or PDFs of your report for a personalized plan")
//                .font(.subheadline).foregroundColor(.secondary)
//                .multilineTextAlignment(.center).padding(.horizontal)
//        }
//        .padding(.top, 8)
//    }
//
//    private var emptyUploadCard: some View {
//        Button(action: { showSourceDialog = true }) {
//            VStack(spacing: 14) {
//                Image(systemName: "arrow.up.doc.fill")
//                    .font(.system(size: 44)).foregroundColor(.green)
//                Text(lm.isArabic ? "ارفع صور أو ملفات التقرير" : "Upload report photos or files")
//                    .font(.headline)
//                Text(lm.isArabic ? "صور من الكاميرا أو المعرض، أو ملفات PDF" : "Camera, photo library, or PDF files")
//                    .font(.caption).foregroundColor(.secondary)
//            }
//            .frame(maxWidth: .infinity)
//            .frame(height: 200)
//            .background(Color(.secondarySystemGroupedBackground))
//            .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
//                    .foregroundColor(.green.opacity(0.4))
//            )
//            .cornerRadius(20)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .padding(.horizontal)
//    }
//
//    private var attachmentsStrip: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text(lm.isArabic
//                 ? "الملفات المرفقة (\(vm.attachments.count)/\(vm.maxAttachments))"
//                 : "Attachments (\(vm.attachments.count)/\(vm.maxAttachments))")
//                .font(.subheadline).bold()
//                .padding(.horizontal)
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 12) {
//                    ForEach(vm.attachments) { item in
//                        InBodyAttachmentCard(attachment: item) { vm.remove(item) }
//                    }
//                    if vm.attachments.count < vm.maxAttachments {
//                        addMoreTile
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.vertical, 4)
//            }
//        }
//    }
//
//    private var addMoreTile: some View {
//        Button(action: { showSourceDialog = true }) {
//            VStack(spacing: 8) {
//                Image(systemName: "plus.circle.fill").font(.title).foregroundColor(.green)
//                Text(lm.isArabic ? "إضافة" : "Add").font(.caption).foregroundColor(.secondary)
//            }
//            .frame(width: 110, height: 140)
//            .background(Color(.secondarySystemGroupedBackground))
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
//                    .foregroundColor(.green.opacity(0.4))
//            )
//            .cornerRadius(12)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//
//    private var errorRow: some View {
//        HStack(alignment: .top, spacing: 8) {
//            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
//            Text(vm.errorMessage).font(.caption).foregroundColor(.orange)
//            Spacer()
//        }
//        .padding(.horizontal)
//    }
//
//    private var analyzeButton: some View {
//        Button(action: { Task { await vm.analyze(arabic: lm.isArabic) } }) {
//            HStack(spacing: 10) {
//                if vm.isAnalyzing {
//                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
//                    Text(lm.isArabic ? "جارٍ التحليل..." : "Analyzing...").font(.headline)
//                } else {
//                    Image(systemName: "brain.head.profile")
//                    Text(lm.isArabic ? "تحليل بالذكاء الاصطناعي" : "Analyze with AI").font(.headline)
//                }
//            }
//            .foregroundColor(.black)
//            .frame(maxWidth: .infinity)
//            .frame(height: 54)
//            .background(LinearGradient(
//                colors: vm.isAnalyzing ? [Color.gray] : [Color(red: 0.88, green: 1.0, blue: 0.2), .green],
//                startPoint: .leading, endPoint: .trailing))
//            .cornerRadius(16)
//        }
//        .disabled(vm.isAnalyzing)
//        .padding(.horizontal)
//    }
//
//    // MARK: Helpers
//    // Small delay so the dialog finishes dismissing before the next sheet appears
//    private func openPicker(_ source: UIImagePickerController.SourceType) {
//        pickerSource = source
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showImagePicker = true }
//    }
//
//    private func openFiles() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showFileImporter = true }
//    }
//}
//
//// MARK: - Attachment card
//struct InBodyAttachmentCard: View {
//    let attachment: InBodyAttachment
//    let onRemove: () -> Void
//
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            VStack(spacing: 6) {
//                ZStack(alignment: .bottomLeading) {
//                    if let thumb = attachment.thumbnail {
//                        Image(uiImage: thumb)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 110, height: 140)
//                    } else {
//                        Color(.tertiarySystemFill).frame(width: 110, height: 140)
//                    }
//                    if attachment.kind == .pdf {
//                        Text("PDF")
//                            .font(.caption2).bold()
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 6).padding(.vertical, 3)
//                            .background(Color.red)
//                            .cornerRadius(6)
//                            .padding(6)
//                    }
//                }
//                .frame(width: 110, height: 140)
//                .clipped()
//                .cornerRadius(12)
//
//                Text(attachment.name)
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//                    .frame(width: 110)
//            }
//
//            Button(action: onRemove) {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.title3)
//                    .foregroundStyle(.white, Color.black.opacity(0.7))
//            }
//            .padding(4)
//        }
//    }
//}
//
//// MARK: - Results
//struct InBodyResultsView: View {
//    let analysis: InBodyAnalysis
//    let lm: LanguageManager
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            if analysis.weightKg != nil || analysis.bodyFatPercent != nil
//                || analysis.muscleMassKg != nil || analysis.bmi != nil {
//                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
//                    if let w = analysis.weightKg {
//                        InBodyStatCard(icon: "scalemass.fill", color: .blue,
//                                       title: lm.isArabic ? "الوزن" : "Weight",
//                                       value: String(format: "%.1f kg", w))
//                    }
//                    if let f = analysis.bodyFatPercent {
//                        InBodyStatCard(icon: "drop.fill", color: .orange,
//                                       title: lm.isArabic ? "الدهون" : "Body Fat",
//                                       value: String(format: "%.1f%%", f))
//                    }
//                    if let m = analysis.muscleMassKg {
//                        InBodyStatCard(icon: "bolt.fill", color: .green,
//                                       title: lm.isArabic ? "العضلات" : "Muscle",
//                                       value: String(format: "%.1f kg", m))
//                    }
//                    if let b = analysis.bmi {
//                        InBodyStatCard(icon: "heart.fill", color: .red,
//                                       title: "BMI",
//                                       value: String(format: "%.1f", b))
//                    }
//                }
//            }
//
//            VStack(alignment: .leading, spacing: 10) {
//                Label(lm.isArabic ? "تحليل الذكاء الاصطناعي" : "AI Analysis",
//                      systemImage: "brain.head.profile")
//                    .font(.headline).foregroundColor(.green)
//
//                Text(markdown(analysis.summary))
//                    .font(.body)
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color(.secondarySystemGroupedBackground))
//                    .cornerRadius(14)
//            }
//        }
//    }
//
//    private func markdown(_ text: String) -> AttributedString {
//        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
//        return (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
//    }
//}
//
//struct InBodyStatCard: View {
//    let icon: String
//    let color: Color
//    let title: String
//    let value: String
//
//    var body: some View {
//        VStack(spacing: 8) {
//            Image(systemName: icon).font(.title2).foregroundColor(color)
//            Text(value).font(.title3).bold()
//            Text(title).font(.caption).foregroundColor(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 16)
//        .background(Color(.secondarySystemGroupedBackground))
//        .cornerRadius(14)
//    }
//}





//كود Gemini دا شغال بس وهمي ال Api مش حقيقي



import SwiftUI
import Combine
import PDFKit
import UniformTypeIdentifiers

// MARK: - Result model
struct InBodyAnalysis: Codable, Identifiable {
    var id: String = UUID().uuidString
    var date: Date = Date()
    var weightKg: Double?
    var bodyFatPercent: Double?
    var muscleMassKg: Double?
    var bmi: Double?
    var summary: String = ""
}

// MARK: - Attachment (photo or PDF)
enum InBodyAttachmentKind { case image, pdf }

struct InBodyAttachment: Identifiable {
    let id = UUID()
    let name: String
    let kind: InBodyAttachmentKind
    let data: Data
    let thumbnail: UIImage?
}

// MARK: - ViewModel
@MainActor
final class InBodyViewModel: ObservableObject {
    @Published var attachments: [InBodyAttachment] = []
    @Published var isAnalyzing = false
    @Published var analysis: InBodyAnalysis?
    @Published var errorMessage = ""

    let maxAttachments = 5
    private let maxPDFBytes = 15 * 1024 * 1024
    private let maxTotalBytes = 20 * 1024 * 1024

    private var totalBytes: Int { attachments.reduce(0) { $0 + $1.data.count } }

    // MARK: Add / remove
    func addImage(_ image: UIImage, name: String = "InBody.jpg") {
        guard canAdd() else { return }
        let resized = image.fbResized(maxDimension: 1600)
        guard let data = resized.jpegData(compressionQuality: 0.75) else { return }
        guard totalBytes + data.count <= maxTotalBytes else {
            errorMessage = "حجم الملفات كبير جداً · Files are too large"
            return
        }
        attachments.append(InBodyAttachment(name: name, kind: .image, data: data, thumbnail: resized))
        analysis = nil
        errorMessage = ""
    }

    func addFiles(_ urls: [URL]) {
        for url in urls {
            guard canAdd() else { break }
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }

            guard let data = try? Data(contentsOf: url) else {
                errorMessage = "تعذر قراءة الملف · Couldn't read the file"
                continue
            }

            if url.pathExtension.lowercased() == "pdf" {
                guard data.count <= maxPDFBytes, totalBytes + data.count <= maxTotalBytes else {
                    errorMessage = "ملف PDF كبير جداً (الحد 15MB) · PDF too large (max 15MB)"
                    continue
                }
                let thumb = PDFDocument(data: data)?.page(at: 0)?
                    .thumbnail(of: CGSize(width: 220, height: 300), for: .mediaBox)
                attachments.append(InBodyAttachment(name: url.lastPathComponent, kind: .pdf, data: data, thumbnail: thumb))
                analysis = nil
                errorMessage = ""
            } else if let image = UIImage(data: data) {
                addImage(image, name: url.lastPathComponent)
            } else {
                errorMessage = "نوع الملف غير مدعوم · Unsupported file type"
            }
        }
    }

    func remove(_ item: InBodyAttachment) {
        attachments.removeAll { $0.id == item.id }
        analysis = nil
    }

    private func canAdd() -> Bool {
        if attachments.count >= maxAttachments {
            errorMessage = "الحد الأقصى \(maxAttachments) ملفات · Max \(maxAttachments) files"
            return false
        }
        return true
    }

    // MARK: Analyze (Full Detailed Mock Plan)
    func analyze(arabic: Bool) async {
        guard !attachments.isEmpty, !isAnalyzing else { return }

        isAnalyzing = true
        errorMessage = ""
        defer { isAnalyzing = false }

        // محاكاة انتظر التحليل 1.5 ثانية
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        var result = InBodyAnalysis()
        result.weightKg = 74.5
        result.bodyFatPercent = 18.2
        result.muscleMassKg = 35.8
        result.bmi = 23.4
        
        if arabic {
            result.summary = """
            📊 **تقرير التحليل والتقييم الشامل (InBody Analysis):**
            - **الوزن الحالي:** 74.5 كجم | **نسبة الدهون:** 18.2% (صحي ومناسب)
            - **الكتلة العضلية:** 35.8 كجم | **مؤشر كتلة الجسم (BMI):** 23.4
            - **الهدف:** زيادة الكتلة العضلية الصافية، نحت الجسم، وخفض نسبة الدهون تدريجياً.

            ---

            🏋️‍♂️ **جدول التمارين الأسبوعي الشامل (6 أيام):**

            * **اليوم الأول: (صدر + ترايستبس + بطن)**
              1. بنش بريس بالبار (Bench Press): 4 مجموعات × 10-12 تكرار
              2. انكلين دمبل بريس (Incline Dumbbell Press): 4 مجموعات × 12 تكرار
              3. فتح صدر جهاز (Chest Fly): 3 مجموعات × 15 تكرار
              4. تمديد ترايستبس بالحبل (Triceps Pushdown): 4 مجموعات × 12 تكرار
              5. ترايستبس خلف الرأس بالدمبل: 3 مجموعات × 12 تكرار
              6. تمرين بلانك للبطن: 3 جولات × 60 ثانية

            * **اليوم الثاني: (ظهر + بايستبس + ساعد)**
              1. سحب عالي للظهر (Lat Pulldown): 4 مجموعات × 12 تكرار
              2. سحب أرضي كابل (Seated Cable Row): 4 مجموعات × 10 تكرار
              3. سحب تبادل بالدمبل (Dumbbell Row): 3 مجموعات لكل يد × 10 تكرار
              4. تبادل بايستبس بالدمبل (Bicep Curls): 4 مجموعات × 12 تكرار
              5. بايستبس بار معقوف (EZ-Bar Curl): 3 مجموعات × 10 تكرار

            * **اليوم الثالث: (أرجل كاملة + سمانة)**
              1. سكوات بالبار (Barbell Squat): 4 مجموعات × 10 تكرارات
              2. ليج بريس (Leg Press): 4 مجموعات × 12 تكرار
              3. مرجحة أرجل خلفي (Hamstring Curl): 3 مجموعات × 15 تكرار
              4. طعن بالدمبل (Lunges): 3 مجموعات لكل رجل × 12 خطوة
              5. سمانة واقف (Standing Calf Raises): 4 مجموعات × 20 تكرار

            * **اليوم الرابع: (أكتاف + ترابيزيس + بطن)**
              1. ضغط أكتاف بالدمبل (Dumbbell Shoulder Press): 4 مجموعات × 12 تكرار
              2. رفرف جانبي دمبل (Lateral Raises): 4 مجموعات × 15 تكرار
              3. رفرف خلفي للأكتاف (Rear Delt Fly): 3 مجموعات × 15 تكرار
              4. هز كتاف بالبار للترابيزيس (Shrugs): 3 مجموعات × 12 تكرار
              5. رفع ساقين للبطن (Leg Raises): 3 مجموعات × 15 تكرار

            * **اليوم الخامس: (تضخيم شامل / Upper Body Focus)**
              1. تجميع صدر مائل بالدمبل: 4 مجموعات × 12 تكرار
              2. عقلة واسع (Pull-ups أو Assisted): 3 مجموعات × أقصى تكرار
              3. رفرف أكتاف أمامي بالكابل: 3 مجموعات × 12 تكرار
              4. سوبرسيت (بايستبس + ترايستبس): 3 مجموعات × 12 تكرار

            * **اليوم السادس: (كارديو مكثف + حرق دهون + استشفاء)**
              1. جري متقطع على المشاية (HIIT): 30 دقيقة
              2. نط الحبل: 4 جولات × 2 دقيقة
              3. تمارين إطالة واسترخاء لكامل الجسم: 15 دقيقة

            * **اليوم السابع: (راحة تامة للاستشفاء العضلي)**

            ---

            🥗 **الخطة الغذائية اليومية المتكاملة (طوال الأسبوع):**
            - **السعرات المستهدفة:** 2,300 سعرة حرارية.
            - **توزيع المغذيات الكبرى (Macros):** بروتين 160 جرام | كاربوهيدرات 240 جرام | دهون صحية 65 جرام.

            * **وجبة الإفطار (وجبة 1):**
              - 4 بيضات مسلوقة (أو أومليت بقليل من زيت الزيتون).
              - 100 جرام شوفان مع كوب حليب خالي الدسم ورشة قرفة وملعقة عسل.
              - ثمرة فاكهة (موزة أو تفاحة).

            * **وجبة الغداء (وجبة 2 - قبل التمرين بـ ساعتين):**
              - 200 جرام صدور دجاج مشوية (أو لحم مفروم قليل الدهون أو سمك فيليه).
              - 200 جرام أرز مصري أو بسمتي مطبوخ أو مكرونة مسلوقة.
              - طبق سلطة خضراء كبير مكثف بالخضروات الورقية مع ليمون وزيت زيتون.

            * **وجبة ما قبل التمرين (وجبة 3 - خفيفة):**
              - توست بر مع ملعقة زبدة فول سوداني + شرائح موز.

            * **وجبة ما بعد التمرين (وجبة 4 - استشفاء):**
              - سكوب واي بروتين (أو علبة تونة مصفاة / 150 جرام جبن قريش).
              - بطاطس متوسطة مسلوقة أو في الفرن.

            * **وجبة العشاء (وجبة 5 - قبل النوم):**
              - كوب زبادي يوناني أو لبن رايب.
              - حفنة مكسرات ندمية غير ملوحة (لوز أو عين جمل).

            ---

            💡 **تعليمات أساسية لضمان تطور ملحوظ وسريع:**
            1. **الزيادة التدريجية للأوزان (Progressive Overload):** يجب زيادة الوزن أو عدد التكرارات أسبوعياً في كل تمرينة.
            2. **شرب الماء:** الالتزام بشرب من 3.5 إلى 4 لتر ماء يومياً.
            3. **النوم:** النوم العميق لمدة 7 إلى 8 ساعات ليلاً لتحفيز النمو العضلي.
            """
        } else {
            result.summary = """
            📊 **Comprehensive InBody Analysis:**
            - **Current Weight:** 74.5 kg | **Body Fat:** 18.2% (Healthy)
            - **Muscle Mass:** 35.8 kg | **BMI:** 23.4
            - **Goal:** Lean muscle hypertrophy and gradual fat loss.

            ---

            🏋️‍♂️ **Full Weekly Workout Routine (6 Days):**
            - **Day 1 (Chest & Triceps & Abs):** Bench Press 4x10, Incline Dumbbell Press 4x12, Chest Fly 3x15, Triceps Pushdown 4x12, Planks 3x60s.
            - **Day 2 (Back & Biceps):** Lat Pulldowns 4x12, Seated Cable Rows 4x10, Dumbbell Rows 3x10, Bicep Curls 4x12, EZ-Bar Curls 3x10.
            - **Day 3 (Full Legs & Calves):** Barbell Squats 4x10, Leg Press 4x12, Hamstring Curls 3x15, Lunges 3x12, Calf Raises 4x20.
            - **Day 4 (Shoulders & Traps & Abs):** Shoulder Press 4x12, Lateral Raises 4x15, Rear Delt Fly 3x15, Shrugs 3x12, Leg Raises 3x15.
            - **Day 5 (Upper Body Focus):** Incline Dumbbell Press 4x12, Pull-ups 3xMax, Cable Front Raises 3x12, Superset Biceps & Triceps 3x12.
            - **Day 6 (HIIT Cardio & Recovery):** Interval Jogging 30 mins, Jump Rope 4x2 mins, Full Body Stretching 15 mins.
            - **Day 7 (Full Rest Day):** Complete muscular recovery.

            ---

            🥗 **Full Daily Nutrition Plan:**
            - **Target Calories:** 2,300 kcal.
            - **Macros:** Protein: 160g | Carbs: 240g | Fats: 65g.
            - **Meal 1 (Breakfast):** 4 boiled eggs + 100g oatmeal with skimmed milk & honey + 1 fruit.
            - **Meal 2 (Lunch):** 200g grilled chicken breast + 200g cooked white rice + large green salad.
            - **Meal 3 (Pre-Workout):** Whole wheat toast with peanut butter + banana slices.
            - **Meal 4 (Post-Workout):** Whey protein scoop (or 150g cottage cheese/canned tuna) + boiled potato.
            - **Meal 5 (Dinner):** Greek yogurt + handful of raw almonds.

            💡 **Key Recommendations for Fast Progress:**
            1. Apply progressive overload every week.
            2. Drink 3.5–4 liters of water daily.
            3. Sleep 7-8 hours nightly for optimal recovery.
            """
        }

        self.analysis = result
    }
}

private extension UIImage {
    func fbResized(maxDimension: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return self }
        let scale = maxDimension / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - Screen
struct InBodyScannerView: View {
    @StateObject private var vm = InBodyViewModel()
    @EnvironmentObject var lm: LanguageManager

    @State private var showSourceDialog = false
    @State private var showImagePicker = false
    @State private var showFileImporter = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    if vm.attachments.isEmpty {
                        emptyUploadCard
                    } else {
                        attachmentsStrip
                    }
                    if !vm.errorMessage.isEmpty { errorRow }
                    if !vm.attachments.isEmpty { analyzeButton }
                    if let analysis = vm.analysis {
                        InBodyResultsView(analysis: analysis, lm: lm)
                            .padding(.horizontal)
                    }
                    Spacer(minLength: 30)
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(lm.isArabic ? "تحليل InBody" : "InBody Analysis")
            .fileImporter(isPresented: $showFileImporter,
                          allowedContentTypes: [.pdf, .image],
                          allowsMultipleSelection: true) { result in
                switch result {
                case .success(let urls): vm.addFiles(urls)
                case .failure(let error): vm.errorMessage = error.localizedDescription
                }
            }
        }
        .confirmationDialog(lm.isArabic ? "إضافة ملف" : "Add a file",
                            isPresented: $showSourceDialog,
                            titleVisibility: .visible) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button(lm.isArabic ? "الكاميرا" : "Camera") { openPicker(.camera) }
            }
            Button(lm.isArabic ? "مكتبة الصور" : "Photo Library") { openPicker(.photoLibrary) }
            Button(lm.isArabic ? "ملفات (PDF / صور)" : "Files (PDF / images)") { openFiles() }
            Button(lm.isArabic ? "إلغاء" : "Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            LegacyImagePicker(sourceType: pickerSource, allowsEditing: false) { image in
                vm.addImage(image)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.green.opacity(0.2), .mint.opacity(0.1)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90)
                Image(systemName: "waveform.path.ecg.rectangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom))
            }
            Text(lm.isArabic ? "محلل InBody بالذكاء الاصطناعي" : "InBody AI Analyzer")
                .font(.title2).bold()
            Text(lm.isArabic
                 ? "ارفع صور أو ملفات PDF لتقريرك واحصل على خطة تمرين وغذاء مخصصة"
                 : "Upload photos or PDFs of your report for a personalized plan")
                .font(.subheadline).foregroundColor(.secondary)
                .multilineTextAlignment(.center).padding(.horizontal)
        }
        .padding(.top, 8)
    }

    private var emptyUploadCard: some View {
        Button(action: { showSourceDialog = true }) {
            VStack(spacing: 14) {
                Image(systemName: "arrow.up.doc.fill")
                    .font(.system(size: 44)).foregroundColor(.green)
                Text(lm.isArabic ? "ارفع صور أو ملفات التقرير" : "Upload report photos or files")
                    .font(.headline)
                Text(lm.isArabic ? "صور من الكاميرا أو المعرض، أو ملفات PDF" : "Camera, photo library, or PDF files")
                    .font(.caption).foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color(.secondarySystemGroupedBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .foregroundColor(.green.opacity(0.4))
            )
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }

    private var attachmentsStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lm.isArabic
                 ? "الملفات المرفقة (\(vm.attachments.count)/\(vm.maxAttachments))"
                 : "Attachments (\(vm.attachments.count)/\(vm.maxAttachments))")
                .font(.subheadline).bold()
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.attachments) { item in
                        InBodyAttachmentCard(attachment: item) { vm.remove(item) }
                    }
                    if vm.attachments.count < vm.maxAttachments {
                        addMoreTile
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
    }

    private var addMoreTile: some View {
        Button(action: { showSourceDialog = true }) {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill").font(.title).foregroundColor(.green)
                Text(lm.isArabic ? "إضافة" : "Add").font(.caption).foregroundColor(.secondary)
            }
            .frame(width: 110, height: 140)
            .background(Color(.secondarySystemGroupedBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    .foregroundColor(.green.opacity(0.4))
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var errorRow: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
            Text(vm.errorMessage).font(.caption).foregroundColor(.orange)
            Spacer()
        }
        .padding(.horizontal)
    }

    private var analyzeButton: some View {
        Button(action: { Task { await vm.analyze(arabic: lm.isArabic) } }) {
            HStack(spacing: 10) {
                if vm.isAnalyzing {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                    Text(lm.isArabic ? "جارٍ التحليل..." : "Analyzing...").font(.headline)
                } else {
                    Image(systemName: "brain.head.profile")
                    Text(lm.isArabic ? "تحليل بالذكاء الاصطناعي" : "Analyze with AI").font(.headline)
                }
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(LinearGradient(
                colors: vm.isAnalyzing ? [Color.gray] : [Color(red: 0.88, green: 1.0, blue: 0.2), .green],
                startPoint: .leading, endPoint: .trailing))
            .cornerRadius(16)
        }
        .disabled(vm.isAnalyzing)
        .padding(.horizontal)
    }

    private func openPicker(_ source: UIImagePickerController.SourceType) {
        pickerSource = source
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showImagePicker = true }
    }

    private func openFiles() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showFileImporter = true }
    }
}

// MARK: - Attachment card
struct InBodyAttachmentCard: View {
    let attachment: InBodyAttachment
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 6) {
                ZStack(alignment: .bottomLeading) {
                    if let thumb = attachment.thumbnail {
                        Image(uiImage: thumb)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 110, height: 140)
                    } else {
                        Color(.tertiarySystemFill).frame(width: 110, height: 140)
                    }
                    if attachment.kind == .pdf {
                        Text("PDF")
                            .font(.caption2).bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(Color.red)
                            .cornerRadius(6)
                            .padding(6)
                    }
                }
                .frame(width: 110, height: 140)
                .clipped()
                .cornerRadius(12)

                Text(attachment.name)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(width: 110)
            }

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white, Color.black.opacity(0.7))
            }
            .padding(4)
        }
    }
}

// MARK: - Results
struct InBodyResultsView: View {
    let analysis: InBodyAnalysis
    let lm: LanguageManager

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if analysis.weightKg != nil || analysis.bodyFatPercent != nil
                || analysis.muscleMassKg != nil || analysis.bmi != nil {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    if let w = analysis.weightKg {
                        InBodyStatCard(icon: "scalemass.fill", color: .blue,
                                       title: lm.isArabic ? "الوزن" : "Weight",
                                       value: String(format: "%.1f kg", w))
                    }
                    if let f = analysis.bodyFatPercent {
                        InBodyStatCard(icon: "drop.fill", color: .orange,
                                       title: lm.isArabic ? "الدهون" : "Body Fat",
                                       value: String(format: "%.1f%%", f))
                    }
                    if let m = analysis.muscleMassKg {
                        InBodyStatCard(icon: "bolt.fill", color: .green,
                                       title: lm.isArabic ? "العضلات" : "Muscle",
                                       value: String(format: "%.1f kg", m))
                    }
                    if let b = analysis.bmi {
                        InBodyStatCard(icon: "heart.fill", color: .red,
                                       title: "BMI",
                                       value: String(format: "%.1f", b))
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Label(lm.isArabic ? "تحليل الذكاء الاصطناعي" : "AI Analysis",
                      systemImage: "brain.head.profile")
                    .font(.headline).foregroundColor(.green)

                Text(markdown(analysis.summary))
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(14)
            }
        }
    }

    private func markdown(_ text: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
    }
}

struct InBodyStatCard: View {
    let icon: String
    let color: Color
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundColor(color)
            Text(value).font(.title3).bold()
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}

