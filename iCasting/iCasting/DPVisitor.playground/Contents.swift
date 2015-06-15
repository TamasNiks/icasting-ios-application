//: Playground - noun: a place where people can play

import UIKit


// Interfaces

protocol Visitor {
    
    func visit(element: NormalMessageElement)
    func visit(element: OfferMessageElement)
    func visit(element: ContractMessageElement)
    
}


protocol Element {
    func accept(visitor: Visitor)
}


// Implementations Elements

class NormalMessageElement: Element {
    
    var message: String = ""
    
    func accept(visitor: Visitor) {
        visitor.visit(self)
    }
    
}

class OfferMessageElement: Element {
    
    var message: String = ""
    
    func accept(visitor: Visitor) {
        visitor.visit(self)
    }
    
    
}

class ContractMessageElement: Element {
    
    var message: String = ""
    
    func accept(visitor: Visitor) {

        visitor.visit(self)
    }
}



// Implementation Visitors

class ConcreteVisitor: Visitor {
    
    // Operations to be supported is modelled with a concrete derived class
    
    func visit(element: NormalMessageElement) {
        element.message = "I'm set on a normal message by the concrete visitor"
    }
    
    func visit(element: ContractMessageElement) {
        element.message = "I'm set on a contract message by the concrete visitor"
    }
    
    func visit(element: OfferMessageElement) {
        element.message = "I'm set on an offer message by the concrete visitor"
    }

}



class OtherVisitor: Visitor {
    
    func visit(element: OfferMessageElement) {
        element.message = "I'm set on a normal message by the other visitor"
    }
    
    func visit(element: ContractMessageElement) {
        element.message = "I'm set on a normal message by the other visitor"
    }
    
    func visit(element: NormalMessageElement) {
        element.message = "I'm set on a normal message by the other visitor"
    }
    
    
}



var elements: [Element] = [NormalMessageElement(), NormalMessageElement(), OfferMessageElement(), ContractMessageElement()]


for el: Element in elements {
    
    el.accept(OtherVisitor())
    
}


