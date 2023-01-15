//
//  AspectVGrid.swift
//  Memorize
//
//  Created by CS193p Instructor on 4/14/21.
//  Copyright Stanford University 2021
//

import SwiftUI

struct AspectVGrid<Item, ItemView>: View where ItemView: View, Item: Identifiable {
    var items: [Item]
    var aspectRatio: CGFloat
    var minimumWidth: CGFloat?
    var content: (Item) -> ItemView
    
    init(items: [Item], aspectRatio: CGFloat, @ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    init(items: [Item], aspectRatio: CGFloat, minimumWidth: CGFloat, @ViewBuilder content: @escaping (Item) -> ItemView) {
        self.init(items: items, aspectRatio: aspectRatio, content: content)
        self.minimumWidth = minimumWidth
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = widthThatFits(itemCount: items.count, in: geometry.size, itemAspectRatio: aspectRatio)
            if width == minimumWidth {
                ScrollView {
                    grid(width: width)
                }
            } else {
                VStack {
                    grid(width: width)
                }
            }
        }
    }
    
    @ViewBuilder private func grid(width: CGFloat) -> some View {
        LazyVGrid(columns: [adaptiveGridItem(width: width)], spacing: 0) {
            ForEach(items) { item in
                content(item).aspectRatio(aspectRatio, contentMode: .fit)
            }
        }
        Spacer(minLength: 0)
    }
    
    private func adaptiveGridItem(width: CGFloat) -> GridItem {
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }
    
    private func widthThatFits(itemCount: Int, in size: CGSize, itemAspectRatio: CGFloat) -> CGFloat {
        var columnCount = 1
        var rowCount = itemCount
        repeat {
            let itemWidth = size.width / CGFloat(columnCount)
            let itemHeight = itemWidth / itemAspectRatio
            if  CGFloat(rowCount) * itemHeight < size.height {
                break
            }
            columnCount += 1
            rowCount = (itemCount + (columnCount - 1)) / columnCount
        } while columnCount < itemCount
        if columnCount > itemCount {
            columnCount = itemCount
        }
        let width = floor(size.width / CGFloat(columnCount))
        if let minimumWidth = self.minimumWidth {
            return max(width, minimumWidth)
        }
        return width
    }

}

//struct AspectVGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        AspectVGrid()
//    }
//}
