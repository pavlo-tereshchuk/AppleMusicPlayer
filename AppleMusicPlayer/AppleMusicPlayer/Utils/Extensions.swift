//
//  Extensions.swift
//  AppleMusicPlayer
//
//  Created by Pavlo Tereshchuk on 19.04.23.
//

import Foundation
import SwiftUI
import MediaPlayer

extension TimeInterval {

    // MARK: - Public properties

    /// The interval formatted as `m:ss`, as used by the player's time labels.
    var minuteSecond: String {
        String(format:"%d:%02d", minute, second)
    }

    /// The minutes component of the interval, wrapping each hour.
    var minute: Int {
        Int((self/60).truncatingRemainder(dividingBy: 60))
    }

    /// The seconds component of the interval, wrapping each minute.
    var second: Int {
        Int(truncatingRemainder(dividingBy: 60))
    }
}

extension Binding {

    // MARK: - Public methods

    /// Wraps the binding so a handler runs whenever it's written to.
    ///
    /// This is how the scrubber and volume slider push their values through to
    /// the audio player: the binding updates the view model as usual, and the
    /// handler performs the side effect.
    ///
    /// - Parameter handler: A closure called with the new value after it's
    ///   stored.
    /// - Returns: A binding that forwards writes to the original and then to
    ///   `handler`.
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

    // MARK: - Public methods

    /// Sets the system output volume.
    ///
    /// There's no public API for this, so the value is written to the hidden
    /// `UISlider` inside an off-screen `MPVolumeView`. The write is deferred
    /// by a moment because the slider isn't wired up to the audio session
    /// immediately after the view is created.
    ///
    /// - Parameter volume: The target level, from `0` to `1`.
    ///
    /// - Important: This relies on `MPVolumeView`'s private view hierarchy and
    ///   will silently stop working if that changes.
    static func setVolume(_ volume: Float) -> Void {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
    
    
    /// Reads the system output volume from the shared audio session.
    ///
    /// - Returns: The current level from `0` to `1`, or `0` if the session
    ///   can't be activated.
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

    // MARK: - Public properties

    /// The image's single average color, or `nil` if it can't be computed.
    ///
    /// Averaging is done by a Core Image `CIAreaAverage` filter rendered into a
    /// 1×1 bitmap, so cost doesn't scale with the artwork's size.
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
    
    // MARK: - Public methods

    /// Splits the image into its four quadrants.
    ///
    /// - Returns: The top-left, top-right, bottom-left and bottom-right
    ///   quadrants, in that order.
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
    
    /// The average color of each quadrant, used as gradient stops behind the
    /// expanded player.
    ///
    /// Sampling per quadrant rather than once overall keeps some of the
    /// artwork's spatial variation, so the background gradient resembles the
    /// cover art instead of collapsing to a single flat tone.
    func getAverageColors() -> [Color] {
        return self.splitImage().compactMap({Color($0.averageColor ?? .gray)})
    }
}

extension View {

    // MARK: - Public properties

    /// The display's corner radius, inset slightly for the expanded player's
    /// rounded card.
    ///
    /// Read through the screen's private `_displayCornerRadius` key so the
    /// sheet's corners line up with the hardware on every device.
    ///
    /// - Returns: The adjusted radius, or `0` if the value isn't available.
    ///
    /// - Important: This depends on a private UIKit key and may break on
    ///   future OS versions.
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

