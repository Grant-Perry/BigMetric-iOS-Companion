import SwiftUI

struct WorkoutHeaderView: View {
    let cityName: String
    let address: Address?
    let routeStartDate: Date?
    let weatherTemp: String?
    let weatherSymbol: String?
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                if let routeDate = routeStartDate {
                    Text(routeDate, formatter: dateFormatter)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 24)
                }
                
                if let address = address {
                    Text(address.city)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text(cityName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            if let wTemp = weatherTemp, let wSymbol = weatherSymbol {
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: wSymbol)
                        .font(.system(size: 48))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white)
                    Text("\(wTemp)°")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.top, 24)
                .padding(.trailing, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}