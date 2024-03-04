//
//  Buttons.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.10.2022.
//

import Foundation
import SwiftUI

struct Buttons {
    
    struct FilledRoundedButton<AdditionalLeadingView: View>: View {
        
        let title: String
        var isEnabled = true
        var isLoading = false
        var fillColor: Color = .darkGreen
        var tint: Color = .cultured
        
        @ViewBuilder var additionalLeadingView: AdditionalLeadingView
        let action: () -> Void
        
        private var _isEnabled: Bool {
            isEnabled && !isLoading
        }
        
        var body: some View {
            Button {
                action()
            } label: {
                HStack(spacing: 8) {
                    additionalLeadingView
                    Text(title)
                        .font(.Secondary.p1Bold)
                        .foregroundColor(_isEnabled ? tint : .middleGrey)
                }
                .transition(.opacity.animation(.linear))
                .animation(.linear, value: _isEnabled)
                .loadingIndicator(isLoading, tint: fillColor)
            }
            .buttonStyle(ButtonStyles.FilledRounded(isEnabled: _isEnabled, fillColor: fillColor))
            .disabled(!_isEnabled)
        }
    }
    
    struct SeeAll: View {
        
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                Text(Strings.Buttons.seeAll.uppercased())
                    .font(kernedFont: .Secondary.p3BoldExtraKerned)
                    .foregroundColor(.orangish)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct PlainEditButton: View {
        
        let onEdit: () -> Void
        
        var body: some View {
            Button {
                onEdit()
            } label: {
                Text(Strings.Buttons.edit.uppercased())
                    .font(kernedFont: .Secondary.p3BoldExtraKerned)
                    .foregroundStyle(Color.brightGold)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct EditButton: View {
        
        let onEdit: () -> Void
        
        var body: some View {
            Button {
                onEdit()
            } label: {
                Text(Strings.Buttons.edit)
                    .font(kernedFont: .Secondary.p1MediumKerned)
                    .foregroundStyle(Color.jet)
                    .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .roundedBorder(Color.middleGrey)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct BackButton: View {
        
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                Image(.backIcon)
                    .renderingMode(.template)
                    .foregroundColor(.white)
            }.buttonStyle(.plain)
        }
    }
    
    struct FillBorderedButton<Content: View>: View {
        
        let title: String
        var isEnabled = true
        var isLoading = false
        var fillColor: Color = Color.silver
        var textColor: Color = .brownJet
        var lineWidth: CGFloat = 1
        
        @ViewBuilder var leadingAsset: Content
        let action: () -> Void
        
        private var _isEnabled: Bool {
            isEnabled && !isLoading
        }
        
        var body: some View {
            Button {
                action()
            } label: {
                HStack(spacing: 4) {
                    leadingAsset
                    Text(title)
                        .font(kernedFont: .Secondary.p2BoldKerned)
                        .foregroundColor(textColor)
                        .minimumScaleFactor(0.9)
                }
                .loadingIndicator(isLoading)
            }
            .buttonStyle(ButtonStyles.BorderedFilled(isEnabled: _isEnabled, lineWidth: lineWidth, borderColor: fillColor))
            .disabled(!_isEnabled)
        }
    }
    
    struct BorderedButton<Content: View>: View {
        
        let title: String
        var isEnabled = true
        var isLoading = false
        var fillColor: Color = Color.silver
        var textColor: Color = .brownJet
        var lineWidth: CGFloat = 1
        
        @ViewBuilder var leadingAsset: Content
        let action: () -> Void
        
        private var _isEnabled: Bool {
            isEnabled && !isLoading
        }
        
        var body: some View {
            Button {
                action()
            } label: {
                HStack(spacing: 8) {
                    leadingAsset
                    Text(title)
                        .font(kernedFont: .Secondary.p2BoldKerned)
                        .foregroundColor(textColor)
                        .minimumScaleFactor(0.9)
                }
                .loadingIndicator(isLoading, tint: .darkGreen)
            }
            .buttonStyle(ButtonStyles.Bordered(isEnabled: _isEnabled, lineWidth: lineWidth, borderColor: fillColor))
            .disabled(!_isEnabled)
        }
    }
    
    struct FillableButton: View {
        
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                Text(title)
                    .font(kernedFont: isSelected ? .Secondary.p2BoldKerned : .Secondary.p1MediumKerned)
                    .foregroundColor(isSelected ? .white : .brownJet)
            }
            .buttonStyle(ButtonStyles.Fillable(isSelected: isSelected))
        }
    }
    
    struct SaveButton: View {
        
        let isEnabled: Bool
        let isLoading: Bool
        let action: () -> Void
        
        private var _isEnabled: Bool {
            return !isLoading && isEnabled
        }
        
        var body: some View {
            Button {
                action()
            } label: {
                Text(Strings.Buttons.save)
                    .font(kernedFont: .Secondary.p2BoldKerned)
                    .foregroundColor(.orangish)
                    .loadingIndicator(isLoading, tint: .orangish)
            }
            .buttonStyle(.plain)
            .opacity(isEnabled ? 1 : 0)
            .disabled(!_isEnabled)
            .animation(.easeInOut, value: _isEnabled)
        }
    }
    
    struct CancelButton: View {
        
        let onCancel: () -> Void
        
        var body: some View {
            Button {
                onCancel()
            } label: {
                Text(Strings.Buttons.cancel)
                    .font(kernedFont: .Secondary.p1BoldKerned)
                    .foregroundColor(.orangish)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct QuickActionButton: View {
        
        var text: String = Strings.Buttons.cancel
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                Text(text)
                    .font(kernedFont: .Secondary.p1MediumKerned)
                    .foregroundColor(.orangish)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct CloseButton: View {
        
        let onClose: () -> Void
        
        var body: some View {
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .resizedToFit(size: CGSize(width: 16, height: 16))
                    .foregroundColor(.ebony)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct ShareButton: View {
        
        var tint: Color = .ebony
        let onShare: () -> Void
        
        var body: some View {
            Button {
                onShare()
            } label: {
                Image(.shareIcon)
                    .renderingMode(.template)
                    .foregroundColor(tint)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct ClearButton: View {
        
        let onClear: () -> Void
        
        var body: some View {
            Button {
                onClear()
            } label: {
                Image(.closeIcSmall)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct TinyShareButton: View {
        
        var tint: Color = .ebony
        var size: CGSize = CGSize(width: 16, height: 16)
        let onShare: () -> Void
        
        var body: some View {
            Button {
                onShare()
            } label: {
                Image(.shareIcon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(tint)
                    .frame(width: size.width, height: size.height)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct RemoveLabel: View {
        
        var body: some View {
            Text(Strings.Buttons.remove.uppercased())
                .font(kernedFont: .Secondary.p3BoldExtraKerned)
                .foregroundColor(.firebrick)
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .background(Color(0xF0ECE8).opacity(0.3), in: RoundedRectangle(cornerRadius: 4))
                .roundedBorder(Color.silver)
        }
    }
    
    struct MaterialButton: View {
        
        var material: Material = .thinMaterial
        let image: Image
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                image
                    .renderingMode(.template)
                    .resizedToFit(width: 15, height: 15)
                    .foregroundColor(.cultured)
                    .frame(width: 56, height: 56)
                    .visualEffectBlur(.systemUltraThinMaterialDark, vibrancyStyle: .fill)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
    
    struct BorderedActionButton: View {
        
        let title: String
        let tint: Color
        var height: CGFloat = 40
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                Text(title)
                    .font(kernedFont: .Secondary.p2BoldKerned)
                    .foregroundColor(tint)
                    .minimumScaleFactor(0.9)
            }
            .buttonStyle(
                ButtonStyles.BorderedFilled(
                    isEnabled: true,
                    lineWidth: 1,
                    borderColor: tint.opacity(0.6),
                    height: height
                )
            )
        }
    }
}

extension Buttons.FillBorderedButton where Content == EmptyView {
    
    init(
        title: String,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fillColor: Color = Color.silver,
        textColor: Color = .brownJet,
        lineWidth: CGFloat = 1,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.fillColor = fillColor
        self.textColor = textColor
        self.lineWidth = lineWidth
        self.action = action
        self.leadingAsset = EmptyView()
    }
}

extension Buttons.FilledRoundedButton where AdditionalLeadingView == EmptyView {
    
    init(title: String, isEnabled: Bool = true, isLoading: Bool = false, fillColor: Color = .darkGreen, tint: Color = .cultured, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.fillColor = fillColor
        self.tint = tint
        self.action = action
        self.additionalLeadingView = EmptyView()
    }
}

#if DEBUG
struct Buttons_Previews: PreviewProvider {
    
    static var previews: some View {
        ButtonsPreview()
    }
    
    private struct ButtonsPreview: View {
        @State var isLoading = false
        
        var body: some View {
            VStack {
                Buttons.EditButton(onEdit: {})
                ApplePayButton(action: {})
                    .frame(height: 56)
                    .padding(.horizontal, 16)
                Buttons.RemoveLabel()
                ZStack {
                    Color.red
                    HStack {
                        Buttons.MaterialButton(image: Image(.plusIcon), action: {})
                    }
                }
                .frame(width: 300, height: 100)
                Buttons.BorderedActionButton(title: "Clear", tint: .firebrick, action: {})
                Buttons.FilledRoundedButton(title: "Apply", isLoading: isLoading, additionalLeadingView: {
                    Image(.mail)
                        .renderingMode(.template)
                        .foregroundColor(.cultured)
                }, action: {
                    isLoading = true
                    DispatchQueue.main.asyncAfter(seconds: 1) {
                        isLoading = false
                    }
                })
            }
        }
    }
}
#endif
