import Foundation

struct Trivia: Codable, Identifiable {
    let categoria: String
    let id: String
    let tags: [String]
    let dificultat: String
    let regions: [String]
    let esNiche: Bool
    let pregunta: Pregunta
    let respostaCorrecta: String
    let respostesIncorrectes: [String]
    let tipus: String
    var puntsAcumulats: Int

    enum CodingKeys: String, CodingKey {
        case categoria = "category"
        case id
        case tags
        case dificultat = "difficulty"
        case regions
        case esNiche = "isNiche"
        case pregunta = "question"
        case respostaCorrecta = "correctAnswer"
        case respostesIncorrectes = "incorrectAnswers"
        case tipus = "type"
        case puntsAcumulats
    }

    // Inicialitzador personalitzat per afegir `puntsAcumulats` amb un valor per defecte
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        categoria = try container.decode(String.self, forKey: .categoria)
        id = try container.decode(String.self, forKey: .id)
        tags = try container.decode([String].self, forKey: .tags)
        dificultat = try container.decode(String.self, forKey: .dificultat)
        regions = try container.decode([String].self, forKey: .regions)
        esNiche = try container.decode(Bool.self, forKey: .esNiche)
        pregunta = try container.decode(Pregunta.self, forKey: .pregunta)
        respostaCorrecta = try container.decode(String.self, forKey: .respostaCorrecta)
        respostesIncorrectes = try container.decode([String].self, forKey: .respostesIncorrectes)
        tipus = try container.decode(String.self, forKey: .tipus)

        // `puntsAcumulats` tindrà un valor per defecte de 0 si no és present al JSON
        puntsAcumulats = (try? container.decode(Int.self, forKey: .puntsAcumulats)) ?? 0
    }

    // Per codificar l'estructura a JSON, incloem `puntsAcumulats`
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(categoria, forKey: .categoria)
        try container.encode(id, forKey: .id)
        try container.encode(tags, forKey: .tags)
        try container.encode(dificultat, forKey: .dificultat)
        try container.encode(regions, forKey: .regions)
        try container.encode(esNiche, forKey: .esNiche)
        try container.encode(pregunta, forKey: .pregunta)
        try container.encode(respostaCorrecta, forKey: .respostaCorrecta)
        try container.encode(respostesIncorrectes, forKey: .respostesIncorrectes)
        try container.encode(tipus, forKey: .tipus)
        try container.encode(puntsAcumulats, forKey: .puntsAcumulats)
    }
}

struct Pregunta: Codable {
    let text: String

    enum CodingKeys: String, CodingKey {
        case text
    }
}
