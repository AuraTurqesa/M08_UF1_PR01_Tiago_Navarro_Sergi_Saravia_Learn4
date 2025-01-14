import SwiftUI

struct ContentView: View {
    @StateObject private var triviaManager = TriviaManager()  // Crear el gestor de preguntes

    var body: some View {
        TabView {
            // Primera pestanya: Mostrar la llargada de l'array de Trivia
            VStack {
                Text("Llargada de l'array de preguntes: \(triviaManager.trivies.count)")
                    .font(.title)
                    .padding()
            }
            .tabItem {
                Label("Trivia", systemImage: "list.dash")  // Icono i text de la pestanya
            }

            // Segona pestanya: Jugar
            RandomQuestionGameView(triviaManager: triviaManager)
                .tabItem {
                    Label("Jugar", systemImage: "questionmark.circle")  // Icono i text de la pestanya
                }
        }
        .onAppear {
            triviaManager.fetchTrivies()  // Carregar totes les preguntes des de l'API quan es carrega la vista
        }
    }
}

struct RandomQuestionGameView: View {
    @ObservedObject var triviaManager: TriviaManager  // Passar el gestor de preguntes
    @State private var currentTrivia: Trivia? = nil  // Pregunta actual
    @State private var respostaSeleccionada: String? = nil  // Resposta seleccionada
    @State private var mostraRespostaCorrecta: Bool = false  // Per mostrar la resposta correcta
    @State private var punts: Int = 0  // Punts acumulats

    var body: some View {
        VStack {
            if let trivia = currentTrivia {
                // Mostrar la pregunta i les opcions
                Text(trivia.pregunta.text)
                    .font(.title)
                    .padding()

                // Opcions de resposta en ordre aleatori
                ForEach(opcionsAleatories(trivia: trivia), id: \.self) { opcio in
                    Button(action: {
                        respostaSeleccionada = opcio
                        comprovarResposta(opcio: opcio, trivia: trivia)
                    }) {
                        Text(opcio)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(respostaSeleccionada == opcio ? Color.gray : Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                if mostraRespostaCorrecta {
                    // Mostrar si la resposta és correcta o no
                    Text(respostaSeleccionada == trivia.respostaCorrecta ? "Correcte! 🎉" : "Incorrecte 😞. La resposta correcta és: \(trivia.respostaCorrecta)")
                        .font(.headline)
                        .padding()
                        .foregroundColor(respostaSeleccionada == trivia.respostaCorrecta ? .green : .red)
                }
            } else {
                // Si no hi ha pregunta actual, mostrar el botó "Jugar"
                Spacer()

                Button(action: generarNovaPregunta) {
                    Text("Jugar")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Spacer()
            }

            Spacer()

            // Mostrar els punts acumulats
            Text("Punts acumulats: \(punts)")
                .font(.headline)
                .padding()
        }
        .onAppear {
            if triviaManager.trivies.isEmpty {
                triviaManager.fetchTrivies()  // Carregar preguntes si no n'hi ha
            }
        }
    }

    // Generar una nova pregunta
    func generarNovaPregunta() {
        if let trivia = triviaManager.trivies.randomElement() {
            currentTrivia = trivia
            respostaSeleccionada = nil
            mostraRespostaCorrecta = false
        }
    }

    // Comprovar si la resposta és correcta i generar una nova pregunta després de 3 segons
    func comprovarResposta(opcio: String, trivia: Trivia) {
        mostraRespostaCorrecta = true
        if opcio == trivia.respostaCorrecta {
            punts += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // Filtrar per assegurar-nos que no es repeteixi la mateixa pregunta
            triviaManager.trivies.removeAll { $0.pregunta.text == trivia.pregunta.text }
            generarNovaPregunta()
        }
    }

    // Opcions de resposta en ordre aleatori
    func opcionsAleatories(trivia: Trivia) -> [String] {
        let opcions = trivia.respostesIncorrectes + [trivia.respostaCorrecta]
        return opcions.shuffled()
    }
}
