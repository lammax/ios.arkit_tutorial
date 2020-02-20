//
//  File.swift
//  ARKit_tutorial
//
//  Created by Mac on 29/10/2018.
//  Copyright © 2018 Lammax. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum ColorPickerSliderConstant {
    static let colorPickerSliderHeightMin: CGFloat = 2.0
    static let uiSliderHeightDefault: CGFloat = 31.0
}

public typealias ColorChangeBlock = (_ color: UIColor?) -> Void

open class ColorPickerSlider: UIView {
    
    //MARK:- Open constant
    //MARK:-
    /**
     User can use this value to change the slider height.
     */
    open var colorPickerSliderHeight: CGFloat = 4.0 //Min value
    
    //MARK:- Private variables
    //MARK:-
    fileprivate var currentHueValue : Float = 0.0
    fileprivate var currentSliderColor = UIColor.black
    fileprivate var hueImage: UIImage!
    fileprivate var slider: UISlider!
    
    //MARK:- Open variables
    //MARK:-
    open var didChangeColor: ColorChangeBlock?
    open var bwBounds: CGFloat = 5.0
    
    //MARK:- Override Functions
    //MARK:-
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        backgroundColor = UIColor.clear
        update()
    }
    
    override open func draw(_ rect: CGRect) {
        
        super.draw(rect)
        if slider == nil {
            let sliderRect = CGRect(x: rect.origin.x, y:  (rect.size.height - ColorPickerSliderConstant.uiSliderHeightDefault) * 0.5,
                                    width: rect.width, height: ColorPickerSliderConstant.uiSliderHeightDefault)
            slider = UISlider(frame: sliderRect)
            slider.setValue(slider.minimumValue, animated: false)
            slider.addTarget(self, action: #selector(onSliderValueChange), for: UIControl.Event.valueChanged)
            slider.thumbTintColor = currentSliderColor
            slider.minimumTrackTintColor = UIColor.clear
            slider.maximumTrackTintColor = UIColor.clear
            
            addSubview(slider)
            
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.leadingAnchor.constraint(equalTo: slider.superview!.leadingAnchor, constant: 0).isActive = true
            slider.topAnchor.constraint(equalTo: slider.superview!.topAnchor, constant: 0).isActive = true
            slider.trailingAnchor.constraint(equalTo: slider.superview!.trailingAnchor, constant: 0).isActive = true
            slider.bottomAnchor.constraint(equalTo: slider.superview!.bottomAnchor, constant: 0).isActive = true
            
        }
        
        let heigthForSliderImage = max(colorPickerSliderHeight, ColorPickerSliderConstant.colorPickerSliderHeightMin)
        let sliderImageRect = CGRect(x: rect.origin.x, y: (rect.size.height - heigthForSliderImage) * 0.5,
                                     width: rect.width, height: heigthForSliderImage)
        if hueImage != nil {
            hueImage.draw(in: sliderImageRect)
        }
        
    }
    
    //MARK:- Internal Functions
    //MARK:-
    @objc func onSliderValueChange(slider: UISlider) {
        
        currentHueValue = slider.value
        
        switch currentHueValue {
        case slider.minimumValue:
            currentSliderColor = UIColor.black
        case slider.maximumValue:
            currentSliderColor = UIColor.white
        default:
            currentSliderColor = UIColor(hue: CGFloat(currentHueValue), saturation: 1, brightness: 1, alpha: 1)
        }
        
        slider.thumbTintColor = currentSliderColor
        self.didChangeColor?(currentSliderColor)
    }
}

fileprivate extension ColorPickerSlider {
    
    func update() {
        
        if hueImage == nil {
            let heigthForSliderImage = max(colorPickerSliderHeight, ColorPickerSliderConstant.colorPickerSliderHeightMin)
            let size: CGSize = CGSize(width: frame.width, height: heigthForSliderImage)
            hueImage = generateHUEImage(size)
        }
    }
    
    func generateHUEImage(_ size: CGSize) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let heigthForSliderImage = max(colorPickerSliderHeight, ColorPickerSliderConstant.colorPickerSliderHeightMin)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIBezierPath(roundedRect: rect, cornerRadius: heigthForSliderImage * 0.5).addClip()
        
        //Black bound
        UIColor.black.set()
        UIRectFill(CGRect(x: 0, y: 0, width: bwBounds, height: size.height))
        
        for x: Int in Int(bwBounds) ..< Int(size.width - bwBounds) {
            UIColor(hue: CGFloat(CGFloat(x) / size.width), saturation: 1.0, brightness: 1.0, alpha: 1.0).set()
            let temp = CGRect(x: CGFloat(x), y: 0, width: 1, height: size.height)
            UIRectFill(temp)
        }
        //White bound
        UIColor.white.set()
        UIRectFill(CGRect(x: size.width - bwBounds, y: 0, width: bwBounds, height: size.height))
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
