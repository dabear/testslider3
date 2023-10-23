//
//  InsertCannulaView.swift
//  OmniBLE
//
//  Created by Pete Schwamb on 2/5/20.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import SwiftUI

import SlideButton
import LoopKitUI
struct InsertCannulaView: View {
    
    @ObservedObject var viewModel: InsertCannulaViewModel
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var cancelModalIsPresented: Bool = false
    
    var body: some View {
        GuidePage(content: {
            VStack {
                Image(systemName: "cloud.sun.rain.fill")

                HStack {
                    InstructionList(instructions: [
                        "Slide the switch below to start cannula insertion.",
                        "Wait until insertion is completed.",
                    ])
                    .disabled(viewModel.state.instructionsDisabled)

                }
                .padding(.bottom, 8)
            }
            .accessibility(sortPriority: 1)
        }) {
            VStack {
                if self.viewModel.state.showProgressDetail {
                    
                        Text("Error")
                    

                    if self.viewModel.error == nil {
                        VStack {
                            ProgressIndicatorView(state: self.viewModel.state.progressState)
                            if self.viewModel.state.isFinished {
                                Text("Inserted")
                                    .bold()
                                    .padding(.top)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }
                if self.viewModel.error != nil {
                    Button(action: {
                        self.viewModel.didRequestDeactivation?()
                    }) {
                        Text("Deactivate Pod")
                            .accessibility(identifier: "button_deactivate_pod")
                            .actionButtonStyle(.secondary)
                    }
                    .disabled(self.viewModel.state.isProcessing)
                }
                
                if (self.viewModel.error == nil || self.viewModel.error?.recoverable == true) {
                    actionButton
                    .disabled(self.viewModel.state.isProcessing)
                    .animation(nil)
                    .zIndex(1)
                        
                }
            }
            .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
            .padding()
        }
        .animation(.default)
        .alert(isPresented: $cancelModalIsPresented) { cancelPairingModal }
        .navigationBarTitle("Insert Cannula")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(trailing: cancelButton)
    }
    
    
    var actionText : some View {
        Text(self.viewModel.state.nextActionButtonDescription)
            .accessibility(identifier: "button_next_action")
            .accessibility(label: Text(self.viewModel.state.actionButtonAccessibilityLabel))
            .font(.headline)
            
    }
    
    
    @ViewBuilder
    var actionButton: some View {
        if self.viewModel.stateNeedsDeliberateUserAcceptance {
            SlideButton(action: {
                print("awaiting for 1 seconds")
                try? await Task.sleep(for: .seconds(1))
                self.viewModel.continueButtonTapped()
                
                
            }) {
                actionText
            }
            
        } else {
            Button(action: {
                self.viewModel.continueButtonTapped()
            }) {
                actionText
                    .actionButtonStyle(.primary)
            }
            
        }
        
        
    }
    
    var cancelButton: some View {
        Button("Cancel") {
            cancelModalIsPresented = true
        }
        .accessibility(identifier: "button_cancel")
    }
    
    var cancelPairingModal: Alert {
        return Alert(
            title: Text("Are you sure you want to cancel Pod setup?"),
            message: Text("If you cancel Pod setup, the current Pod will be deactivated and will be unusable."),
            primaryButton: Alert.Button.default(Text("yes"), action: {
                //yes
            }),
            secondaryButton: Alert.Button.cancel(Text("No, Continue With Pod"), action: {
                //no
            })
        )
    }

}
class MockCannulaInserter: CannulaInserter {
    public func insertCannula(completion: @escaping (Result<TimeInterval,Error>) -> Void) {
        let mockDelay = TimeInterval(3)
        let result :Result<TimeInterval, Error> = .success(mockDelay)
        completion(result)
    }
    
    func checkCannulaInsertionFinished(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
    
}
struct InsertCannulaView_Previews: PreviewProvider {
    static var mockInserter = MockCannulaInserter()
    static var model = InsertCannulaViewModel(cannulaInserter: mockInserter)
    static var previews: some View {
        InsertCannulaView(viewModel: model)
 

        
    }
}
