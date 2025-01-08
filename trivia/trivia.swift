//Modelo de trivia

import Foundation

struct trivia {
    var categoria:String
    var tipus:String
    var dificultat:String
    var pregunta:String
    var respostaCorrecta:String
    var respostesIncorrectes:[String]
    var puntsAcumulats:Int
}
