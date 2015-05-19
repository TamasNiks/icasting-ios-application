//
//  DummyData.swift
//  iCasting
//
//  Created by T. van Steenoven on 20-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

class Dummy {
    
    /*

    Error handling: If the user is on the screen and the time is running out on the server, the user cannot accept a match anymore, and so the server should respond with an error, which needs to be handled correctly by the app
    
    For the job data look at:
    
    job {
        contract {
            dateTime {
                dateStart:"2017-03-03T00:00:00.000Z"
                timeEnd = "16:00"
                timeStart = "13:00"
            },
            location {
                address {
                    city
                    country
                    street
                    streetNumber
                    zipCode
                }
            }
        },
        profile {
            actor(), gender, near{type}, skinColor(), type
    
        }
    
    
    }
    
    */
    
    
    static var matches: JSON {
        
        get {
            
            
            var dummy: String = "[{\"_id\":\"5530ff7914c486cc4ae9c0e9\",\"modified\":\"2015-04-17T12:41:30.786Z\",\"castingObject\":\"551d58a326042f74fb745536\",\"job\":{\"_id\":\"5530ff5a14c486cc4ae9bff0\",\"desc\":\"Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Lo...\",\"title\":\"Long title Long title Long title Long title Long title Long title Long title Long title Long title Long title Long title\",\"contract\":{\"auditionType\":{\"type\":\"none\",\"negotiable\":false},\"requests\":{\"desc\":\"FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJv FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJ  FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJ\",\"negotiable\":false},\"location\":{\"address\":{\"country\":\"Nederland\",\"city\":\"Amsterdam\",\"street\":\"Klaverstraat\",\"streetNumber\":\"2\",\"zipCode\":\"1000AA\"},\"negotiable\":false,\"type\":\"address\"},\"dateTime\":{\"type\":\"single\",\"dateStart\":\"2017-03-03T00:00:00.000Z\",\"timeStart\":\"13:00\",\"timeEnd\":\"16:00\",\"negotiable\":false},\"travelExpenses\":{\"hasTravelExpenses\":false,\"negotiable\":false},\"buyOff\":{\"hasBuyOff\":false,\"medium\":[],\"negotiable\":false},\"budget\":{\"times1000\":0,\"negotiable\":false},\"paymentMethod\":{\"type\":\"iCasting\",\"negotiable\":false}},\"formSource\":{\"contract\":{\"budget\":{\"times1000\":0},\"negotiableFee\":false,\"travelExpenses\":{\"hasTravelExpenses\":false},\"paymentMethod\":{\"type\":\"iCasting\"},\"buyOff\":{\"hasBuyOff\":false},\"dateTime\":{\"type\":\"single\",\"dateStart\":\"2017-03-03T00:00:00+00:00\",\"timeStart\":\"13:00\",\"timeEnd\":\"16:00\"},\"location\":{\"type\":\"address\",\"address\":{\"country\":\"Nederland\",\"city\":\"Amsterdam\",\"street\":\"Klaverstraat\",\"streetNumber\":\"2\",\"zipCode\":\"1000AA\"}},\"requests\":{\"desc\":\"FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJv FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJ  FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJ\"}},\"profile\":{\"type\":\"actor\",\"actor\":[\"student film\",\"tv series\",\"tv commercials\",\"live shows\",\"theater\",\"events\",\"film\"],\"gender\":\"male\",\"skinColor\":[\"pale\",\"medium\",\"brown\",\"dark brown\",\"deep dark brown\"],\"near\":{\"type\":\"everywhere\"}},\"title\":\"Long title Long title Long title Long title Long title Long title Long title Long title Long title Long title Long title\",\"isAudition\":\"job\",\"_id\":\"5530ff1114c486cc4ae9bfd7\",\"numberOfTalents\":2,\"numberOfMatches\":465,\"links\":[],\"descLong\":\"Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc Long desc\"}},\"client\":{\"_id\":\"5502d4353ce61ee486433c6b\",\"country\":\"NL\",\"gender\":\"male\",\"roles\":[\"client\",\"company\",\"adult\",\"verified\"],\"address\":{\"city\":\"Amsterdam\"},\"name\":{\"first\":\"Wouter\",\"last\":\"Baan\",\"display\":\"Wouter Baan\"},\"company\":{\"name\":\"Wouter Baan Bedrijf\",\"COC\":\"00000000\",\"aboutUs\":\"Wouter Baan's Bedrijf\",\"size\":\"1\",\"grade\":6.171428571428571}},\"talent\":\"551d58a226042f74fb745533\",\"points\":0,\"max\":0,\"percentage\":100,\"__v\":0,\"read\":{\"client\":false,\"talent\":false},\"contract\":{\"auditionType\":{\"type\":\"none\",\"accepted\":true},\"requests\":{\"desc\":\"FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJv FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJ  FOIEJFEIOFJ EFOIEFJ EOFJ FOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJFOIEJFEIOFJ EFOIEFJ EOFJ\",\"accepted\":true},\"location\":{\"address\":{\"country\":\"Nederland\",\"city\":\"Amsterdam\",\"street\":\"Klaverstraat\",\"streetNumber\":\"2\",\"zipCode\":\"1000AA\"},\"type\":\"address\",\"accepted\":true},\"dateTime\":{\"type\":\"single\",\"dateStart\":\"2017-03-03T00:00:00.000Z\",\"timeStart\":\"13:00\",\"timeEnd\":\"16:00\",\"dateEnd\":null,\"accepted\":true},\"travelExpenses\":{\"hasTravelExpenses\":false,\"accepted\":true},\"buyOff\":{\"hasBuyOff\":false,\"medium\":[],\"accepted\":true},\"budget\":{\"times1000\":0,\"accepted\":true},\"paymentMethod\":{\"type\":\"iCasting\",\"accepted\":true}},\"reaction\":{\"type\":\"text\"},\"statusHistory\":[],\"disabledBy\":{\"owner\":false,\"admin\":false,\"user\":false},\"demo\":false,\"tx\":[],\"status\":\"pending\",\"talentDisabled\":false,\"reserved\":{\"currency\":\"EUR\",\"amountTimes1000\":0},\"poked\":false},{\"_id\":\"5524f3d55df79f57f2da5f82\",\"modified\":\"2015-04-20T08:52:31.685Z\",\"castingObject\":\"551d58a326042f74fb745536\",\"job\":{\"_id\":\"5524efb75df79f57f2da5dda\",\"desc\":\"Fashion modellen nodig voor een internationale opdracht\",\"title\":\"Op Zoek naar Fashion Modellen\",\"contract\":{\"auditionType\":{\"type\":\"none\",\"negotiable\":false},\"requests\":{\"negotiable\":false},\"location\":{\"address\":{\"city\":\"Rotterdam\",\"street\":\"Sydneystraat\",\"streetNumber\":\"49\",\"zipCode\":\"3047 BP\"},\"negotiable\":false,\"type\":\"my location\"},\"dateTime\":{\"type\":\"single\",\"dateStart\":\"2015-05-06T00:00:00.000Z\",\"timeStart\":\"11:00\",\"timeEnd\":\"23:00\",\"negotiable\":false},\"travelExpenses\":{\"hasTravelExpenses\":true,\"negotiable\":false},\"buyOff\":{\"hasBuyOff\":false,\"medium\":[],\"negotiable\":false},\"budget\":{\"times1000\":250000,\"negotiable\":false},\"paymentMethod\":{\"type\":\"iCasting\",\"negotiable\":false}},\"formSource\":{\"contract\":{\"budget\":{\"times1000\":250000},\"negotiableFee\":true,\"travelExpenses\":{\"hasTravelExpenses\":true},\"paymentMethod\":{\"type\":\"iCasting\"},\"buyOff\":{\"hasBuyOff\":false},\"dateTime\":{\"type\":\"single\",\"dateStart\":\"2015-05-06T00:00:00+00:00\",\"timeStart\":\"11:00\",\"timeEnd\":\"23:00\"},\"location\":{\"type\":\"my location\",\"address\":{\"city\":\"Rotterdam\",\"street\":\"Sydneystraat\",\"streetNumber\":\"49\",\"zipCode\":\"3047 BP\"}}},\"profile\":{\"type\":\"fashion model\",\"gender\":\"any\",\"skinColor\":[\"pale\"],\"hair\":{\"head\":{\"isBalding\":false,\"isGreying\":false},\"face\":{\"hasFacial\":false}},\"hasTattoos\":false,\"hasScars\":false,\"hasPiercings\":false,\"languages\":{\"nl\":{\"level\":2,\"name\":\"nl\"},\"en\":{\"level\":2,\"name\":\"en\"}},\"near\":{\"type\":\"everywhere\"}},\"dayFee\":250000,\"_id\":\"5524efb75df79f57f2da5dda\",\"numberOfMatches\":381,\"isAudition\":\"job\",\"title\":\"Op Zoek naar Fashion Modellen\",\"numberOfTalents\":5,\"links\":[],\"descLong\":\"Fashion modellen nodig voor een internationale opdracht\"}},\"client\":{\"_id\":\"5524e3ef96d96da03c96665c\",\"gender\":\"female\",\"country\":\"NL\",\"roles\":[\"client\",\"person\",\"adult\",\"verified\"],\"address\":{\"city\":\"Rotterdam\"},\"name\":{\"first\":\"Angie\",\"last\":\"Peralta\",\"display\":\"Angie Peralta\"},\"company\":{\"grade\":null},\"avatar\":{\"thumb\":\"\"}},\"talent\":\"551d58a226042f74fb745533\",\"points\":20,\"max\":10,\"percentage\":200,\"__v\":0,\"read\":{\"client\":false,\"talent\":true},\"contract\":{\"auditionType\":{\"type\":\"none\",\"accepted\":true},\"requests\":{\"accepted\":true},\"location\":{\"address\":{\"city\":\"Rotterdam\",\"street\":\"Sydneystraat\",\"streetNumber\":\"49\",\"zipCode\":\"3047 BP\"},\"type\":\"my location\",\"accepted\":true},\"dateTime\":{\"type\":\"single\",\"dateStart\":\"2015-05-06T00:00:00.000Z\",\"timeStart\":\"11:00\",\"timeEnd\":\"23:00\",\"dateEnd\":null,\"accepted\":true},\"travelExpenses\":{\"hasTravelExpenses\":true,\"accepted\":true},\"buyOff\":{\"hasBuyOff\":false,\"medium\":[],\"accepted\":true},\"budget\":{\"times1000\":250000,\"accepted\":true},\"paymentMethod\":{\"type\":\"iCasting\",\"accepted\":true}},\"reaction\":{\"type\":\"text\"},\"statusHistory\":[],\"disabledBy\":{\"owner\":false,\"admin\":false,\"user\":false},\"demo\":false,\"tx\":[],\"status\":\"pending\",\"talentDisabled\":false,\"reserved\":{\"currency\":\"EUR\",\"amountTimes1000\":0},\"poked\":false}]"
            
            var dum2: String = "[{\"_id\":\"1\"},{\"_id\":\"2\"}]"
            
            var parsedJSON: AnyObject = JSONParser.mockJSONParse(dummy)!
            var json: JSON = JSON(parsedJSON)
            
            return json
        }
        
        
    }
    
    
}