//
//  AgeController.swift
//  MVVM
//
//  Created by 김수환 on 2022/09/09.
//

import SwiftUI


let testvalues:[testStruct] = [testStruct(name: "Hi", val: "1", Image: UIImage(named: "Image1")!,BGColor:Color.orange),
                               testStruct(name: "nice", val: "2", Image: UIImage(named: "Image2")!,BGColor:Color.purple),
                               testStruct(name: "to", val: "3", Image: UIImage(named: "Image3")!,BGColor:Color.gray),
                               testStruct(name: "meet", val: "4", Image: UIImage(named: "Image4")!,BGColor:Color.red),
                               testStruct(name: "you", val: "5", Image: UIImage(named: "Image5")!,BGColor:Color.yellow)]

class ContentViewModel: ObservableObject {
    @Published var person = Person(name: "tkgka", age: 27)
    @Published var BG:Color = testvalues[0].BGColor
    var name: String {
        person.name
    }
    var age: String {
        //Date를 -> 나이로 변환
        String(person.age)
    }
    var background:Color {
        BG
    }
    func changeBG(color:Color){
        BG = color
    }
    
    //이름변경 함수 생성
    func changeName(_ name: String) {
        person.name = name
    }
    
    func changeAge(_ age: Int) {
        person.age = age
    }
}
