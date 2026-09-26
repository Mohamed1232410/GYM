//
//  Exercisediagramview.swift
//  GYM
//
//  Created by Mohamed ahmed on 25/05/2026.



import SwiftUI

// MARK: - Exercise Diagram View (main entry point)
struct ExerciseDiagramView: View {
    let exercise: Exercise
    @State private var animationStep: Int = 0
    @State private var isAnimating: Bool = false
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 16) {
            // Movement Animation
            movementDiagram
            // Muscle Highlight Diagram
            muscleMapDiagram
        }
    }

    // MARK: - Movement Diagram
    var movementDiagram: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Movement", systemImage: "figure.mixed.cardio")
                    .font(.headline)
                Spacer()
                Button(action: toggleAnimation) {
                    HStack(spacing: 4) {
                        Image(systemName: isAnimating ? "pause.circle.fill" : "play.circle.fill")
                        Text(isAnimating ? "Pause" : "Animate")
                            .font(.caption)
                    }
                    .foregroundColor(.green)
                }
            }

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))

                ExerciseMovementSVG(exercise: exercise, step: animationStep)
                    .frame(height: 200)
                    .padding()
            }
            .frame(height: 220)

            // Step indicators
            HStack(spacing: 6) {
                ForEach(0..<exerciseStepCount, id: \.self) { i in
                    Capsule()
                        .fill(i == animationStep ? Color.green : Color.secondary.opacity(0.3))
                        .frame(width: i == animationStep ? 20 : 8, height: 6)
                }
            }
            .animation(.spring(), value: animationStep)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: - Muscle Map
    var muscleMapDiagram: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Muscles Targeted", systemImage: "bolt.heart.fill")
                .font(.headline)

            HStack(spacing: 16) {
                // Front body
                VStack(spacing: 4) {
                    Text("Front").font(.caption2).foregroundColor(.secondary)
                    BodyMapSVG(
                        muscleGroups: exercise.muscleGroups,
                        view: .front
                    )
                    .frame(width: 130, height: 200)
                }
                // Back body
                VStack(spacing: 4) {
                    Text("Back").font(.caption2).foregroundColor(.secondary)
                    BodyMapSVG(
                        muscleGroups: exercise.muscleGroups,
                        view: .back
                    )
                    .frame(width: 130, height: 200)
                }
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    Text("Legend").font(.caption2).foregroundColor(.secondary)
                    LegendRow(color: .red, label: "Primary")
                    LegendRow(color: .orange, label: "Secondary")
                    LegendRow(color: Color(.systemGray4), label: "Inactive")
                    Divider()
                    ForEach(exercise.muscleGroups, id: \.self) { mg in
                        HStack(spacing: 6) {
                            Circle().fill(Color.red).frame(width: 7, height: 7)
                            Text(mg.rawValue)
                                .font(.caption2)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }

    var exerciseStepCount: Int {
        ExerciseMovementSVG.stepCount(for: exercise)
    }

    func toggleAnimation() {
        if isAnimating {
            timer?.invalidate()
            timer = nil
            isAnimating = false
        } else {
            isAnimating = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
                animationStep = (animationStep + 1) % exerciseStepCount
            }
        }
    }
}

struct LegendRow: View {
    let color: Color
    let label: String
    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color.opacity(0.7))
                .frame(width: 14, height: 10)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
    }
}

// MARK: - Body Map SVG (front & back human outline with highlights)
enum BodyView { case front, back }

struct BodyMapSVG: View {
    let muscleGroups: [MuscleGroup]
    let view: BodyView

    func color(for muscle: MuscleGroup) -> Color {
        muscleGroups.contains(muscle) ? .red : Color(.systemGray5)
    }

    var body: some View {
        if view == .front {
            frontBody
        } else {
            backBody
        }
    }

    // MARK: Front Body
    var frontBody: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let sx = w / 100, sy = h / 200

            // ── Helper closures ──────────────────────────────────────────
            func fill(_ path: Path, _ color: Color, opacity: Double = 0.75) {
                ctx.fill(path, with: .color(color.opacity(opacity)))
                ctx.stroke(path, with: .color(.white.opacity(0.5)), lineWidth: 0.5)
            }

            // Head
            var head = Path()
            head.addEllipse(in: CGRect(x: 38*sx, y: 2*sy, width: 24*sx, height: 22*sy))
            fill(head, .gray, opacity: 0.35)

            // Neck
            var neck = Path()
            neck.addRect(CGRect(x: 45*sx, y: 23*sy, width: 10*sx, height: 7*sy))
            fill(neck, .gray, opacity: 0.3)

            // Chest (Pectorals)
            var chestL = Path()
            chestL.move(to: CGPoint(x: 30*sx, y: 31*sy))
            chestL.addCurve(to: CGPoint(x: 49*sx, y: 45*sy),
                            control1: CGPoint(x: 28*sx, y: 38*sy),
                            control2: CGPoint(x: 38*sx, y: 46*sy))
            chestL.addCurve(to: CGPoint(x: 30*sx, y: 31*sy),
                            control1: CGPoint(x: 45*sx, y: 39*sy),
                            control2: CGPoint(x: 35*sx, y: 30*sy))
            fill(chestL, color(for: .chest))

            var chestR = Path()
            chestR.move(to: CGPoint(x: 70*sx, y: 31*sy))
            chestR.addCurve(to: CGPoint(x: 51*sx, y: 45*sy),
                            control1: CGPoint(x: 72*sx, y: 38*sy),
                            control2: CGPoint(x: 62*sx, y: 46*sy))
            chestR.addCurve(to: CGPoint(x: 70*sx, y: 31*sy),
                            control1: CGPoint(x: 55*sx, y: 39*sy),
                            control2: CGPoint(x: 65*sx, y: 30*sy))
            fill(chestR, color(for: .chest))

            // Shoulders (Deltoids)
            var shoulderL = Path()
            shoulderL.addEllipse(in: CGRect(x: 18*sx, y: 28*sy, width: 16*sx, height: 14*sy))
            fill(shoulderL, color(for: .shoulders))

            var shoulderR = Path()
            shoulderR.addEllipse(in: CGRect(x: 66*sx, y: 28*sy, width: 16*sx, height: 14*sy))
            fill(shoulderR, color(for: .shoulders))

            // Abs / Core
            let absColor = color(for: .core)
            for row in 0..<3 {
                for col in 0..<2 {
                    var ab = Path()
                    let x = (CGFloat(43) + CGFloat(col) * 8) * sx
                    let y = (CGFloat(46) + CGFloat(row) * 12) * sy
                    ab.addRoundedRect(in: CGRect(x: x, y: y, width: 7*sx, height: 10*sy),
                                      cornerSize: CGSize(width: 3, height: 3))
                    fill(ab, absColor)
                }
            }

            // Biceps
            var bicepL = Path()
            bicepL.addEllipse(in: CGRect(x: 17*sx, y: 44*sy, width: 12*sx, height: 26*sy))
            fill(bicepL, color(for: .biceps))

            var bicepR = Path()
            bicepR.addEllipse(in: CGRect(x: 71*sx, y: 44*sy, width: 12*sx, height: 26*sy))
            fill(bicepR, color(for: .biceps))

            // Forearms
            var forearmL = Path()
            forearmL.addEllipse(in: CGRect(x: 15*sx, y: 72*sy, width: 11*sx, height: 28*sy))
            fill(forearmL, color(for: .forearms))

            var forearmR = Path()
            forearmR.addEllipse(in: CGRect(x: 74*sx, y: 72*sy, width: 11*sx, height: 28*sy))
            fill(forearmR, color(for: .forearms))

            // Hands
            for xPos in [13.0, 74.0] {
                var hand = Path()
                hand.addEllipse(in: CGRect(x: xPos*sx, y: 101*sy, width: 13*sx, height: 10*sy))
                fill(hand, .gray, opacity: 0.3)
            }

            // Obliques / sides
            var oblL = Path()
            oblL.addEllipse(in: CGRect(x: 28*sx, y: 46*sy, width: 12*sx, height: 30*sy))
            fill(oblL, color(for: .core).opacity(0.5))

            var oblR = Path()
            oblR.addEllipse(in: CGRect(x: 60*sx, y: 46*sy, width: 12*sx, height: 30*sy))
            fill(oblR, color(for: .core).opacity(0.5))

            // Quadriceps
            let quadColor = color(for: .quadriceps)
            var quadL = Path()
            quadL.move(to: CGPoint(x: 34*sx, y: 110*sy))
            quadL.addCurve(to: CGPoint(x: 34*sx, y: 155*sy),
                           control1: CGPoint(x: 26*sx, y: 125*sy),
                           control2: CGPoint(x: 26*sx, y: 145*sy))
            quadL.addCurve(to: CGPoint(x: 47*sx, y: 155*sy),
                           control1: CGPoint(x: 38*sx, y: 160*sy),
                           control2: CGPoint(x: 44*sx, y: 160*sy))
            quadL.addCurve(to: CGPoint(x: 47*sx, y: 110*sy),
                           control1: CGPoint(x: 52*sx, y: 145*sy),
                           control2: CGPoint(x: 52*sx, y: 125*sy))
            quadL.closeSubpath()
            fill(quadL, quadColor)

            var quadR = Path()
            quadR.move(to: CGPoint(x: 66*sx, y: 110*sy))
            quadR.addCurve(to: CGPoint(x: 66*sx, y: 155*sy),
                           control1: CGPoint(x: 74*sx, y: 125*sy),
                           control2: CGPoint(x: 74*sx, y: 145*sy))
            quadR.addCurve(to: CGPoint(x: 53*sx, y: 155*sy),
                           control1: CGPoint(x: 62*sx, y: 160*sy),
                           control2: CGPoint(x: 56*sx, y: 160*sy))
            quadR.addCurve(to: CGPoint(x: 53*sx, y: 110*sy),
                           control1: CGPoint(x: 48*sx, y: 145*sy),
                           control2: CGPoint(x: 48*sx, y: 125*sy))
            quadR.closeSubpath()
            fill(quadR, quadColor)

            // Calves (front tibialis)
            let calfColor = color(for: .calves)
            var calfL = Path()
            calfL.addEllipse(in: CGRect(x: 30*sx, y: 158*sy, width: 16*sx, height: 34*sy))
            fill(calfL, calfColor)

            var calfR = Path()
            calfR.addEllipse(in: CGRect(x: 54*sx, y: 158*sy, width: 16*sx, height: 34*sy))
            fill(calfR, calfColor)

            // Feet
            for xPos in [27.0, 52.0] {
                var foot = Path()
                foot.addEllipse(in: CGRect(x: xPos*sx, y: 191*sy, width: 22*sx, height: 8*sy))
                fill(foot, .gray, opacity: 0.3)
            }

            // Body outline
            var outline = Path()
            outline.move(to: CGPoint(x: 38*sx, y: 30*sy))
            outline.addLine(to: CGPoint(x: 18*sx, y: 35*sy))
            outline.addLine(to: CGPoint(x: 14*sx, y: 72*sy))
            outline.addLine(to: CGPoint(x: 13*sx, y: 100*sy))
            outline.addLine(to: CGPoint(x: 26*sx, y: 100*sy))
            outline.addLine(to: CGPoint(x: 30*sx, y: 110*sy))
            outline.addLine(to: CGPoint(x: 34*sx, y: 192*sy))
            outline.addLine(to: CGPoint(x: 52*sx, y: 192*sy))
            outline.addLine(to: CGPoint(x: 50*sx, y: 108*sy))
            outline.addLine(to: CGPoint(x: 50*sx, y: 108*sy))
            outline.addLine(to: CGPoint(x: 50*sx, y: 108*sy))
            // mirror right side
            outline.move(to: CGPoint(x: 62*sx, y: 30*sy))
            outline.addLine(to: CGPoint(x: 82*sx, y: 35*sy))
            outline.addLine(to: CGPoint(x: 86*sx, y: 72*sy))
            outline.addLine(to: CGPoint(x: 87*sx, y: 100*sy))
            outline.addLine(to: CGPoint(x: 74*sx, y: 100*sy))
            outline.addLine(to: CGPoint(x: 70*sx, y: 110*sy))
            outline.addLine(to: CGPoint(x: 66*sx, y: 192*sy))
            ctx.stroke(outline, with: .color(.secondary.opacity(0.2)), lineWidth: 1)
        }
    }

    // MARK: Back Body
    var backBody: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let sx = w / 100, sy = h / 200

            func fill(_ path: Path, _ color: Color, opacity: Double = 0.75) {
                ctx.fill(path, with: .color(color.opacity(opacity)))
                ctx.stroke(path, with: .color(.white.opacity(0.5)), lineWidth: 0.5)
            }

            // Head
            var head = Path()
            head.addEllipse(in: CGRect(x: 38*sx, y: 2*sy, width: 24*sx, height: 22*sy))
            fill(head, .gray, opacity: 0.35)

            // Neck
            var neck = Path()
            neck.addRect(CGRect(x: 45*sx, y: 23*sy, width: 10*sx, height: 7*sy))
            fill(neck, .gray, opacity: 0.3)

            // Traps
            var trapL = Path()
            trapL.move(to: CGPoint(x: 50*sx, y: 27*sy))
            trapL.addCurve(to: CGPoint(x: 28*sx, y: 42*sy),
                           control1: CGPoint(x: 40*sx, y: 28*sy),
                           control2: CGPoint(x: 28*sx, y: 35*sy))
            trapL.addLine(to: CGPoint(x: 36*sx, y: 50*sy))
            trapL.addLine(to: CGPoint(x: 50*sx, y: 45*sy))
            trapL.closeSubpath()
            fill(trapL, color(for: .back))

            var trapR = Path()
            trapR.move(to: CGPoint(x: 50*sx, y: 27*sy))
            trapR.addCurve(to: CGPoint(x: 72*sx, y: 42*sy),
                           control1: CGPoint(x: 60*sx, y: 28*sy),
                           control2: CGPoint(x: 72*sx, y: 35*sy))
            trapR.addLine(to: CGPoint(x: 64*sx, y: 50*sy))
            trapR.addLine(to: CGPoint(x: 50*sx, y: 45*sy))
            trapR.closeSubpath()
            fill(trapR, color(for: .back))

            // Rear Deltoids
            var rDelL = Path()
            rDelL.addEllipse(in: CGRect(x: 18*sx, y: 28*sy, width: 15*sx, height: 13*sy))
            fill(rDelL, color(for: .shoulders))

            var rDelR = Path()
            rDelR.addEllipse(in: CGRect(x: 67*sx, y: 28*sy, width: 15*sx, height: 13*sy))
            fill(rDelR, color(for: .shoulders))

            // Lats (Back)
            let backColor = color(for: .back)
            var latL = Path()
            latL.move(to: CGPoint(x: 30*sx, y: 42*sy))
            latL.addCurve(to: CGPoint(x: 36*sx, y: 84*sy),
                          control1: CGPoint(x: 22*sx, y: 55*sy),
                          control2: CGPoint(x: 24*sx, y: 75*sy))
            latL.addLine(to: CGPoint(x: 48*sx, y: 84*sy))
            latL.addLine(to: CGPoint(x: 50*sx, y: 42*sy))
            latL.closeSubpath()
            fill(latL, backColor)

            var latR = Path()
            latR.move(to: CGPoint(x: 70*sx, y: 42*sy))
            latR.addCurve(to: CGPoint(x: 64*sx, y: 84*sy),
                          control1: CGPoint(x: 78*sx, y: 55*sy),
                          control2: CGPoint(x: 76*sx, y: 75*sy))
            latR.addLine(to: CGPoint(x: 52*sx, y: 84*sy))
            latR.addLine(to: CGPoint(x: 50*sx, y: 42*sy))
            latR.closeSubpath()
            fill(latR, backColor)

            // Lower Back / Erectors
            var erector = Path()
            erector.addRoundedRect(in: CGRect(x: 42*sx, y: 80*sy, width: 16*sx, height: 28*sy),
                                   cornerSize: CGSize(width: 5, height: 5))
            fill(erector, color(for: .back).opacity(0.6))

            // Triceps
            var triL = Path()
            triL.addEllipse(in: CGRect(x: 17*sx, y: 44*sy, width: 11*sx, height: 26*sy))
            fill(triL, color(for: .triceps))

            var triR = Path()
            triR.addEllipse(in: CGRect(x: 72*sx, y: 44*sy, width: 11*sx, height: 26*sy))
            fill(triR, color(for: .triceps))

            // Forearms
            var forearmL = Path()
            forearmL.addEllipse(in: CGRect(x: 15*sx, y: 72*sy, width: 11*sx, height: 28*sy))
            fill(forearmL, color(for: .forearms))

            var forearmR = Path()
            forearmR.addEllipse(in: CGRect(x: 74*sx, y: 72*sy, width: 11*sx, height: 28*sy))
            fill(forearmR, color(for: .forearms))

            // Glutes
            let gluteColor = color(for: .glutes)
            var gluteL = Path()
            gluteL.addEllipse(in: CGRect(x: 33*sx, y: 104*sy, width: 20*sx, height: 20*sy))
            fill(gluteL, gluteColor)

            var gluteR = Path()
            gluteR.addEllipse(in: CGRect(x: 47*sx, y: 104*sy, width: 20*sx, height: 20*sy))
            fill(gluteR, gluteColor)

            // Hamstrings
            let hamColor = color(for: .hamstrings)
            var hamL = Path()
            hamL.move(to: CGPoint(x: 33*sx, y: 122*sy))
            hamL.addCurve(to: CGPoint(x: 33*sx, y: 158*sy),
                          control1: CGPoint(x: 25*sx, y: 135*sy),
                          control2: CGPoint(x: 25*sx, y: 148*sy))
            hamL.addLine(to: CGPoint(x: 48*sx, y: 158*sy))
            hamL.addCurve(to: CGPoint(x: 48*sx, y: 122*sy),
                          control1: CGPoint(x: 53*sx, y: 148*sy),
                          control2: CGPoint(x: 53*sx, y: 135*sy))
            hamL.closeSubpath()
            fill(hamL, hamColor)

            var hamR = Path()
            hamR.move(to: CGPoint(x: 67*sx, y: 122*sy))
            hamR.addCurve(to: CGPoint(x: 67*sx, y: 158*sy),
                          control1: CGPoint(x: 75*sx, y: 135*sy),
                          control2: CGPoint(x: 75*sx, y: 148*sy))
            hamR.addLine(to: CGPoint(x: 52*sx, y: 158*sy))
            hamR.addCurve(to: CGPoint(x: 52*sx, y: 122*sy),
                          control1: CGPoint(x: 47*sx, y: 148*sy),
                          control2: CGPoint(x: 47*sx, y: 135*sy))
            hamR.closeSubpath()
            fill(hamR, hamColor)

            // Calves
            let calfColor = color(for: .calves)
            var calfL = Path()
            calfL.addEllipse(in: CGRect(x: 30*sx, y: 158*sy, width: 16*sx, height: 34*sy))
            fill(calfL, calfColor)

            var calfR = Path()
            calfR.addEllipse(in: CGRect(x: 54*sx, y: 158*sy, width: 16*sx, height: 34*sy))
            fill(calfR, calfColor)

            // Feet
            for xPos in [27.0, 52.0] {
                var foot = Path()
                foot.addEllipse(in: CGRect(x: xPos*sx, y: 191*sy, width: 22*sx, height: 8*sy))
                fill(foot, .gray, opacity: 0.3)
            }
        }
    }
}

// MARK: - Exercise Movement SVG (step-by-step animation frames)
struct ExerciseMovementSVG: View {
    let exercise: Exercise
    let step: Int

    static func stepCount(for exercise: Exercise) -> Int {
        movementSteps(for: exercise).count
    }

    var body: some View {
        let steps = ExerciseMovementSVG.movementSteps(for: exercise)
        let current = steps[safe: step] ?? steps[0]
        return AnyView(current)
    }

    static func movementSteps(for exercise: Exercise) -> [AnyView] {
        switch exercise.name {
        case "Barbell Bench Press":   return benchPressSteps()
        case "Push-Up":               return pushUpSteps()
        case "Dumbbell Flyes":        return flyeSteps()
        case "Pull-Up":               return pullUpSteps()
        case "Barbell Row":           return barbellRowSteps()
        case "Barbell Back Squat":    return squatSteps()
        case "Romanian Deadlift":     return rdlSteps()
        case "Goblet Squat":          return gobletSquatSteps()
        case "Overhead Press":        return ohpSteps()
        case "Plank":                 return plankSteps()
        case "Russian Twist":         return russianTwistSteps()
        case "Burpee":                return burpeeSteps()
        case "Mountain Climbers":     return mountainClimberSteps()
        default:                      return genericSteps(exercise: exercise)
        }
    }

    // MARK: - Bench Press
    static func benchPressSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "Start Position", description: "Lie flat, grip bar above chest, arms locked out") {
            BenchPressSVG(phase: .top)
        }),
        AnyView(MovementFrame(title: "Lower Phase", description: "Control bar down to mid-chest, elbows ~45°") {
            BenchPressSVG(phase: .bottom)
        }),
        AnyView(MovementFrame(title: "Press Up", description: "Drive bar up explosively, squeeze chest at top") {
            BenchPressSVG(phase: .top)
        })
    ]}

    // MARK: - Push-Up
    static func pushUpSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "High Plank", description: "Arms straight, body rigid from head to heel") {
            PushUpSVG(phase: .top)
        }),
        AnyView(MovementFrame(title: "Lower Down", description: "Bend elbows, chest toward floor") {
            PushUpSVG(phase: .bottom)
        }),
        AnyView(MovementFrame(title: "Push Up", description: "Extend arms, squeeze chest & triceps") {
            PushUpSVG(phase: .top)
        })
    ]}

    // MARK: - Flyes
    static func flyeSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "Arms Extended", description: "Dumbbells above chest, slight elbow bend") {
            FlyeSVG(phase: .top)
        }),
        AnyView(MovementFrame(title: "Open Arc", description: "Lower arms wide, feel chest stretch") {
            FlyeSVG(phase: .bottom)
        }),
        AnyView(MovementFrame(title: "Close Arc", description: "Bring dumbbells together, squeeze pecs") {
            FlyeSVG(phase: .top)
        })
    ]}

    // MARK: - Pull-Up
    static func pullUpSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "Dead Hang", description: "Hang from bar, arms fully extended, shoulders engaged") {
            PullUpSVG(phase: .bottom)
        }),
        AnyView(MovementFrame(title: "Pull Up", description: "Drive elbows down and back, chin over bar") {
            PullUpSVG(phase: .top)
        }),
        AnyView(MovementFrame(title: "Lower Down", description: "Control the descent over 2 seconds") {
            PullUpSVG(phase: .bottom)
        })
    ]}

    // MARK: - Barbell Row
    static func barbellRowSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "Hip Hinge", description: "Hinge forward ~45°, back flat, bar hanging") {
            RowSVG(phase: .bottom)
        }),
        AnyView(MovementFrame(title: "Pull to Stomach", description: "Row bar to lower chest, squeeze shoulder blades") {
            RowSVG(phase: .top)
        }),
        AnyView(MovementFrame(title: "Lower with Control", description: "Extend arms slowly, maintain back angle") {
            RowSVG(phase: .bottom)
        })
    ]}

    // MARK: - Squat
    static func squatSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "Set Up", description: "Bar on upper traps, feet shoulder-width apart") {
            SquatSVG(phase: .top)
        }),
        AnyView(MovementFrame(title: "Break at Hips & Knees", description: "Sit back and down, knees track toes") {
            SquatSVG(phase: .mid)
        }),
        AnyView(MovementFrame(title: "Full Depth", description: "Thighs parallel, chest up, heels down") {
            SquatSVG(phase: .bottom)
        }),
        AnyView(MovementFrame(title: "Drive Up", description: "Push through heels, extend hips and knees together") {
            SquatSVG(phase: .top)
        })
    ]}

    // MARK: - RDL
    static func rdlSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "Stand Tall", description: "Bar at hips, soft knee bend, neutral spine") {
            RDLSVG(phase: .top)
        }),
        AnyView(MovementFrame(title: "Hip Hinge", description: "Push hips back, bar slides down thighs") {
            RDLSVG(phase: .bottom)
        }),
        AnyView(MovementFrame(title: "Feel the Stretch", description: "Feel hamstrings load, back stays flat") {
            RDLSVG(phase: .bottom)
        }),
        AnyView(MovementFrame(title: "Drive Hips Forward", description: "Contract hamstrings & glutes to stand") {
            RDLSVG(phase: .top)
        })
    ]}

    // MARK: - Goblet Squat
    static func gobletSquatSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "Hold Dumbbell", description: "Cup dumbbell at chest, feet wide, toes out") {
            GobletSquatSVG(phase: .top)
        }),
        AnyView(MovementFrame(title: "Squat Deep", description: "Drop between knees, elbows inside thighs") {
            GobletSquatSVG(phase: .bottom)
        }),
        AnyView(MovementFrame(title: "Stand Up", description: "Drive through heels, squeeze glutes at top") {
            GobletSquatSVG(phase: .top)
        })
    ]}

    // MARK: - OHP
    static func ohpSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "Rack Position", description: "Bar at collarbone, elbows slightly forward") {
            OHPSVG(phase: .bottom)
        }),
        AnyView(MovementFrame(title: "Press Overhead", description: "Drive bar straight up, lock out arms") {
            OHPSVG(phase: .top)
        }),
        AnyView(MovementFrame(title: "Lower with Control", description: "Return bar to collarbone, stay tight") {
            OHPSVG(phase: .bottom)
        })
    ]}

    // MARK: - Plank
    static func plankSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "Forearm Plank", description: "Elbows under shoulders, body straight") {
            PlankSVG(phase: .top)
        }),
        AnyView(MovementFrame(title: "Squeeze Everything", description: "Core tight, glutes squeezed, breathe steadily") {
            PlankSVG(phase: .top)
        })
    ]}

    // MARK: - Russian Twist
    static func russianTwistSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "Sit Back", description: "Lean back ~45°, knees bent, hold weight at chest") {
            RussianTwistSVG(phase: .center)
        }),
        AnyView(MovementFrame(title: "Rotate Left", description: "Twist torso left, weight toward floor") {
            RussianTwistSVG(phase: .left)
        }),
        AnyView(MovementFrame(title: "Rotate Right", description: "Twist torso right, weight toward floor") {
            RussianTwistSVG(phase: .right)
        })
    ]}

    // MARK: - Burpee
    static func burpeeSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "Stand", description: "Starting position — feet shoulder-width") {
            BurpeeSVG(phase: .stand)
        }),
        AnyView(MovementFrame(title: "Drop to Plank", description: "Hands down, jump feet back to push-up position") {
            BurpeeSVG(phase: .plank)
        }),
        AnyView(MovementFrame(title: "Push-Up", description: "Chest to floor, then push back up") {
            BurpeeSVG(phase: .pushup)
        }),
        AnyView(MovementFrame(title: "Jump Up", description: "Jump feet to hands, then explode upward") {
            BurpeeSVG(phase: .jump)
        })
    ]}

    // MARK: - Mountain Climbers
    static func mountainClimberSteps() -> [AnyView] {[
        AnyView(MovementFrame(title: "High Plank", description: "Arms straight, strong core, neutral spine") {
            MountainClimberSVG(phase: .start)
        }),
        AnyView(MovementFrame(title: "Drive Right Knee", description: "Pull right knee to chest rapidly") {
            MountainClimberSVG(phase: .rightKnee)
        }),
        AnyView(MovementFrame(title: "Drive Left Knee", description: "Alternate — pull left knee to chest") {
            MountainClimberSVG(phase: .leftKnee)
        })
    ]}

    // MARK: - Generic fallback
    static func genericSteps(exercise: Exercise) -> [AnyView] {[
        AnyView(MovementFrame(title: "Start Position", description: exercise.instructions.first ?? "Get into position") {
            GenericExerciseSVG(muscleGroups: exercise.muscleGroups)
        }),
        AnyView(MovementFrame(title: "Movement", description: exercise.instructions[safe: 1] ?? "Perform the movement with control") {
            GenericExerciseSVG(muscleGroups: exercise.muscleGroups)
        })
    ]}
}

// MARK: - Movement Frame Wrapper
struct MovementFrame<Content: View>: View {
    let title: String
    let description: String
    let content: () -> Content

    var body: some View {
        VStack(spacing: 8) {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline).bold()
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Individual Exercise SVGs

enum ExercisePhase { case top, bottom, mid }

// Bench Press
struct BenchPressSVG: View {
    let phase: ExercisePhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            // Bench
            drawRect(ctx, CGRect(x: w*0.1, y: h*0.65, width: w*0.8, height: h*0.08), color: .brown)
            // Body
            drawRect(ctx, CGRect(x: w*0.2, y: h*0.45, width: w*0.6, height: h*0.2), color: .blue.opacity(0.6))
            // Head
            drawCircle(ctx, center: CGPoint(x: w*0.82, y: h*0.38), radius: w*0.07, color: .orange.opacity(0.8))
            // Arms
            let armY = phase == .top ? h*0.25 : h*0.55
            drawLine(ctx, from: CGPoint(x: w*0.3, y: h*0.45), to: CGPoint(x: w*0.25, y: armY), color: .blue.opacity(0.7), width: 6)
            drawLine(ctx, from: CGPoint(x: w*0.7, y: h*0.45), to: CGPoint(x: w*0.75, y: armY), color: .blue.opacity(0.7), width: 6)
            // Barbell
            drawLine(ctx, from: CGPoint(x: w*0.1, y: armY), to: CGPoint(x: w*0.9, y: armY), color: .gray, width: 5)
            drawCircle(ctx, center: CGPoint(x: w*0.12, y: armY), radius: 8, color: .gray.opacity(0.8))
            drawCircle(ctx, center: CGPoint(x: w*0.88, y: armY), radius: 8, color: .gray.opacity(0.8))
            // Arrow
            let arrowDir: CGFloat = phase == .top ? 1 : -1
            drawArrow(ctx, from: CGPoint(x: w*0.5, y: armY + arrowDir*h*0.06),
                      to: CGPoint(x: w*0.5, y: armY + arrowDir*h*0.14), color: .green)
        }
    }
}

// Push-Up
struct PushUpSVG: View {
    let phase: ExercisePhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let bodyY: CGFloat = phase == .top ? h*0.4 : h*0.55
            // Body
            drawLine(ctx, from: CGPoint(x: w*0.15, y: h*0.7), to: CGPoint(x: w*0.85, y: bodyY - h*0.05), color: .blue.opacity(0.7), width: 10)
            // Head
            drawCircle(ctx, center: CGPoint(x: w*0.88, y: bodyY - h*0.12), radius: w*0.07, color: .orange.opacity(0.8))
            // Arms
            drawLine(ctx, from: CGPoint(x: w*0.72, y: bodyY), to: CGPoint(x: w*0.68, y: h*0.72), color: .blue.opacity(0.7), width: 6)
            // Feet
            drawLine(ctx, from: CGPoint(x: w*0.15, y: h*0.7), to: CGPoint(x: w*0.1, y: h*0.75), color: .blue.opacity(0.7), width: 6)
            // Ground
            drawLine(ctx, from: CGPoint(x: w*0.05, y: h*0.78), to: CGPoint(x: w*0.95, y: h*0.78), color: .secondary.opacity(0.4), width: 2)
            // Arrow
            let arrowY: CGFloat = phase == .top ? h*0.25 : h*0.62
            drawArrow(ctx, from: CGPoint(x: w*0.5, y: arrowY), to: CGPoint(x: w*0.5, y: arrowY + h*0.12), color: .green)
        }
    }
}

// Flye
struct FlyeSVG: View {
    let phase: ExercisePhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            // Bench
            drawRect(ctx, CGRect(x: w*0.15, y: h*0.62, width: w*0.7, height: h*0.07), color: .brown)
            // Body
            drawRect(ctx, CGRect(x: w*0.25, y: h*0.44, width: w*0.5, height: h*0.18), color: .blue.opacity(0.6))
            // Head
            drawCircle(ctx, center: CGPoint(x: w*0.8, y: h*0.37), radius: w*0.07, color: .orange.opacity(0.8))
            // Arms — open in bottom phase
            let leftArmEnd = phase == .top ? CGPoint(x: w*0.25, y: h*0.3) : CGPoint(x: w*0.05, y: h*0.52)
            let rightArmEnd = phase == .top ? CGPoint(x: w*0.75, y: h*0.3) : CGPoint(x: w*0.95, y: h*0.52)
            drawLine(ctx, from: CGPoint(x: w*0.35, y: h*0.44), to: leftArmEnd, color: .blue.opacity(0.7), width: 6)
            drawLine(ctx, from: CGPoint(x: w*0.65, y: h*0.44), to: rightArmEnd, color: .blue.opacity(0.7), width: 6)
            // Dumbbells
            drawCircle(ctx, center: leftArmEnd, radius: 7, color: .gray)
            drawCircle(ctx, center: rightArmEnd, radius: 7, color: .gray)
        }
    }
}

// Pull-Up
struct PullUpSVG: View {
    let phase: ExercisePhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            // Bar
            drawLine(ctx, from: CGPoint(x: w*0.1, y: h*0.1), to: CGPoint(x: w*0.9, y: h*0.1), color: .gray, width: 6)
            // Body position
            let bodyTop: CGFloat = phase == .top ? h*0.2 : h*0.45
            // Arms
            drawLine(ctx, from: CGPoint(x: w*0.35, y: h*0.1), to: CGPoint(x: w*0.38, y: bodyTop), color: .blue.opacity(0.7), width: 6)
            drawLine(ctx, from: CGPoint(x: w*0.65, y: h*0.1), to: CGPoint(x: w*0.62, y: bodyTop), color: .blue.opacity(0.7), width: 6)
            // Torso
            drawRect(ctx, CGRect(x: w*0.38, y: bodyTop, width: w*0.24, height: h*0.25), color: .blue.opacity(0.6))
            // Head
            drawCircle(ctx, center: CGPoint(x: w*0.5, y: bodyTop - h*0.06), radius: w*0.07, color: .orange.opacity(0.8))
            // Legs
            drawLine(ctx, from: CGPoint(x: w*0.44, y: bodyTop + h*0.25), to: CGPoint(x: w*0.42, y: bodyTop + h*0.42), color: .blue.opacity(0.7), width: 6)
            drawLine(ctx, from: CGPoint(x: w*0.56, y: bodyTop + h*0.25), to: CGPoint(x: w*0.58, y: bodyTop + h*0.42), color: .blue.opacity(0.7), width: 6)
            // Arrow
            let arrowDir: CGFloat = phase == .bottom ? -1 : 1
            drawArrow(ctx, from: CGPoint(x: w*0.82, y: h*0.5),
                      to: CGPoint(x: w*0.82, y: h*0.5 + arrowDir*h*0.15), color: .green)
        }
    }
}

// Row
struct RowSVG: View {
    let phase: ExercisePhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            // Torso (hinged)
            drawLine(ctx, from: CGPoint(x: w*0.25, y: h*0.55), to: CGPoint(x: w*0.75, y: h*0.3), color: .blue.opacity(0.7), width: 10)
            // Head
            drawCircle(ctx, center: CGPoint(x: w*0.82, y: h*0.24), radius: w*0.07, color: .orange.opacity(0.8))
            // Legs
            drawLine(ctx, from: CGPoint(x: w*0.25, y: h*0.55), to: CGPoint(x: w*0.22, y: h*0.8), color: .blue.opacity(0.7), width: 8)
            drawLine(ctx, from: CGPoint(x: w*0.3, y: h*0.56), to: CGPoint(x: w*0.35, y: h*0.8), color: .blue.opacity(0.7), width: 8)
            // Arms
            let barY: CGFloat = phase == .top ? h*0.48 : h*0.7
            drawLine(ctx, from: CGPoint(x: w*0.55, y: h*0.38), to: CGPoint(x: w*0.52, y: barY), color: .blue.opacity(0.7), width: 6)
            drawLine(ctx, from: CGPoint(x: w*0.65, y: h*0.35), to: CGPoint(x: w*0.65, y: barY), color: .blue.opacity(0.7), width: 6)
            // Barbell
            drawLine(ctx, from: CGPoint(x: w*0.3, y: barY), to: CGPoint(x: w*0.8, y: barY), color: .gray, width: 5)
            drawCircle(ctx, center: CGPoint(x: w*0.31, y: barY), radius: 7, color: .gray.opacity(0.8))
            drawCircle(ctx, center: CGPoint(x: w*0.79, y: barY), radius: 7, color: .gray.opacity(0.8))
            // Ground
            drawLine(ctx, from: CGPoint(x: w*0.05, y: h*0.82), to: CGPoint(x: w*0.95, y: h*0.82), color: .secondary.opacity(0.3), width: 2)
            // Arrow
            drawArrow(ctx, from: CGPoint(x: w*0.58, y: barY + h*0.04),
                      to: CGPoint(x: w*0.58, y: barY + (phase == .top ? -h*0.15 : h*0.0)), color: .green)
        }
    }
}

// Squat
struct SquatSVG: View {
    let phase: ExercisePhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let hipY: CGFloat
            let kneeY: CGFloat
            switch phase {
            case .top:    hipY = h*0.45; kneeY = h*0.72
            case .mid:    hipY = h*0.56; kneeY = h*0.74
            case .bottom: hipY = h*0.68; kneeY = h*0.76
            }
            // Head
            drawCircle(ctx, center: CGPoint(x: w*0.5, y: h*0.14), radius: w*0.08, color: .orange.opacity(0.8))
            // Torso
            drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.22), to: CGPoint(x: w*0.5, y: hipY), color: .blue.opacity(0.7), width: 10)
            // Barbell
            drawLine(ctx, from: CGPoint(x: w*0.15, y: h*0.25), to: CGPoint(x: w*0.85, y: h*0.25), color: .gray, width: 5)
            drawCircle(ctx, center: CGPoint(x: w*0.16, y: h*0.25), radius: 8, color: .gray.opacity(0.8))
            drawCircle(ctx, center: CGPoint(x: w*0.84, y: h*0.25), radius: 8, color: .gray.opacity(0.8))
            // Arms
            drawLine(ctx, from: CGPoint(x: w*0.32, y: h*0.25), to: CGPoint(x: w*0.38, y: h*0.3), color: .blue.opacity(0.6), width: 5)
            drawLine(ctx, from: CGPoint(x: w*0.68, y: h*0.25), to: CGPoint(x: w*0.62, y: h*0.3), color: .blue.opacity(0.6), width: 5)
            // Upper legs
            drawLine(ctx, from: CGPoint(x: w*0.5, y: hipY), to: CGPoint(x: w*0.35, y: kneeY), color: .blue.opacity(0.7), width: 8)
            drawLine(ctx, from: CGPoint(x: w*0.5, y: hipY), to: CGPoint(x: w*0.65, y: kneeY), color: .blue.opacity(0.7), width: 8)
            // Lower legs
            drawLine(ctx, from: CGPoint(x: w*0.35, y: kneeY), to: CGPoint(x: w*0.3, y: h*0.9), color: .blue.opacity(0.7), width: 7)
            drawLine(ctx, from: CGPoint(x: w*0.65, y: kneeY), to: CGPoint(x: w*0.7, y: h*0.9), color: .blue.opacity(0.7), width: 7)
            // Ground
            drawLine(ctx, from: CGPoint(x: w*0.1, y: h*0.92), to: CGPoint(x: w*0.9, y: h*0.92), color: .secondary.opacity(0.3), width: 2)
            // Depth arrow
            if phase != .top {
                drawArrow(ctx, from: CGPoint(x: w*0.88, y: h*0.4),
                          to: CGPoint(x: w*0.88, y: h*0.6), color: .green)
            }
        }
    }
}

// RDL
struct RDLSVG: View {
    let phase: ExercisePhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let isBottom = phase == .bottom
            // Head
            let headY: CGFloat = isBottom ? h*0.22 : h*0.14
            let headX: CGFloat = isBottom ? w*0.72 : w*0.5
            drawCircle(ctx, center: CGPoint(x: headX, y: headY), radius: w*0.07, color: .orange.opacity(0.8))
            // Spine / torso
            let spineEnd = isBottom ? CGPoint(x: w*0.28, y: h*0.48) : CGPoint(x: w*0.5, y: h*0.52)
            drawLine(ctx, from: CGPoint(x: headX, y: headY + w*0.07),
                     to: spineEnd, color: .blue.opacity(0.7), width: 10)
            // Hips → knee
            drawLine(ctx, from: spineEnd, to: CGPoint(x: w*0.42, y: h*0.72), color: .blue.opacity(0.7), width: 8)
            drawLine(ctx, from: spineEnd, to: CGPoint(x: w*0.58, y: h*0.72), color: .blue.opacity(0.7), width: 8)
            // Lower leg
            drawLine(ctx, from: CGPoint(x: w*0.42, y: h*0.72), to: CGPoint(x: w*0.4, y: h*0.92), color: .blue.opacity(0.7), width: 7)
            drawLine(ctx, from: CGPoint(x: w*0.58, y: h*0.72), to: CGPoint(x: w*0.6, y: h*0.92), color: .blue.opacity(0.7), width: 7)
            // Bar
            let barY: CGFloat = isBottom ? h*0.6 : h*0.45
            drawLine(ctx, from: CGPoint(x: w*0.15, y: barY), to: CGPoint(x: w*0.85, y: barY), color: .gray, width: 5)
            drawCircle(ctx, center: CGPoint(x: w*0.16, y: barY), radius: 7, color: .gray.opacity(0.8))
            drawCircle(ctx, center: CGPoint(x: w*0.84, y: barY), radius: 7, color: .gray.opacity(0.8))
            // Ground
            drawLine(ctx, from: CGPoint(x: w*0.1, y: h*0.93), to: CGPoint(x: w*0.9, y: h*0.93), color: .secondary.opacity(0.3), width: 2)
        }
    }
}

// Goblet Squat
struct GobletSquatSVG: View {
    let phase: ExercisePhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let isBottom = phase == .bottom
            let hipY: CGFloat = isBottom ? h*0.62 : h*0.44
            let kneeY: CGFloat = isBottom ? h*0.75 : h*0.72
            // Head
            drawCircle(ctx, center: CGPoint(x: w*0.5, y: h*0.13), radius: w*0.08, color: .orange.opacity(0.8))
            // Torso
            drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.21), to: CGPoint(x: w*0.5, y: hipY), color: .blue.opacity(0.7), width: 10)
            // Dumbbell held at chest
            let dbY: CGFloat = isBottom ? h*0.4 : h*0.3
            drawRect(ctx, CGRect(x: w*0.42, y: dbY, width: w*0.16, height: h*0.06), color: .gray.opacity(0.8))
            // Arms holding db
            drawLine(ctx, from: CGPoint(x: w*0.38, y: h*0.35), to: CGPoint(x: w*0.44, y: dbY + h*0.03), color: .blue.opacity(0.6), width: 5)
            drawLine(ctx, from: CGPoint(x: w*0.62, y: h*0.35), to: CGPoint(x: w*0.56, y: dbY + h*0.03), color: .blue.opacity(0.6), width: 5)
            // Legs
            drawLine(ctx, from: CGPoint(x: w*0.5, y: hipY), to: CGPoint(x: w*0.33, y: kneeY), color: .blue.opacity(0.7), width: 8)
            drawLine(ctx, from: CGPoint(x: w*0.5, y: hipY), to: CGPoint(x: w*0.67, y: kneeY), color: .blue.opacity(0.7), width: 8)
            drawLine(ctx, from: CGPoint(x: w*0.33, y: kneeY), to: CGPoint(x: w*0.28, y: h*0.92), color: .blue.opacity(0.7), width: 7)
            drawLine(ctx, from: CGPoint(x: w*0.67, y: kneeY), to: CGPoint(x: w*0.72, y: h*0.92), color: .blue.opacity(0.7), width: 7)
            // Ground
            drawLine(ctx, from: CGPoint(x: w*0.1, y: h*0.93), to: CGPoint(x: w*0.9, y: h*0.93), color: .secondary.opacity(0.3), width: 2)
        }
    }
}

// OHP
struct OHPSVG: View {
    let phase: ExercisePhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let isTop = phase == .top
            let barY: CGFloat = isTop ? h*0.12 : h*0.35
            // Head
            drawCircle(ctx, center: CGPoint(x: w*0.5, y: isTop ? h*0.22 : h*0.18), radius: w*0.08, color: .orange.opacity(0.8))
            // Torso
            drawLine(ctx, from: CGPoint(x: w*0.5, y: isTop ? h*0.3 : h*0.26),
                     to: CGPoint(x: w*0.5, y: h*0.6), color: .blue.opacity(0.7), width: 10)
            // Arms
            let armAngle: CGFloat = isTop ? 0 : 0.3
            drawLine(ctx, from: CGPoint(x: w*0.4, y: h*0.32), to: CGPoint(x: w*(0.38 - armAngle*0.2), y: barY), color: .blue.opacity(0.7), width: 6)
            drawLine(ctx, from: CGPoint(x: w*0.6, y: h*0.32), to: CGPoint(x: w*(0.62 + armAngle*0.2), y: barY), color: .blue.opacity(0.7), width: 6)
            // Barbell
            drawLine(ctx, from: CGPoint(x: w*0.1, y: barY), to: CGPoint(x: w*0.9, y: barY), color: .gray, width: 5)
            drawCircle(ctx, center: CGPoint(x: w*0.11, y: barY), radius: 7, color: .gray.opacity(0.8))
            drawCircle(ctx, center: CGPoint(x: w*0.89, y: barY), radius: 7, color: .gray.opacity(0.8))
            // Legs
            drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.6), to: CGPoint(x: w*0.4, y: h*0.82), color: .blue.opacity(0.7), width: 8)
            drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.6), to: CGPoint(x: w*0.6, y: h*0.82), color: .blue.opacity(0.7), width: 8)
            drawLine(ctx, from: CGPoint(x: w*0.4, y: h*0.82), to: CGPoint(x: w*0.38, y: h*0.95), color: .blue.opacity(0.7), width: 7)
            drawLine(ctx, from: CGPoint(x: w*0.6, y: h*0.82), to: CGPoint(x: w*0.62, y: h*0.95), color: .blue.opacity(0.7), width: 7)
            // Arrow
            drawArrow(ctx, from: CGPoint(x: w*0.82, y: isTop ? h*0.3 : h*0.18),
                      to: CGPoint(x: w*0.82, y: isTop ? h*0.18 : h*0.3), color: .green)
        }
    }
}

// Plank
struct PlankSVG: View {
    let phase: ExercisePhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            // Body — straight plank
            drawLine(ctx, from: CGPoint(x: w*0.15, y: h*0.65), to: CGPoint(x: w*0.82, y: h*0.5), color: .blue.opacity(0.7), width: 10)
            // Head
            drawCircle(ctx, center: CGPoint(x: w*0.88, y: h*0.44), radius: w*0.07, color: .orange.opacity(0.8))
            // Forearms
            drawLine(ctx, from: CGPoint(x: w*0.68, y: h*0.54), to: CGPoint(x: w*0.65, y: h*0.72), color: .blue.opacity(0.7), width: 6)
            // Feet
            drawLine(ctx, from: CGPoint(x: w*0.15, y: h*0.65), to: CGPoint(x: w*0.1, y: h*0.7), color: .blue.opacity(0.7), width: 6)
            // Ground
            drawLine(ctx, from: CGPoint(x: w*0.05, y: h*0.75), to: CGPoint(x: w*0.95, y: h*0.75), color: .secondary.opacity(0.3), width: 2)
            // Core highlight
            var coreZone = Path()
            coreZone.addEllipse(in: CGRect(x: w*0.42, y: h*0.48, width: w*0.2, height: h*0.1))
            ctx.fill(coreZone, with: .color(.orange.opacity(0.25)))
            ctx.stroke(coreZone, with: .color(.orange.opacity(0.6)), lineWidth: 1.5)
        }
    }
}

// Russian Twist
enum TwistPhase { case center, left, right }
struct RussianTwistSVG: View {
    let phase: TwistPhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            // Torso leaned back
            drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.72), to: CGPoint(x: w*0.5, y: h*0.38), color: .blue.opacity(0.7), width: 10)
            // Head
            drawCircle(ctx, center: CGPoint(x: w*0.5, y: h*0.3), radius: w*0.08, color: .orange.opacity(0.8))
            // Knees up
            drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.72), to: CGPoint(x: w*0.35, y: h*0.62), color: .blue.opacity(0.7), width: 8)
            drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.72), to: CGPoint(x: w*0.65, y: h*0.62), color: .blue.opacity(0.7), width: 8)
            drawLine(ctx, from: CGPoint(x: w*0.35, y: h*0.62), to: CGPoint(x: w*0.3, y: h*0.82), color: .blue.opacity(0.7), width: 7)
            drawLine(ctx, from: CGPoint(x: w*0.65, y: h*0.62), to: CGPoint(x: w*0.7, y: h*0.82), color: .blue.opacity(0.7), width: 7)
            // Weight position
            let weightX: CGFloat = phase == .left ? w*0.22 : (phase == .right ? w*0.78 : w*0.5)
            let weightY: CGFloat = phase == .center ? h*0.5 : h*0.58
            // Arms
            drawLine(ctx, from: CGPoint(x: w*0.44, y: h*0.5), to: weightX == w*0.5 ? CGPoint(x: w*0.5, y: weightY) : CGPoint(x: weightX, y: weightY), color: .blue.opacity(0.6), width: 5)
            drawLine(ctx, from: CGPoint(x: w*0.56, y: h*0.5), to: CGPoint(x: weightX, y: weightY), color: .blue.opacity(0.6), width: 5)
            // Weight
            drawCircle(ctx, center: CGPoint(x: weightX, y: weightY), radius: 12, color: .gray.opacity(0.8))
            // Ground
            drawLine(ctx, from: CGPoint(x: w*0.05, y: h*0.88), to: CGPoint(x: w*0.95, y: h*0.88), color: .secondary.opacity(0.3), width: 2)
            // Rotation arrow
            if phase != .center {
                let arrowX: CGFloat = phase == .left ? w*0.18 : w*0.82
                drawArrow(ctx, from: CGPoint(x: arrowX, y: h*0.4), to: CGPoint(x: arrowX, y: h*0.55), color: .green)
            }
        }
    }
}

// Burpee
enum BurpeePhase { case stand, plank, pushup, jump }
struct BurpeeSVG: View {
    let phase: BurpeePhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            switch phase {
            case .stand:
                drawCircle(ctx, center: CGPoint(x: w*0.5, y: h*0.15), radius: w*0.08, color: .orange.opacity(0.8))
                drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.23), to: CGPoint(x: w*0.5, y: h*0.6), color: .blue.opacity(0.7), width: 10)
                drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.35), to: CGPoint(x: w*0.3, y: h*0.5), color: .blue.opacity(0.6), width: 6)
                drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.35), to: CGPoint(x: w*0.7, y: h*0.5), color: .blue.opacity(0.6), width: 6)
                drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.6), to: CGPoint(x: w*0.4, y: h*0.85), color: .blue.opacity(0.7), width: 8)
                drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.6), to: CGPoint(x: w*0.6, y: h*0.85), color: .blue.opacity(0.7), width: 8)
            case .plank, .pushup:
                let bodyY: CGFloat = phase == .plank ? h*0.45 : h*0.6
                drawLine(ctx, from: CGPoint(x: w*0.15, y: h*0.72), to: CGPoint(x: w*0.82, y: bodyY - h*0.05), color: .blue.opacity(0.7), width: 10)
                drawCircle(ctx, center: CGPoint(x: w*0.88, y: bodyY - h*0.12), radius: w*0.07, color: .orange.opacity(0.8))
                drawLine(ctx, from: CGPoint(x: w*0.7, y: bodyY), to: CGPoint(x: w*0.66, y: h*0.75), color: .blue.opacity(0.7), width: 6)
            case .jump:
                drawCircle(ctx, center: CGPoint(x: w*0.5, y: h*0.1), radius: w*0.08, color: .orange.opacity(0.8))
                drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.18), to: CGPoint(x: w*0.5, y: h*0.52), color: .blue.opacity(0.7), width: 10)
                drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.3), to: CGPoint(x: w*0.22, y: h*0.2), color: .blue.opacity(0.6), width: 6)
                drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.3), to: CGPoint(x: w*0.78, y: h*0.2), color: .blue.opacity(0.6), width: 6)
                drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.52), to: CGPoint(x: w*0.38, y: h*0.72), color: .blue.opacity(0.7), width: 8)
                drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.52), to: CGPoint(x: w*0.62, y: h*0.72), color: .blue.opacity(0.7), width: 8)
                drawArrow(ctx, from: CGPoint(x: w*0.82, y: h*0.35), to: CGPoint(x: w*0.82, y: h*0.18), color: .green)
            }
            drawLine(ctx, from: CGPoint(x: w*0.05, y: h*0.88), to: CGPoint(x: w*0.95, y: h*0.88), color: .secondary.opacity(0.3), width: 2)
        }
    }
}

// Mountain Climbers
enum MCPhase { case start, rightKnee, leftKnee }
struct MountainClimberSVG: View {
    let phase: MCPhase
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            // Body in plank
            drawLine(ctx, from: CGPoint(x: w*0.15, y: h*0.7), to: CGPoint(x: w*0.82, y: h*0.42), color: .blue.opacity(0.7), width: 10)
            // Head
            drawCircle(ctx, center: CGPoint(x: w*0.88, y: h*0.36), radius: w*0.07, color: .orange.opacity(0.8))
            // Arms
            drawLine(ctx, from: CGPoint(x: w*0.72, y: h*0.48), to: CGPoint(x: w*0.68, y: h*0.68), color: .blue.opacity(0.7), width: 6)
            // Left foot
            let leftKneeX: CGFloat = phase == .leftKnee ? w*0.55 : w*0.2
            let leftKneeY: CGFloat = phase == .leftKnee ? h*0.58 : h*0.72
            drawLine(ctx, from: CGPoint(x: w*0.28, y: h*0.66), to: CGPoint(x: leftKneeX, y: leftKneeY), color: .blue.opacity(0.7), width: 7)
            // Right foot
            let rightKneeX: CGFloat = phase == .rightKnee ? w*0.55 : w*0.15
            let rightKneeY: CGFloat = phase == .rightKnee ? h*0.55 : h*0.72
            drawLine(ctx, from: CGPoint(x: w*0.22, y: h*0.68), to: CGPoint(x: rightKneeX, y: rightKneeY), color: .blue.opacity(0.7), width: 7)
            // Ground
            drawLine(ctx, from: CGPoint(x: w*0.05, y: h*0.78), to: CGPoint(x: w*0.95, y: h*0.78), color: .secondary.opacity(0.3), width: 2)
            // Arrow on driving knee
            if phase != .start {
                let arrowX = phase == .rightKnee ? w*0.62 : w*0.62
                drawArrow(ctx, from: CGPoint(x: arrowX, y: h*0.7), to: CGPoint(x: arrowX, y: h*0.52), color: .green)
            }
        }
    }
}

// Generic fallback
struct GenericExerciseSVG: View {
    let muscleGroups: [MuscleGroup]
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            drawCircle(ctx, center: CGPoint(x: w*0.5, y: h*0.15), radius: w*0.08, color: .orange.opacity(0.8))
            drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.23), to: CGPoint(x: w*0.5, y: h*0.6), color: .blue.opacity(0.7), width: 10)
            drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.35), to: CGPoint(x: w*0.28, y: h*0.52), color: .blue.opacity(0.6), width: 6)
            drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.35), to: CGPoint(x: w*0.72, y: h*0.52), color: .blue.opacity(0.6), width: 6)
            drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.6), to: CGPoint(x: w*0.4, y: h*0.85), color: .blue.opacity(0.7), width: 8)
            drawLine(ctx, from: CGPoint(x: w*0.5, y: h*0.6), to: CGPoint(x: w*0.6, y: h*0.85), color: .blue.opacity(0.7), width: 8)
            drawLine(ctx, from: CGPoint(x: w*0.05, y: h*0.9), to: CGPoint(x: w*0.95, y: h*0.9), color: .secondary.opacity(0.3), width: 2)
        }
    }
}

// MARK: - Drawing Helpers
private func drawRect(_ ctx: GraphicsContext, _ rect: CGRect, color: Color) {
    var path = Path(); path.addRoundedRect(in: rect, cornerSize: CGSize(width: 4, height: 4))
    ctx.fill(path, with: .color(color))
}

private func drawCircle(_ ctx: GraphicsContext, center: CGPoint, radius: CGFloat, color: Color) {
    var path = Path()
    path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius,
                               width: radius*2, height: radius*2))
    ctx.fill(path, with: .color(color))
}

private func drawLine(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint, color: Color, width: CGFloat) {
    var path = Path(); path.move(to: from); path.addLine(to: to)
    ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))
}

private func drawArrow(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint, color: Color) {
    drawLine(ctx, from: from, to: to, color: color, width: 2.5)
    let angle = atan2(to.y - from.y, to.x - from.x)
    let len: CGFloat = 8
    let p1 = CGPoint(x: to.x - len * cos(angle - 0.5), y: to.y - len * sin(angle - 0.5))
    let p2 = CGPoint(x: to.x - len * cos(angle + 0.5), y: to.y - len * sin(angle + 0.5))
    var arrowHead = Path()
    arrowHead.move(to: to); arrowHead.addLine(to: p1)
    arrowHead.move(to: to); arrowHead.addLine(to: p2)
    ctx.stroke(arrowHead, with: .color(color), style: StrokeStyle(lineWidth: 2, lineCap: .round))
}
