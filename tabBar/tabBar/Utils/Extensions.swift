//
//  Extensions.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 19.04.23.
//

import Foundation
import SwiftUI
import MediaPlayer

extension TimeInterval {
    var minuteSecond: String {
        String(format:"%d:%02d", minute, second)
    }
    
    var minute: Int {
        Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        Int(truncatingRemainder(dividingBy: 60))
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

//Update system volume
extension MPVolumeView {

    static func setVolume(_ volume: Float) -> Void {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
    
    
    static func getVolume() -> Float {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            let volume = audioSession.outputVolume
            return volume
        } catch {
            print("Error getting audio session active: \(error.localizedDescription)")
            return 0.0
        }
    }     
}

extension UIImage {
    // Average color of the image, nil if it cannot be found
    var averageColor: UIColor? {
        // convert our image to a Core Image Image
        guard let inputImage = CIImage(image: self) else { return nil }

        // Create an extent vector (a frame with width and height of our current input image)
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)

        // create a CIAreaAverage filter to pull the average color from the image later on
        guard let filter = CIFilter(name: "CIAreaAverage",
                                  parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        // A bitmap consisting of (r, g, b, a) value
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])

        // Render our output image into a 1 by 1 image supplying it our bitmap to update the values of (i.e the rgba of the 1 by 1 image will fill out bitmap array
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        

        // Convert our bitmap images of r, g, b, a to a UIColor
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
    
    func splitImage() -> [UIImage] {
        let imgWidth = self.size.width / 2
        let imgHeight = self.size.height / 2
        var imgImages:[UIImage] = []

        let leftHigh = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
        let rightHigh = CGRect(x: imgWidth, y: 0, width: imgHeight, height: imgHeight)
        let leftLow = CGRect(x: 0, y: imgHeight, width: imgWidth, height: imgHeight)
        let rightLow = CGRect(x: imgWidth, y: imgHeight, width: imgWidth, height: imgHeight)

        let leftQH = self.cgImage?.cropping(to:leftHigh)
        let rightHQ = self.cgImage?.cropping(to:rightHigh)
        let leftQL = self.cgImage?.cropping(to:leftLow)
        let rightQL = self.cgImage?.cropping(to:rightLow)

        imgImages.append(UIImage(cgImage: leftQH!))
        imgImages.append(UIImage(cgImage: rightHQ!))
        imgImages.append(UIImage(cgImage: leftQL!))
        imgImages.append(UIImage(cgImage: rightQL!))

        return imgImages
    }
    
    func getAverageColors() -> [Color] {
        return self.splitImage().compactMap({Color($0.averageColor ?? .gray)})
    }
}

extension View {
    var deviceCornerRadius: CGFloat {
        let key = "_displayCornerRadius"
        if let screen = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen {
            if let cornerRadius = screen.value(forKey: key) as? CGFloat {
                return cornerRadius - 10
            }
        }
     return 0
    }
}

