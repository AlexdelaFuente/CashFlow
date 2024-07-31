//
//  ChartBar.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 26/7/24.
//

import SwiftUI

struct ChartBar: View {
    
    @ObservedObject var viewModel: ChartBarViewModel
    var data: [(Date, Double)]
    
    @State private var animatedIndexes: Set<Int> = []
    
    private let minBarHeight: CGFloat = 30
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 20) {
                        ForEach(0..<data.count, id: \.self) { index in
                            let item = data[index]
                            let maxDataValue = data.map { $0.1 }.max() ?? 1
                            let barHeight = CGFloat(item.1 / maxDataValue) * 170
                            
                            let adjustedBarHeight = max(barHeight, minBarHeight)
                            let barWidth: CGFloat = 30
                            
                            VStack {
                                Capsule()
                                    .fill(item.1 == 0.0 ? Color.clear : (viewModel.selectedIndex == index ? Color.accentColor : Color.gray))
                                    .frame(width: barWidth, height: animatedIndexes.contains(index) ? adjustedBarHeight : 0)
                                    .overlay(
                                        Capsule()
                                            .stroke(viewModel.selectedIndex == index ? Color.accentColor : Color.gray, lineWidth: 3)
                                    )
                                    
                                Text(formattedMonth(from: item.0))
                                    .font(.system(size: 12))
                                    .fontWeight(viewModel.selectedIndex == index ? .heavy : .medium)
                                    .frame(width: barWidth)
                                    .padding(.top, 4)
                            }
                            .frame(height: 200, alignment: .bottom)
                            .id(index)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    viewModel.selectedIndex = index
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12).padding(.top)
                    
                }.onAppear {
                    scrollViewProxy.scrollTo(data.count - 1, anchor: .trailing)
                    animateBarsSequentially()
                }.padding()
            }
        }
    }
    
    
    func formattedMonth(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: date)
    }
    
    
    private func animateBarsSequentially() {
        for index in 0..<data.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                let _ = withAnimation(.easeInOut(duration: 0.5)) {
                    animatedIndexes.insert(index)
                }
            }
        }
    }
}
