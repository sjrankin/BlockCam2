//
//  SelectedImageView.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 6/2/21.
//

import SwiftUI

struct HistogramImageView: View
{
    @Binding var ShowPicker: Bool
    @Binding var Updated: Bool
    
    var body: some View
    {
        if Utility.HaveHistogramSource()
        {
            Image(uiImage: Utility.GetHistogramSource()!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.black)
                .border(Color.black, width: 0.5)
                .frame(alignment: .center)
                .gesture(
                    TapGesture(count: 1)
                        .onEnded(
                            {
                                ShowPicker = true
                            }
                        )
                )
        }
        else
        {
            Image(systemName: "slash.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color(UIColor.systemYellow))
                .border(Color.black, width: 0.5)
                .foregroundColor(Color(UIColor.systemRed))
                .gesture(
                    TapGesture(count: 1)
                        .onEnded(
                            {
                                ShowPicker = true
                            }
                        )
                )
        }
    }
}

struct SelectedImageView: View
{
    @Binding var Updated: Bool
    @State var ShowPicker: Bool = false
    @State var SelectedImageName: String? = nil
    @State var SelectedImage: UIImage? = nil
    @State var SelectedImageURL: URL? = nil
    
    var body: some View
    {
        VStack(alignment: .center)
        {
            Text("Histogram Source Image")
                .frame(alignment: .center)
                .font(.subheadline)
                .foregroundColor(.gray)
            HistogramImageView(ShowPicker: $ShowPicker,
                               Updated: $Updated)
            Text("Tap image to select new source.")
                .frame(alignment: .center)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .sheet(isPresented: $ShowPicker)
        {
            ImagePicker(SelectedImage: $SelectedImage,
                        SelectedImageName: $SelectedImageName,
                        SelectedImageURL: $SelectedImageURL)
        }
        .onChange(of: SelectedImageURL)
        {
            NewValue in
            if let SomeURL = NewValue
            {
                if let HImage = UIImage(contentsOfFile: SomeURL.path)
                {
                    Utility.AddHistogramSource(FileName: "HistogramSource.jpg",
                                               Image: HImage)
                    Updated.toggle()
                }
            }
        }
    }
}

struct SelectedImageView_Previews: PreviewProvider
{
    @State static var NotUsed: Bool = false
    
    static var previews: some View
    {
        SelectedImageView(Updated: $NotUsed)
    }
}
