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
    
    // Para manejar la presentación del formulario de añadir pregunta
    @State private var showAddQuestionModal: Bool = false
    @State private var newPreguntaText: String = ""
    @State private var newCategoria: String = ""
    @State private var newRespostaCorrecta: String = ""
    @State private var newRespostesIncorrectes: [String] = Array(repeating: "", count: 3)

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
                        .onMove(perform: moveTrivia)
                        ForEach(triviaManager.create) { cr in
                            VStack(alignment: .leading) {
                                Text(cr.pregunta)
                                    .font(.body)
                                Text("Categoria: \(cr.categoria)")
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("+") {
                        showAddQuestionModal.toggle() // Mostrar el formulario modal
                    }
                    .foregroundColor(.blue)
                }
            }
            .onAppear {
                if triviaManager.trivies.isEmpty {
                    triviaManager.fetchTrivies()
                }
            }
            .sheet(isPresented: $showAddQuestionModal) {
                // Vista de la hoja modal para agregar una nueva pregunta
                AddQuestionModalView(
                    newPreguntaText: $newPreguntaText,
                    newCategoria: $newCategoria,
                    newRespostaCorrecta: $newRespostaCorrecta,
                    newRespostesIncorrectes: $newRespostesIncorrectes,
                    onSave: addNewQuestion
                )
            }
        }
    }

    // Función para agregar una nueva pregunta
    func addNewQuestion() {
        let newTrivia = Created(
            pregunta: newPreguntaText,
            categoria: newCategoria,
            respostaCorrecta: newRespostaCorrecta,
            respostesIncorrectes: newRespostesIncorrectes
        )
        triviaManager.create.append(newTrivia)
        
        // Limpiar campos del formulario
        newPreguntaText = ""
        newCategoria = ""
        newRespostaCorrecta = ""
        newRespostesIncorrectes = Array(repeating: "", count: 3)
        
        // Cerrar el modal
        showAddQuestionModal = false
    }

    // Generar una nueva pregunta
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

    // Comprobar si la respuesta es correcta
    func comprovarResposta(opcio: String, trivia: Trivia) {
        mostraRespostaCorrecta = true
        if opcio == trivia.respostaCorrecta {
            punts += 1
        }
        totalRespostes += 1
    }

    // Opciones de respuesta aleatorias
    func opcionsAleatories(trivia: Trivia) -> [String] {
        let opcions = trivia.respostesIncorrectes + [trivia.respostaCorrecta]
        return opcions.shuffled()
    }

    // Reiniciar el juego
    func reiniciarJoc() {
        jocIniciat = false
        currentTrivia = nil
        respostaSeleccionada = nil
        mostraRespostaCorrecta = false
        preguntesUsades.removeAll()
        triviaManager.fetchTrivies()

        // Mostrar la pantalla final durante 10 segundos
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

// Vista de formulario modal para agregar una pregunta
struct AddQuestionModalView: View {
    @Binding var newPreguntaText: String
    @Binding var newCategoria: String
    @Binding var newRespostaCorrecta: String
    @Binding var newRespostesIncorrectes: [String]
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pregunta")) {
                    TextField("Escribe la pregunta", text: $newPreguntaText)
                }

                Section(header: Text("Categoría")) {
                    TextField("Escribe la categoría", text: $newCategoria)
                }

                Section(header: Text("Respuesta Correcta")) {
                    TextField("Escribe la respuesta correcta", text: $newRespostaCorrecta)
                }

                Section(header: Text("Respuestas Incorrectas")) {
                    ForEach(0..<newRespostesIncorrectes.count, id: \.self) { index in
                        TextField("Respuesta incorrecta \(index + 1)", text: $newRespostesIncorrectes[index])
                    }
                }
            }
            .navigationBarTitle("Agregar Pregunta")
            .navigationBarItems(trailing: Button("Guardar") {
                onSave()
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
