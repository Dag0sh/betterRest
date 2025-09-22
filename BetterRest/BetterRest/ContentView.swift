//
//  ContentView.swift
//  BetterRest
//
//  Created by Dagosh on 07.09.2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var wakeUp = defaultWakeTime
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isAlertPresented = false
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {

        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    Form {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Когда проснемся?")
                                .font(.headline)

                            DatePicker(
                                "Введите время",
                                selection: $wakeUp,
                                displayedComponents: .hourAndMinute,
                            )
                            .labelsHidden()
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Желаемое количество часов сна")
                                .font(.headline)
                            Stepper(
                                "\(sleepAmount.formatted()) hours",
                                value: $sleepAmount,
                                in: 4...12,
                                step: 0.25
                            )
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Сколько кружек коффе опустущены?")
                                .font(.headline)

                            Stepper(
                                "^[\(coffeeAmount) cup](inflect: true)",
                                value: $coffeeAmount,
                                in: 1...20
                            )
                            .padding()
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .navigationTitle("BetterRest")
                    .navigationBarTitleDisplayMode(.automatic)
                    .toolbar {
                        Button("Calculate", action: calculateBedtime)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.4))
                            .frame(width: 200, height: 200)

                        Text("\(isNightTime ? "🛌" : "🤪")")
                            .font(.system(size: 80))
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .alert(alertTitle, isPresented: $isAlertPresented) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
        .ignoresSafeArea()

    }

    private var isNightTime: Bool {
        let hour = Calendar.current.component(.hour, from: Date.now)
        return hour >= 22 || hour < 8
    }

    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents(
                [.hour, .minute],
                from: wakeUp
            )
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let predication = try model.prediction(
                wake: Double(
                    hour + minute
                ),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )
            let sleepTime = wakeUp - predication.actualSleep
            alertTitle = "bedtime is "
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "bububu"
            alertMessage = "problem calculating your bedtime"
        }
        isAlertPresented = true
    }
}

#Preview {
    ContentView()
}
