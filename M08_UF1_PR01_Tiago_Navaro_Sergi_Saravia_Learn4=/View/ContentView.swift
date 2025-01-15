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
    @State private var totalRespostes: Int = 0
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation // Variable per detectar l'orientació del dispositiu

    init() {
        // Iniciar la detecció de l'orientació del dispositiu
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }

    var body: some View {
        NavigationView {
            TabView {
                // Primera pestanya: Llistat de preguntes
                GeometryReader { geometry in
                    VStack {
                        Text("Nombre total de preguntes: \(triviaManager.trivies.count)")
                            .font(.system(size: 14))
                            .padding()
                            .lineLimit(nil)

                        List(triviaManager.trivies) { trivia in
                            VStack(alignment: .leading) {
                                Text(trivia.pregunta.text)
                                    .font(.system(size: 14))
                                    .lineLimit(nil)
                                Text("Categoria: \(trivia.categoria)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .lineLimit(nil)
                            }
                        }
                    }
                }
                .tabItem {
                    Label("Preguntes", systemImage: "list.bullet")
                }

                // Segona pestanya: Joc de trivia
                GeometryReader { geometry in
                    VStack {
                        Text("Punts acumulats: \(punts)")
                            .font(.system(size: 14))
                            .padding()
                            .lineLimit(nil)

                        if !jocIniciat {
                            Spacer()
                            Button(action: {
                                jocIniciat = true
                                generarNovaPregunta()
                            }) {
                                Text("Començar el joc")
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
                                            .lineLimit(nil) // Evitar que el text es talli
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
            .onAppear {
                if triviaManager.trivies.isEmpty {
                    triviaManager.fetchTrivies()
                }

                // Afegir l'observador per canviar l'orientació
                NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                    self.orientation = UIDevice.current.orientation
                }
            }
            .onDisappear {
                // Deixar de generar notificacions quan la vista desaparegui
                UIDevice.current.endGeneratingDeviceOrientationNotifications()
            }
            .background(
                NavigationLink(destination: FinalView(punts: punts, totalRespostes: totalRespostes, onRedirigir: redirigir), isActive: $mostrarFinal) {
                    EmptyView()
                }
            )
        }
        .onChange(of: orientation) { newOrientation in
            if newOrientation == .portraitUpsideDown {
                // Quan estigui al revés, rotar la vista
                print("Dispositiu al revés")
            }
        }
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

        // Mostrar alerta amb dos botons
        let titol = opcio == trivia.respostaCorrecta ? "Correcte!" : "Incorrecte"
        let missatge = opcio == trivia.respostaCorrecta ? "🎉 Resposta correcta!" : "😞 La resposta correcta és: \(trivia.respostaCorrecta)"
        
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
}

struct FinalView: View {
    var punts: Int
    var totalRespostes: Int
    var onRedirigir: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Has contestat \(totalRespostes) respostes.")
                    .font(.system(size: 16))
                    .padding()
                    .lineLimit(nil)

                Spacer()

                Button(action: {
                    onRedirigir()
                }) {
                    Text("Tornar al joc")
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
