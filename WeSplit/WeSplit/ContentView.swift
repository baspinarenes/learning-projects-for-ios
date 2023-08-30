//
//  ContentView.swift
//  WeSplit
//
//  Created by Enes Başpınar on 29.08.2023.
//

import SwiftUI

struct ContentView: View {
  @State private var checkAmount = 0.0
  @State private var peopleCount = 2
  @State private var tipPercentage = 0.1
  @FocusState private var isFocusedToCheckAmountTextField: Bool
  
  let tipPercentages = [0, 0.05, 0.1, 0.15, 0.20, 0.25]
  
  var checkAmountWithTip: Double {
    return checkAmount * (1 + tipPercentage)
  }
  
  var totalPerPerson: Double {
    return checkAmountWithTip / Double(peopleCount)
  }
  
  private var currency: FloatingPointFormatStyle<Double>.Currency {
    .currency(code: Locale.current.currency?.identifier ?? "USD")
  }
  
  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Amount", value: $checkAmount, format: currency)
            .keyboardType(.decimalPad)
          
          Picker("Number of people", selection: $peopleCount) {
            ForEach(2..<100, id: \.self) {
              Text("\($0) people")
            }
          }
          .pickerStyle(.navigationLink)
          .focused($isFocusedToCheckAmountTextField)
        }
        
        Section {
          Picker("Tip percentage", selection: $tipPercentage) {
            ForEach(tipPercentages, id: \.self) {
              Text($0, format: .percent)
            }
          }
          .pickerStyle(.segmented)
        } header: {
          Text("How much tip do you want to leave?")
        }
        
        Section {
          Text(checkAmountWithTip, format: currency)
        } header: {
          Text("Amount per person")
        }
        
        Section {
          Text(totalPerPerson, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
        } header: {
          Text("Amount per person")
        }
      }
      .navigationTitle("WeSplit")
      .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          
          Button("Done") {
            isFocusedToCheckAmountTextField = false
          }
        }
      }
    }
  }
}

#Preview {
  ContentView()
}
