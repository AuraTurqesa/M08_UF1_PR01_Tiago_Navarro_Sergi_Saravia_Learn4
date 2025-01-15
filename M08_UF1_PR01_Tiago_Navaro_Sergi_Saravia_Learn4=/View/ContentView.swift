import SwiftUI

struct ContentView: View {
    @StateObject private var triviaManager = TriviaManager()
    @State private var currentTrivia: Trivia? = nil
    @State private var respostaSeleccionada: String? = nil
    @State private var mostraRespostaCorrecta: Bool = false
    @State private var punts: Int = 0
    @State private var currentOpcions: [String] = []
    @State private var preguntesUsades: [Trivia] = []
    @State private var jocIniciat: Bool = false
    @State private var mostrarFinal: Bool = false
    @State private var totalRespostes: Int = 0
    @State private var editMode: EditMode = .inactive // Control del modo de edición

    var body: some View {
        NavigationView {
            TabView {
                // Primera pestaña: Lista de preguntas
                VStack {
                    Text("Nombre total de preguntes: \(triviaManager.trivies.count)")
                        .font(.body)
                        .padding()

                    List {
                        ForEach(triviaManager.trivies) { trivia in
                            VStack(alignment: .leading) {
                                Text(trivia.pregunta.text)
                                    .font(.body)
                                Text("Categoria: \(trivia.categoria)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onDelete(perform: deleteTrivia) // Habilita eliminar preguntas
                        .onMove(perform: moveTrivia) // Habilita mover preguntas
                    }
                    .environment(\.editMode, $editMode) // Vincula el modo de edición
                }
                .tabItem {
                    Label("Preguntes", systemImage: "list.bullet")
                }

                // Segunda pestaña: Juego de trivia
                VStack {
                    if !jocIniciat {
                        Spacer()
                        Button(action: {
                            jocIniciat = true
                            generarNovaPregunta()
                        }) {
                            Text("Començar el joc")
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        Spacer()
                    } else if let trivia = currentTrivia {
                        Text(trivia.pregunta.text)
                            .font(.body)
                            .padding()

                        ForEach(currentOpcions, id: \.self) { opcio in
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
                            VStack {
                                Text(respostaSeleccionada == trivia.respostaCorrecta ? "Correcte! 🎉" : "Incorrecte 😞")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(respostaSeleccionada == trivia.respostaCorrecta ? .green : .red)

                                if respostaSeleccionada != trivia.respostaCorrecta {
                                    Text("La resposta correcta és:")
                                        .font(.body)
                                        .multilineTextAlignment(.center)

                                    Text(trivia.respostaCorrecta)
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.blue)
                                }
                            }

                            HStack {
                                Button(action: reiniciarJoc) {
                                    Text("Reiniciar")
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.orange)
                                        .cornerRadius(10)
                                }

                                Button(action: generarNovaPregunta) {
                                    Text("Continuar")
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.top)
                        }
                    }

                    Spacer()

                    Text("Punts acumulats: \(punts)")
                        .font(.body)
                        .padding()
                }
                .tabItem {
                    Label("Jugar", systemImage: "gamecontroller")
                }
            }
            .navigationBarTitle("Trivia App", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Cambiar el modo de edición
                        if editMode == .active {
                            editMode = .inactive
                        } else {
                            editMode = .active
                        }
                    }) {
                        Text(editMode == .active ? "Done" : "Edit")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                if triviaManager.trivies.isEmpty {
                    triviaManager.fetchTrivies()
                }
            }
        }
    }

    // Generar una nova pregunta
    func generarNovaPregunta() {
        respostaSeleccionada = nil
        mostraRespostaCorrecta = false

        if triviaManager.trivies.isEmpty {
            triviaManager.trivies = preguntesUsades.shuffled()
            preguntesUsades.removeAll()
        }

        if let trivia = triviaManager.trivies.randomElement() {
            currentTrivia = trivia
            currentOpcions = opcionsAleatories(trivia: trivia)
            preguntesUsades.append(trivia)
            triviaManager.trivies.removeAll { $0.pregunta.text == trivia.pregunta.text }
        }
    }

    // Comprovar si la resposta és correcta
    func comprovarResposta(opcio: String, trivia: Trivia) {
        mostraRespostaCorrecta = true
        if opcio == trivia.respostaCorrecta {
            punts += 1
        }
        totalRespostes += 1
    }

    // Opcions de resposta en ordre aleatori
    func opcionsAleatories(trivia: Trivia) -> [String] {
        let opcions = trivia.respostesIncorrectes + [trivia.respostaCorrecta]
        return opcions.shuffled()
    }

    // Reiniciar el joc
    func reiniciarJoc() {
        jocIniciat = false
        currentTrivia = nil
        respostaSeleccionada = nil
        mostraRespostaCorrecta = false
        preguntesUsades.removeAll()
        triviaManager.fetchTrivies()

        // Mostrar la pantalla final durant 10 segons
        mostrarFinal = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            mostrarFinal = false
        }
    }

    // Función para eliminar una pregunta
    func deleteTrivia(at offsets: IndexSet) {
        triviaManager.trivies.remove(atOffsets: offsets)
    }

    // Función para mover una pregunta
    func moveTrivia(from source: IndexSet, to destination: Int) {
        triviaManager.trivies.move(fromOffsets: source, toOffset: destination)
    }
}

// Vista final
struct FinalView: View {
    var punts: Int
    var totalRespostes: Int
    var onRedirigir: () -> Void

    var body: some View {
        VStack {
            Text("Has contestat \(totalRespostes) respostes.")
                .font(.title)
                .padding()

            Spacer()

            Button(action: {
                onRedirigir()
            }) {
                Text("Tornar al joc")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                onRedirigir()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
