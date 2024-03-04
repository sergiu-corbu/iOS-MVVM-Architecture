//
//  ShippingDetailView.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 26.09.2023.
//

import SwiftUI

struct ShippingDetailView: View {
    
    var onOpenEmail: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
                .padding(.top, 24)
            ScrollView {
                contentView
            }
        }
        .background(Color.cultured.opacity(0.9))
        .presentationDragIndicator(.visible)
    }
    
    private var headerView: some View {
        Text(Strings.NavigationTitles.howShippingWorks)
            .font(kernedFont: .Secondary.p1BoldKerned)
            .foregroundColor(.ebony)
            .lineLimit(2)
            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
            .roundedBorder(Color.ebony.opacity(0.15), cornerRadius: 10)
            .frame(maxWidth: .infinity)
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(SectionType.allCases, id: \.rawValue) { section in
                if section == .questions {
                    SectionView(section: section, additionalContent: {
                        Button {
                            onOpenEmail?()
                        } label: {
                            Text(Constants.EMAIL_ADDRESS)
                                .font(kernedFont: .Secondary.p1BoldKerned)
                                .foregroundColor(.brightGold)
                        }
                        .buttonStyle(.plain)
                    })
                } else {
                    SectionView(section: section)
                }
            }
        }
    }
    
    enum SectionType: Int, CaseIterable {
        case goodToKnow, payment, shipping, returns, questions
        
        var title: String {
            switch self {
            case .goodToKnow: return Strings.ShippingDetails.goodToKnow
            case .payment: return Strings.ShippingDetails.payment
            case .shipping: return Strings.ShippingDetails.shipping
            case .returns: return Strings.ShippingDetails.returns
            case .questions: return Strings.ShippingDetails.questions
            }
        }
        
        var description: String {
            switch self {
            case .goodToKnow: return Strings.ShippingDetails.goodToKnowDetails
            case .payment: return Strings.ShippingDetails.paymentDetails
            case .shipping: return Strings.ShippingDetails.shippingDetails
            case .returns: return Strings.ShippingDetails.returnsDetails
            case .questions: return Strings.ShippingDetails.questionsDetails
            }
        }
    }
    
    struct SectionView<AdditionalContent: View>: View {
        
        let title: String
        let description: String
        @ViewBuilder let additionalContent: AdditionalContent
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Group {
                    Text(title)
                        .font(kernedFont: .Main.p1MediumKerned)
                        .foregroundColor(.jet)
                    Text(description)
                        .font(kernedFont: .Secondary.p1RegularKerned)
                        .foregroundColor(.ebony)
                        .lineSpacing(1.5)
                    additionalContent
                }
                .padding(.horizontal, 16)
                DividerView()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

extension ShippingDetailView.SectionView where AdditionalContent == EmptyView {
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
        self.additionalContent = EmptyView()
    }
    
    init(section: ShippingDetailView.SectionType) {
        self.title = section.title
        self.description = section.description
        self.additionalContent = EmptyView()
    }

}

extension ShippingDetailView.SectionView {
    
    init(section: ShippingDetailView.SectionType, @ViewBuilder additionalContent: () -> AdditionalContent) {
        self.title = section.title
        self.description = section.description
        self.additionalContent = additionalContent()
    }
}

#if DEBUG
struct ShippingDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        Color.white
            .sheet(isPresented: .constant(true)) {
                ShippingDetailView()
                    .presentationDetents([.fraction(0.8)])
            }
    }
}
#endif
