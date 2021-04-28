//
//  FilterSettingsView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/28/21.
//

import Foundation
import SwiftUI

struct FilterSettingsView: View
{
    @ObservedObject var Storage = SettingsUI()
    @State var IsVisible: Bool
    @State var ViewTitle: String = "Some Title"
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            NavigationView
            {
                VStack()
                {
                    switch self.$Storage.CurrentFilter.wrappedValue
                    {
                        case BuiltInFilters.HueAdjust.rawValue:
                            Hue_View()
                            
                        default:
                            NoSettingsView()
                    }
                    Spacer()
                    Button(action:
                            {
                                IsVisible.toggle()
                            }
                        )
                    {
                        Text("Done")
                            .font(.custom("Avenir-Black", size: 24.0))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .shadow(radius: 3)
                }
                .position(x: Geometry.size.width / 2,
                          y: 150.0)
                

                .navigationBarTitle(Text(ViewTitle))
                .border(Color.gray, width: 1)
                .toolbar
                {
                    ToolbarItem(placement: .navigationBarTrailing)
                    {
                        Button(action:
                                {
                                    IsVisible.toggle()
                                }
                        )
                        {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                }
            }
            .frame(width: Geometry.size.width * 0.8,
                   height: Geometry.size.height * 0.65)
            .position(x: IsVisible ? Geometry.size.width / 2.0 : -Geometry.size.width / 2.0,
                      y: Geometry.size.height / 2.0)
            .animation(.linear(duration: IsVisible ? 0.1 : 0.2))
            .transition(.slide)
        }
    }
}
