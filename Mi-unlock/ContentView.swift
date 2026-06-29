import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct ContentView: View {
    @State private var macAddress = ""
    @State private var serialNumber = ""
    @State private var useNewAlgorithm = false
    @State private var showCopiedToast = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case mac, serial
    }

    private var result: String {
        UnlockCalculator.compute(
            macInput: macAddress,
            snInput: serialNumber,
            useNewAlgorithm: useNewAlgorithm
        )
    }

    var body: some View {
        ScrollView {
            GlassEffectContainer(spacing: 18) {
                VStack(spacing: 18) {
                    header

                    VStack(spacing: 16) {
                        GlassField(
                            label: "设备 MAC 地址",
                            placeholder: "00:11:22:33:44:55",
                            text: $macAddress,
                            focus: $focusedField,
                            focusValue: .mac
                        )

                        GlassField(
                            label: "设备 SN 序列号",
                            placeholder: "ABCDE/1234567890",
                            text: $serialNumber,
                            focus: $focusedField,
                            focusValue: .serial
                        )
                    }

                    algorithmPanel

                    if !result.isEmpty {
                        resultPanel
                            .transition(.blurReplace.combined(with: .scale(0.96)))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .overlay(alignment: .bottom) {
            if showCopiedToast {
                GlassToast(message: "解锁码已复制")
                    .padding(.bottom, 28)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: 0.35), value: result.isEmpty)
        .animation(.smooth(duration: 0.25), value: showCopiedToast)
    }

    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(GlassTheme.accent.opacity(0.25))
                    .frame(width: 72, height: 72)
                    .blur(radius: 18)

                Image(systemName: "applewatch.and.arrow.forward")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [GlassTheme.accent, GlassTheme.accentGlow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.bottom, 4)

            Text("小米环表解锁工具")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text("输入 MAC 与 SN，即时生成解锁码")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }

    private var algorithmPanel: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 10) {
                Toggle(isOn: $useNewAlgorithm) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("使用新算法")
                            .font(.body.weight(.semibold))
                        Text("适用于 S5、10 Pro 及以后设备")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(GlassTheme.accent)
            }
        }
    }

    private var resultPanel: some View {
        let isSuccess = result.count == 10

        return GlassPanel {
            VStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: isSuccess ? "checkmark.seal.fill" : "xmark.seal.fill")
                        .foregroundStyle(isSuccess ? GlassTheme.success : GlassTheme.error)
                    Text(isSuccess ? "计算成功" : "计算失败")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Text(result)
                    .font(.system(size: 36, weight: .heavy, design: .monospaced))
                    .tracking(4)
                    .foregroundStyle(
                        isSuccess
                            ? LinearGradient(
                                colors: [GlassTheme.accent, GlassTheme.accentGlow],
                                startPoint: .leading,
                                endPoint: .trailing
                              )
                            : LinearGradient(
                                colors: [GlassTheme.error, GlassTheme.error.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                              )
                    )
                    .shadow(color: isSuccess ? GlassTheme.accent.opacity(0.35) : .clear, radius: 12)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                if isSuccess {
                    Button {
                        copyToClipboard(result)
                    } label: {
                        Label("复制到剪贴板", systemImage: "doc.on.doc")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(GlassTheme.accent)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func copyToClipboard(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif

        showCopiedToast = true
        Task {
            try? await Task.sleep(for: .seconds(1.6))
            showCopiedToast = false
        }
    }
}

#Preview {
    ContentView()
}
