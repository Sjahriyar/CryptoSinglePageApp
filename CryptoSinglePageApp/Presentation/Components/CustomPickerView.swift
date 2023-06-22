//
//  CustomPickerView.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 16/06/2023.
//

import SwiftUI

struct SegmentedControlView: View {
    @Binding private var selectedIndex: Int

    @State private var frames: Array<CGRect>
    @State private var backgroundFrame = CGRect.zero

    private let titles: [String]

    init(selectedIndex: Binding<Int>, titles: [String]) {
        self._selectedIndex = selectedIndex
        self.titles = titles
        frames = Array<CGRect>(repeating: .zero, count: titles.count)
    }

    var body: some View {
        VStack {
            SegmentedControlButtonView(
                selectedIndex: $selectedIndex,
                frames: $frames,
                backgroundFrame: $backgroundFrame,
                titles: titles
            )
        }
        .background(
            GeometryReader { geoReader in
                Color.clear.preference(
                    key: RectPreferenceKey.self,
                    value: geoReader.frame(in: .global)
                )
                .onPreferenceChange(RectPreferenceKey.self) {
                    self.setBackgroundFrame(frame: $0)
                }
            }
        )
    }

    private func setBackgroundFrame(frame: CGRect) {
        backgroundFrame = frame
    }
}

private struct SegmentedControlButtonView: View {
    @Binding private var selectedIndex: Int
    @Binding private var frames: [CGRect]
    @Binding private var backgroundFrame: CGRect

    private let titles: [String]

    init(
        selectedIndex: Binding<Int>,
        frames: Binding<[CGRect]>,
        backgroundFrame: Binding<CGRect>,
        titles: [String]
    ) {
        _selectedIndex = selectedIndex
        _frames = frames
        _backgroundFrame = backgroundFrame

        self.titles = titles
    }

    var body: some View {
        HStack(spacing: 16) {
            ForEach(titles.indices, id: \.self) { index in
                Button(action: { selectedIndex = index }) {
                    HStack {
                        Text(titles[index])
                            .foregroundColor(selectedIndex == index ? .primary.opacity(0.8) : .secondary)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .buttonStyle(CustomSegmentButtonStyle())
                .background(
                    GeometryReader { geoReader in
                        Color.clear.preference(key: RectPreferenceKey.self, value: geoReader.frame(in: .global))
                            .onPreferenceChange(RectPreferenceKey.self) {
                                self.setFrame(index: index, frame: $0)
                            }
                    }
                )
            }
        }
        .modifier(UnderlineModifier(selectedIndex: selectedIndex, frames: frames))
    }

    private func setFrame(index: Int, frame: CGRect) {
        self.frames[index] = frame
    }
}

private struct UnderlineModifier: ViewModifier {
    var selectedIndex: Int
    let frames: [CGRect]

    @State private var animationAmount = 0.2

    func body(content: Content) -> some View {
        content
            .background(
                Color.cyan
                    .frame(width: frames[selectedIndex].width, height: 1.5)
                    .offset(
                        x: frames[selectedIndex].minX - (frames.first?.minX ?? 0)
                    ),
                alignment: .bottomLeading
            )
            .background(
                Color.gray.opacity(0.4)
                    .frame(height: 1.5),
                alignment: .bottomLeading
            )
            .animation(.easeOut(duration: 0.2), value: selectedIndex)
    }
}

private struct CustomSegmentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding(
                EdgeInsets(
                    top: Constants.spacingDefault,
                    leading: Constants.spacingMedium,
                    bottom: Constants.spacingDefault,
                    trailing: Constants.spacingMedium
                )
            )
            .frame(maxWidth: .infinity)
    }
}

struct SegmentedControlView_Preview: PreviewProvider {
    static var previews: some View {
        SegmentedControlView(
            selectedIndex: .constant(0),
            titles: ["Item 1", "Item 2", "Item 3"]
        )
    }
}
