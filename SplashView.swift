import SwiftUI

struct SplashView: View {
    let onFinish: () -> Void

    @State private var appear = false
    @State private var glowPulse = false
    @State private var shimmerPhase: CGFloat = -1
    @State private var parallax: CGSize = .zero

    init(onFinish: @escaping () -> Void = {}) {
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack {
            // Background: deep gradient with subtle animated vignette and parallax
            LinearGradient(colors: AppAppearance.backgroundGradient,
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .overlay(
                    RadialGradient(colors: [Color.white.opacity(0.08), .clear],
                                   center: .center,
                                   startRadius: 2,
                                   endRadius: 520)
                        .blendMode(.screen)
                        .opacity(appear ? 1 : 0)
                        .offset(x: parallax.width * 0.05, y: parallax.height * 0.05)
                        .animation(.easeInOut(duration: 1.0), value: appear)
                )

            VStack(spacing: 22) {
                // Glyph
                Image(systemName: "sparkles")
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundStyle(AppAppearance.brandPrimary.opacity(0.95))
                    .scaleEffect(appear ? 1 : 0.9)
                    .opacity(appear ? 1 : 0)
                    .modifier(GlowModifier(color: AppAppearance.accentGlow, radius: glowPulse ? 22 : 10))
                    .animation(.easeOut(duration: 0.7), value: appear)
                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: glowPulse)

                ZStack {
                    Text("Zenith")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .kerning(0.6)
                        .foregroundStyle(AppAppearance.brandPrimary)
                        .opacity(appear ? 1 : 0)
                        .scaleEffect(appear ? 1 : 0.98)
                        .animation(.spring(response: 0.7, dampingFraction: 0.85), value: appear)
                        .modifier(GlowModifier(color: AppAppearance.accentGlow, radius: glowPulse ? 28 : 12))

                    // Shimmer overlay
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.55), Color.white.opacity(0.0)],
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                        .mask(Text("Zenith").font(.system(size: 46, weight: .bold, design: .rounded)))
                        .frame(height: 52)
                        .offset(x: shimmerPhase * 220)
                        .opacity(appear ? 1 : 0)
                        .animation(.easeInOut(duration: 1.4).delay(0.2), value: appear)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: false)) {
                                shimmerPhase = 1.2
                            }
                        }
                }
            }
            .padding(40)
            .offset(x: parallax.width * 0.02, y: parallax.height * 0.02)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Start subtle animations
            appear = true
            glowPulse = true

            // Auto-finish after configured duration
            DispatchQueue.main.asyncAfter(deadline: .now() + AppAppearance.splashDisplayDuration) {
                onFinish()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    // Light parallax based on touch
                    let w = min(max(value.translation.width, -30), 30)
                    let h = min(max(value.translation.height, -30), 30)
                    parallax = CGSize(width: w / 3, height: h / 3)
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.6)) {
                        parallax = .zero
                    }
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Zenith")
        .accessibilityAddTraits(.isStaticText)
    }
}

struct GlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius)
    }
}

#Preview {
    SplashView()
}
