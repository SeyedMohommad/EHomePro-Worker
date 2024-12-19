//
//  WorkTypeCardProfileView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/13/24.
//

import SwiftUI

struct WorkTypeCardProfileView: View {
    let workType:WorkType
    @State var didSelected:Bool
    @Binding var selectedWorkTypes:[WorkerWorkType]
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .frame(width: 100,height:150)
            //                    .foregroundColor(Color(uiColor:didSelected ?? UIColor(hexStringToUIColor(hex: "#818CA1"):UIColor.white)))
                .foregroundColor(Color(uiColor: didSelected ? hexStringToUIColor(hex: "#818CA1"): .white))
            
            
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 70,height: 70)
                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#E5E5E5")))
                    Image(workType.logo)
                        .resizable()
                        .frame(width: 45,height: 45)
                    
                }
                .padding(.horizontal)
                
                Text(workType.name)
                    .font(.system(size: 8,weight: .bold))
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                    .padding()
                
            }
            
            
        }
        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
        
        .onTapGesture {
            didSelected.toggle()
            if didSelected {
                
                guard let workerId = UserDefaults.standard.string(forKey: "WorkerId") else {
                    return
                }
                let workerWorkType = WorkerWorkType(id: nil , workerId: Int(workerId)!, workTypeId: workType.id, status: true)
                selectedWorkTypes.append(workerWorkType)
                
//                for selectedWorkType in selectedWorkTypesID {
//                    if selectedWorkType == workType.id {
//                        self.selectedWorkTypesID.append(selectedWorkType)
//                    }
//                }
                
            } else {
                if let index = selectedWorkTypes.firstIndex(where: { $0.workTypeId == workType.id }) {
                    selectedWorkTypes.remove(at: index)
                }
            }
        }
    }
//    private func generateValidId() -> Int {
//        var uuidInt: Int?
//        
//        // تولید UUID تا زمانی که یک عدد معتبر بدست آید
//        repeat {
//            let uuid = UUID().uuidString
//            let digits = uuid.filter { $0.isNumber }
//            uuidInt = Int(digits.prefix(9)) // فقط 9 رقم اول استفاده می‌شود تا مطمئن شویم عدد در محدوده Int است
//        } while uuidInt == nil || uuidInt! <= 0
//        
//        return uuidInt!
//    }
    
}

//#Preview {
//    WorkTypeCardProfileView()
//}
