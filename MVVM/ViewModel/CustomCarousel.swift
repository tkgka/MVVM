//
//  CustomCarousel.swift
//  MVVM
//
//  Created by 김수환 on 2022/09/09.
//

import SwiftUI

struct CustomCarousel<Content: View,Item,ID>: View where Item: RandomAccessCollection,ID: Hashable,Item.Element:Equatable{
    var content: (Item.Element,CGSize)->Content
    var id: KeyPath<Item.Element,ID>
    
    var spacing: CGFloat
    var cardPadding: CGFloat
    @Binding var index:Int
    var items: Item
    
    init(index:Binding<Int>,items: Item, spacing:CGFloat = 30, cardPadding:CGFloat = 80, id: KeyPath<Item.Element, ID>, @ViewBuilder content: @escaping (Item.Element,CGSize) -> Content){
        self.content = content
        self.id = id
        self._index = index
        self.spacing = spacing
        self.cardPadding = cardPadding
        self.items = items
    }
    //MARK: Gesture Properties
    @GestureState var translation:CGFloat = 0
    @State var offset:CGFloat = 0
    @State var lastStoredOffset:CGFloat = 0
    
    @State var currentIndex:Int = 0
    @State var rotation:Double = 0
    var body: some View {
        GeometryReader{proxy in
            let size = proxy.size
            let cardWidth = size.width - (cardPadding - spacing)
            LazyHStack(spacing: spacing){
                ForEach(items, id: id){val in
                    let index = indexOf(item: val)
                    content(val,CGSize(width: size.width - cardPadding, height: size.height))
                    //MARK: Rotate each view 5 Deg to make circular looking
                    
                        .rotationEffect(.init(degrees: Double(index) * 5), anchor: .bottom)
                        .rotationEffect(.init(degrees: rotation), anchor: .bottom)
                    
                        .offset(y: offsetY(index: index, cardWidth: cardWidth))
                    
                        .frame(width: size.width - cardPadding, height: size.height)
                        .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, spacing)
            .offset(x: limitScroll())
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 5)
                    .updating($translation, body: {value, out, _ in
                        out = value.translation.width
                    })
                    .onChanged{onChanged(value: $0, cardWidth: cardWidth)}
                    .onEnded{onEnd(value: $0, cardWidth: cardWidth)}
            )
        }
        .padding(.top, 60)
        .onAppear{
            let extraSpace = (cardPadding / 2) - spacing
            offset = extraSpace
            lastStoredOffset = extraSpace
        }
        .animation(.easeOut, value: translation == 0)
    }
    
    // MARK: moving current Item up
    func offsetY(index:Int, cardWidth:CGFloat) -> CGFloat{
        //MARK: converting current translation
        let progress = ((translation < 0 ? translation : -translation)/cardWidth) * 60
        let offsetY = -progress < 60 ? progress : -(progress + 120)
        
        let previous = (index - 1) == self.index ? (translation < 0 ? offsetY : -offsetY) : 0
        let next = (index + 1) == self.index ? (translation < 0 ? -offsetY : offsetY) : 0
        let In_Between = (index - 1) == self.index ? previous : next
        return index == self.index ? -60 - offsetY : In_Between
    }
    
    // MARK: Item Index
    func indexOf(item: Item.Element) -> Int {
        let array = Array(items)
        if let index = array.firstIndex(of: item){
            return index
        }
        return 0
    }
    //MARK: limit scroll on first and last Item
    
    func limitScroll () -> CGFloat {
        let extraSpace = (cardPadding / 2) - spacing
        if index == 0 &&  offset > extraSpace {
            return extraSpace + (offset / 4)
        }else if index == items.count - 1 && translation < 0 {
            return offset - (translation / 2)
        }else {
            return offset
        }
    }
    
    func onChanged(value: DragGesture.Value, cardWidth:CGFloat){
        let translationX = value.translation.width
        offset = translationX + lastStoredOffset
        
        //MARK: calculation Rotation
        let progress = offset / cardWidth
        rotation = progress * 5
    }
    func onEnd(value: DragGesture.Value, cardWidth:CGFloat){
        // MARK: find current Index
        //since index start with 0
        var _index = (offset/cardWidth).rounded()
        _index = max(-CGFloat(items.count-1),_index)
        _index = min(_index, 0)
        currentIndex = Int(_index)
        //MARK: Update index
        index = -currentIndex
        // all data will be Nagative
        
        withAnimation(.easeOut(duration: 0.25)){
            // MARK: remove extra space
            let extraSpace = (cardPadding / 2) - spacing
            offset = (cardWidth * _index) + extraSpace
            
            //MARK: calculation Rotation
            let progress = offset / cardWidth
            rotation = (progress * 5).rounded() - 1
        }
        lastStoredOffset = offset
    }
}
