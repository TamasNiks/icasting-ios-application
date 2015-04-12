// Playground - noun: a place where people can play

import Swift
import Foundation


class DeathStarBuilder {
    
    var x: Double?
    var y: Double?
    var z: Double?
    
    typealias BuilderClosure = (DeathStarBuilder) -> ()
    
    init (buildClosure: BuilderClosure) {
        buildClosure(self)
    }
    
}

struct DeathStar {
    
    let x: Double
    let y: Double
    let z: Double
    
    init?(builder: DeathStarBuilder) {

        if let x = builder.x {
            self.x = x
        }
//        if let x = builder.x, y = builder.y, z = builder.z {
//            self.x = x
//            self.y = y
//            self.z = z
//        }
//        else {
//            return nil
//        }
//    }
}


let test : DeathStarBuilder = DeathStarBuilder({ builder in
    builder.x = 0.1
    builder.y = 0.2
    builder.z = 0.3
})

//let deathStar = DeathStar(builder: test)

//let test = DeatchStarBuilder(


//let empire = DeathStarBuilder { builder in
//    builder.x = 0.1
//    builder.y = 0.2
//    builder.z = 0.3
//}

//let deathStar = DeathStar(builder:empire)