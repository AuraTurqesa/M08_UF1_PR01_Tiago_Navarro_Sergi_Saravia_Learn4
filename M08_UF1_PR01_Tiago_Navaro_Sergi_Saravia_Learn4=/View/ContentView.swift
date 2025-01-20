import SwiftUI

struct ContentView: View {
    @StateObject private var triviaManager = TriviaManager()
    @State private var currentTrivia: Trivia? = nil
    @State private var respostaSeleccionada: String? = nil
    @State private var punts: Int = 0
    @State private var currentOpcions: [String] = []
    @State private var preguntesUsades: [Trivia] = []
    @State private var jocIniciat: Bool = false
    @State private var mostrarFinal: Bool = false
    @State private var showAddQuestionModal: Bool = false
    @State private var totalRespostes: Int = 0
    @State private var editMode: EditMode = .inactive
    @State private var puntsAcumulats: Int = 0

    // Variables para la nueva trivia
    @State private var newPreguntaText: String = ""
    @State private var newCategoria: String = ""
    @State private var newRespostaCorrecta: String = ""
    @State private var newDificultat: String = ""
    @State private var newRespostesIncorrectes: [String] = Array(repeating: "", count: 3)
    @State private var newRegions: [String] = []
    @State private var newTags: [String] = []
    @State private var newEsNiche: Bool = false
    @State private var newTipo: String = ""
    @State private var newPuntsAcumulats = 0
    @State private var newID: String = UUID().uuidString

    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation

    init() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }

    var body: some View {
        NavigationView {
            TabView {
                // Primera pestanya: Llistat de preguntes
                GeometryReader { geometry in
                    VStack {
                        Text("Nombre total de preguntas: \(triviaManager.trivies.count)")
                            .font(.system(size: 14))
                            .padding()
                            .lineLimit(nil)

                        List {
                            ForEach(triviaManager.trivies) { trivia in
                                NavigationLink(destination: DetailView(trivia: trivia)){
                                    VStack(alignment: .leading) {
                                        Text(trivia.pregunta.text)
                                            .font(.system(size: 14))
                                        Text("Categoria: \(trivia.categoria)")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .onDelete(perform: deleteTrivia)
                            .onMove(perform: moveTrivia)
                        }
                    }
                    .environment(\.editMode, $editMode)
                }
                .tabItem {
                    Label("Preguntas", systemImage: "list.bullet")
                }

                // Segona pestanya: Joc de trivia
                GeometryReader { geometry in
                    VStack {
                        Text("Puntos acumulados: \(punts)")
                            .font(.system(size: 14))
                            .padding()
                            .lineLimit(nil)
                        if !jocIniciat {
                            Spacer()
                            Button(action: {
                                jocIniciat = true
                                generarNovaPregunta()
                            }) {
                                Text("Comenzar el juego")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .lineLimit(nil)
                            }
                            Spacer()
                        } else if let trivia = currentTrivia {
                            Text(trivia.pregunta.text)
                                .font(.system(size: 14))
                                .padding()
                                .lineLimit(nil)

                            // Opcions en dues columnes
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 20) {
                                ForEach(currentOpcions, id: \.self) { opcio in
                                    Button(action: {
                                        respostaSeleccionada = opcio
                                        comprovarResposta(opcio: opcio, trivia: trivia)
                                    }) {
                                        Text(opcio)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(minWidth: 0, maxWidth: .infinity) // Assegura que tots els botons tinguin la mateixa amplada
                                            .background(respostaSeleccionada == opcio ? Color.gray : Color.blue)
                                            .cornerRadius(10)
                                            .lineLimit(nil)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .tabItem {
                    Label("Jugar", systemImage: "gamecontroller")
                }
            }
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

                // Añadir el observador para cambiar la orientación
                NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                    self.orientation = UIDevice.current.orientation
                }
            }
            .onDisappear {
                // Dejar de generar notificaciones cuando la vista desaparezca
                UIDevice.current.endGeneratingDeviceOrientationNotifications()
            }
            .background(
                NavigationLink(destination: FinalView(punts: punts, totalRespostes: totalRespostes, onRedirigir: redirigir), isActive: $mostrarFinal) {
                    EmptyView()
                }
            )
            .sheet(isPresented: $showAddQuestionModal) {
                // Vista de la hoja modal para agregar una nueva pregunta
                AddTriviaModalView(
                    categoria: $newCategoria,
                    id: $newID,
                    dificultat: $newDificultat,
                    regions: $newRegions,
                    esNiche: $newEsNiche,
                    pregunta: $newPreguntaText,
                    respostaCorrecta: $newRespostaCorrecta,
                    respostesIncorrectes: $newRespostesIncorrectes,
                    tipus: $newTipo,
                    puntsAcumulats: $newPuntsAcumulats,
                    onSave: addTrivia
                )
            }
        }
        .onChange(of: orientation) { newOrientation in
            if newOrientation == .portraitUpsideDown {
                // Cuando está al revés, rotar la vista
                print("Dispositivo al revés")
            }
        }
    }

    func addTrivia() {
        // Crear un nuevo objeto Trivia
        let newTrivia = Trivia(
            categoria: newCategoria,
            id: newID,
            tags: newTags,
            dificultat: newDificultat,
            regions: newRegions,
            esNiche: newEsNiche,
            pregunta: Pregunta(text: newPreguntaText),
            respostaCorrecta: newRespostaCorrecta,
            respostesIncorrectes: newRespostesIncorrectes,
            tipus: newTipo,
            puntsAcumulats: newPuntsAcumulats // Puntos iniciales
        )

        // Agregar la nueva trivia al array de trivies en el triviaManager
        triviaManager.trivies.append(newTrivia)
    }

    func generarNovaPregunta() {
        respostaSeleccionada = nil

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

    func comprovarResposta(opcio: String, trivia: Trivia) {
        if opcio == trivia.respostaCorrecta {
            punts += 1
        }
        totalRespostes += 1

        // Mostrar alerta con dos botones
        let titol = opcio == trivia.respostaCorrecta ? "Correcto!" : "Incorrecto"
        let missatge = opcio == trivia.respostaCorrecta ? "🎉 Respuesta correcta!" : "😞 La respuesta correcta es: \(trivia.respostaCorrecta)"
        
        mostrarAlert(titol: titol, missatge: missatge, onContinuar: generarNovaPregunta, onReiniciar: reiniciarJoc)
    }

    func opcionsAleatories(trivia: Trivia) -> [String] {
        let opcions = trivia.respostesIncorrectes + [trivia.respostaCorrecta]
        return opcions.shuffled()
    }

    func reiniciarJoc() {
        jocIniciat = false
        currentTrivia = nil
        respostaSeleccionada = nil
        preguntesUsades.removeAll()
        triviaManager.fetchTrivies()

        mostrarFinal = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            mostrarFinal = false
        }
    }

    func redirigir() {
        jocIniciat = false
        punts = 0
        totalRespostes = 0
        triviaManager.fetchTrivies()
    }

    func mostrarAlert(titol: String, missatge: String, onContinuar: @escaping () -> Void, onReiniciar: @escaping () -> Void) {
        let alert = UIAlertController(title: titol, message: missatge, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Reiniciar", style: .destructive, handler: { _ in
            onReiniciar()
        }))
        
        alert.addAction(UIAlertAction(title: "Continuar", style: .default, handler: { _ in
            onContinuar()
        }))
        
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }

    func moveTrivia(from source: IndexSet, to destination: Int) {
        triviaManager.trivies.move(fromOffsets: source, toOffset: destination)
    }

    func deleteTrivia(at offsets: IndexSet) {
        triviaManager.trivies.remove(atOffsets: offsets)
    }
}


struct FinalView: View {
    var punts: Int
    var totalRespostes: Int
    var onRedirigir: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Has contestado \(totalRespostes) respuestas.")
                    .font(.system(size: 16))
                    .padding()
                    .lineLimit(nil)

                Spacer()

                Button(action: {
                    onRedirigir()
                }) {
                    Text("Volver al juego")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .lineLimit(nil)
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
}

struct AddTriviaModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var categoria: String
    @Binding var id: String
    @Binding var dificultat: String
    @Binding var regions: [String]
    @Binding var esNiche: Bool
    @Binding var pregunta: String
    @Binding var respostaCorrecta: String
    @Binding var respostesIncorrectes: [String]
    @Binding var tipus: String
    @Binding var puntsAcumulats: Int
    var onSave: () -> Void
    
    @State private var showAlert = false // Controla si la alerta se muestra
    @State private var alertMessage = "" // Mensaje de la alerta
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pregunta")) {
                    TextField("Escribe la pregunta", text: $pregunta)
                }
                
                Section(header: Text("Categoría")) {
                    TextField("Escribe la categoría", text: $categoria)
                }
                
                Section(header: Text("ID")) {
                    TextField("Escribe el ID", text: $id)
                }
                
                
                Section(header: Text("Dificultad")) {
                    TextField("Escribe la dificultad", text: $dificultat)
                }
                
                Section(header: Text("Regiones")) {
                    ForEach(0..<regions.count, id: \.self) { index in
                        TextField("Región \(index + 1)", text: $regions[index])
                    }
                    Button("Agregar Región") {
                        regions.append("")
                    }
                }
                
                Section(header: Text("Es Niche")) {
                    Toggle("¿Es una pregunta niche?", isOn: $esNiche)
                }
                
                Section(header: Text("Respuesta Correcta")) {
                    TextField("Escribe la respuesta correcta", text: $respostaCorrecta)
                }
                
                Section(header: Text("Respuestas Incorrectas")) {
                    ForEach(0..<respostesIncorrectes.count, id: \.self) { index in
                        TextField("Respuesta incorrecta \(index + 1)", text: $respostesIncorrectes[index])
                    }
                    Button("Agregar Respuesta Incorrecta") {
                        respostesIncorrectes.append("")
                    }
                }
                
                Section(header: Text("Tipo")) {
                    TextField("Escribe el tipo", text: $tipus)
                }
                
                Section(header: Text("Puntos Acumulados")) {
                    Stepper(value: $puntsAcumulats, in: 0...100) {
                        Text("Puntos: \(puntsAcumulats)")
                    }
                }
            }
            .navigationBarTitle("Agregar Trivia")
            .navigationBarItems(
                leading: Button("Cancelar", action: { presentationMode.wrappedValue.dismiss() }),
                trailing: Button("Guardar") {
                    if validarCampos() {
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        showAlert = true // Mostrar la alerta si los campos no son válidos
                    }
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Campos Incompletos"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Aceptar"))
                )
            }
        }
    }
    
    // Función para validar que todos los campos estén llenos
    func validarCampos() -> Bool {
        if pregunta.isEmpty || categoria.isEmpty || id.isEmpty || dificultat.isEmpty || respostaCorrecta.isEmpty || respostesIncorrectes.contains(where: { $0.isEmpty }) {
            alertMessage = "Todos los campos son obligatorios, por favor llena todos los campos."
            return false
        }
        return true
    }
}
