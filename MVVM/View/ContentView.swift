//
//  ContentView.swift
//  MVVM
//
//  Created by 김수환 on 2022/09/09.
//

import SwiftUI

struct ContentView: View {
    //ViewModel을 가져온다
    @StateObject var viewModel = ContentViewModel()
    @State var Ontab:Bool = false
    
    @State var currentIndex:Int = 0
    
    private let maxScaleEffect: CGFloat = 4.0
    private let minScaleEffect: CGFloat = 0
    @State private var shouldTransition = true
    @State var background:Color = .clear
    
    var body: some View {
        ZStack{
            background.ignoresSafeArea()
            Circle()
                .fill(viewModel.background)
                .scaleEffect(shouldTransition ? maxScaleEffect : minScaleEffect)
            
            VStack {
                Text(viewModel.name)
                    .padding()
                Text(viewModel.age).scaleEffect(Ontab ? 1.8 : 1, anchor: .bottom)
                    .padding()
                Button("이름변경") {
                    viewModel.changeName("Hello")
                    Ontab = true
                }
                .padding()
                Button("나이 변경") {
                    viewModel.changeAge(21)
                    Ontab = false
                }
                
                // Custom Carousel
                CustomCarousel(index: $currentIndex, items: testvalues, spacing: UIScreen.main.bounds.width/3, cardPadding: 150, id: \.self){val,cardSize,IsCardUp in
                    // MARK: your custom cell View
                    Image(uiImage: val.Image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: cardSize.width, height: cardSize.height)
                        .clipShape(RoundedRectangle(cornerRadius: 20,style: .continuous))
                        .onChange(of: IsCardUp) { index in
                            if index != nil{
                                viewModel.changeBG(color: testvalues[index!].BGColor)
                                shouldTransition = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        background = viewModel.background
                                        shouldTransition = true
                                    }
                                }
                            }
                        }
                }
                .padding(.horizontal, -15)
                .padding(.vertical)
                
                
            }.padding([.horizontal,.top], 15)
                .onAppear{
                    background = viewModel.background
                }
        }
    }
    
}






