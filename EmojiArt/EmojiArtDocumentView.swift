//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 4/26/21.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    @State var selected = Set<EmojiArtModel.Emoji>()
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0,0), in: geometry))
                )
                .gesture(doubleTapToZoom(in: geometry.size).exclusively(before: tapToDeselect()))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(animatableSize: fontSize(for: emoji))
                            .position(position(for: emoji, in: geometry))
                            .gesture(tapToSelect(emoji).simultaneously(with: dragEmoji(emoji)))
                            .shadow(color: selected.contains(matching: emoji) ? .blue : .clear, radius: 10)
                    }
                }
                if !selected.isEmpty {
                    deleteButton
                        .transition(.opacity)
                        .zIndex(100)
                }
            }
            .clipped()
            .dropDestination(for: DropItem.self) { items, location in
                drop(items: items, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
        }
    }
    
    // MARK: - Select/Drag Emoji
    
    private func tapToSelect(_ emoji: EmojiArtModel.Emoji) -> some Gesture {
        TapGesture(count: 1).onEnded {
            withAnimation {
                selected.toggleMembership(of: emoji)
            }
        }
    }
    
    private func tapToDeselect() -> some Gesture {
        TapGesture(count: 1).onEnded {
            withAnimation {
                selected.removeAll()
            }
        }
    }
    
    @GestureState private var gestureDragOffset: CGSize = CGSize.zero
    @State var unselected: EmojiArtModel.Emoji?
    
    
    private func dragEmoji(_ emoji: EmojiArtModel.Emoji) -> some Gesture {
        DragGesture()
            .onChanged({ _ in
                unselected = selected.contains(matching: emoji) ? nil : emoji
            })
            .updating($gestureDragOffset) { latestDragGestureValue, gestureDragOffset, transaction in
                gestureDragOffset = latestDragGestureValue.translation
            }
            .onEnded { finalDragGestureValue in
                if selected.contains(matching: emoji) {
                    for emoji in selected {
                        document.moveEmoji(emoji, by: finalDragGestureValue.translation / zoomScale)
                    }
                } else {
                    document.moveEmoji(emoji, by: finalDragGestureValue.translation / zoomScale)
                }
            }
    }
    
    private func isDragging(emoji: EmojiArtModel.Emoji) -> Bool {
        if let unselected = unselected {
            return unselected.id == emoji.id
        }
        return selected.contains(matching: emoji)
    }
    
    // MARK: - Drag and Drop
    
    private func drop(items: [DropItem], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        guard let item = items.first else { return false }
        
        if let url = item.url {
            document.setBackground(.url(url.imageURL))
            return true
        }
        
        if let image = item.image {
            guard UIImage(data: image) != nil else { return false }
            document.setBackground(.imageData(image))
            return true
        }
        
        if let emoji = item.text?.first, emoji.isEmoji {
            document.addEmoji(
                String(emoji),
                at: convertToEmojiCoordinates(location, in: geometry),
                size: defaultEmojiFontSize / zoomScale
            )
            return true
        }
        return false
    }
    
    // MARK: - Positioning/Sizing Emoji
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        var location = convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
        if isDragging(emoji: emoji) {
            location = location + gestureDragOffset
        }
        return location
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        var size = CGFloat(emoji.size) * zoomScale
        if selected.contains(matching: emoji) {
            size *= gestureZoomScale
        }
        return size
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    // MARK: - Zooming
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        if !selected.isEmpty {
            // zooming on emojis
            return steadyStateZoomScale
        } else {
            return steadyStateZoomScale * gestureZoomScale
        }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                if !selected.isEmpty {
                    for emoji in selected {
                        document.scaleEmoji(emoji, by: gestureScaleAtEnd)
                    }
                } else {
                    steadyStateZoomScale *= gestureScaleAtEnd
                }
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0  {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    // MARK: - Panning
    
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }

    // MARK: - Palette
    
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiFontSize))
    }
    
    let testEmojis = "😀😷🦠💉👻👀🐶🌲🌎🌞🔥🍎⚽️🚗🚓🚲🛩🚁🚀🛸🏠⌚️🎁🗝🔐❤️⛔️❌❓✅⚠️🎶➕➖🏳️"
    
    
    var deleteButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        selected.forEach(document.removeEmoji)
                        selected.removeAll()
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.largeTitle)
                        .frame(width: 70, height: 70)
                        .padding(2)
                        .foregroundColor(.white)
                }
                .background(Color.red)
                .cornerRadius(5)
                .shadow(radius: 10)
                .padding()
            }
        }
    }
}

struct ScrollingEmojisView: View {
    let emojis: String

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
