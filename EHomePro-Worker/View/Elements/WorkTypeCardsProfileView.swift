//
//  WorkTypeCardsProfileView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/13/24.
//

import SwiftUI

import SwiftUI

struct WorkTypeCardsProfileView: View {
    @Binding var workTypes: [WorkType]
    @Binding var selectedWorkTypes: [WorkerWorkType]
    

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach($workTypes, id: \.id) { $workType in
                    let isSelected = selectedWorkTypes.contains { $0.workTypeId == workType.id }
                    WorkTypeCardProfileView(workType: workType, didSelected: isSelected, selectedWorkTypes: $selectedWorkTypes)
//                        .onAppear {
//                            print("\(selectedWorkTypesID.contains { $0 == workType.id }) \(workType.id) \(isSelected)")
//                        }
                }
            }
            .padding()
        }
        .onAppear {
            
        }
    }

}

//#Preview {
//    WorkTypeCardsProfileView()
//}
