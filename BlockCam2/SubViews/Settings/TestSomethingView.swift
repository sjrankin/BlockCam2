//
//  TestSomethingView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/27/21.
//

import SwiftUI

struct RunTest: View
{
    @State var Test: String
    
    var body: some View
    {
        switch Test
        {
            case "3D Processing View":
                Test_3DProcessingView()
                
            case "Circular Progress":
                Test_CircularProgressView()
                
            default:
                UnexpectedView()
        }
    }
}

struct TestSomethingView: View
{
    @ObservedObject var Storage = SettingsUI()
    @State var TestValue: Bool = false
    
    var body: some View
    {
        GeometryReader
        {
            Geometry in
            List(TestOptions)
            {
                SomeTest in
                NavigationLink(destination: RunTest(Test: SomeTest.Title))
                {
                    SettingsItemView(SettingData: SomeTest)
                }
            }
            .navigationBarTitle(Text("Test Something"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TestSomethingView_Previews: PreviewProvider
{
    static var previews: some View
    {
        TestSomethingView()
    }
}

