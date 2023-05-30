//
//  Extensions.swift
//  UberClone
//
//  Created by Cesar Vargas on 09/09/21.
//

import UIKit
import MapKit

extension UIColor {
    
    static func rgb(red: CGFloat, grenn: CGFloat, blue : CGFloat ) -> UIColor {
        
        return UIColor.init(red: red/255, green: grenn/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgroundColor = UIColor.rgb(red: 25, grenn: 25, blue: 25)
    static let mainBlueTint = UIColor.rgb(red: 17, grenn: 154, blue: 237)
    static let outlineStrokeColor = UIColor.rgb(red: 234, grenn: 46, blue: 111)
    static let trackStrokeColor = UIColor.rgb(red: 56, grenn: 25, blue: 49)
    static let pulsatingFillColor = UIColor.rgb(red: 86, grenn: 30, blue: 63)
    
}

extension UIView {
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.65
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 10
        layer.masksToBounds = false
    }
    
    
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerX(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView,
                 leftAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeft: CGFloat = 0,
                 constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    
    
    //MARK: - InputContainetView
    
    func inputContainerView(image: UIImage, textField : UITextField? = nil, segmentedControl: UISegmentedControl? = nil) -> UIView {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 0.87
        view.addSubview(imageView)
        
        if let textField = textField {

            imageView.centerY(inView: view)
            imageView.anchor(left: view.leftAnchor, paddingLeft: 8, width: 24, height: 24)
            
            view.addSubview(textField)
            textField.centerY(inView: view)
            textField.anchor(left: imageView.rightAnchor, bottom: view.bottomAnchor,
                                  right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
        }
        
        if let sc = segmentedControl {
            
            imageView.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: -8,
                             paddingLeft: 8, width: 24, height: 24)
            
            view.addSubview(sc)
            sc.anchor(left: view.leftAnchor, right: view.rightAnchor,
                      paddingLeft: 8, paddingRight: 8)
            
            sc.centerY(inView: view, constant: 8)
        }
        
       
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        view.addSubview(separatorView)
        separatorView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                             right: view.rightAnchor, paddingLeft: 8, height: 0.75)
        
        return view
    }

}


extension UITextField {
    
    func customTextField(withPlaceholder placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        
        let tf = UITextField()
        
        tf.addToolBar()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.keyboardAppearance = .dark
        tf.isSecureTextEntry = isSecureTextEntry
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        return tf
        
    }
    
    
}


extension MKPlacemark {
    var address: String? {
        get {
            guard let subThoroughfare = subThoroughfare,
                    let thoroughfare = thoroughfare ,
                    let locality = locality,
                    let administrativeArea = administrativeArea
            else { return nil }
            
            return "\(subThoroughfare) \(thoroughfare), \(locality), \(administrativeArea)"
            
        }
    }
}

extension MKMapView {
    
    func zoomToFir(annotations: [MKAnnotation]) {
        var zoomrect = MKMapRect.null
        
        annotations.forEach { anno in
            let annotaionPoint = MKMapPoint(anno.coordinate)
            let pointRect = MKMapRect(x: annotaionPoint.x, y: annotaionPoint.y,
                                      width: 0.01, height: 0.01)
            zoomrect = zoomrect.union(pointRect)
        }
        
        let insets = UIEdgeInsets(top: 100, left: 100, bottom: 310.0, right: 100)
        DispatchQueue.main.async {
            self.setVisibleMapRect(zoomrect, edgePadding: insets, animated: true)
        }
    }
    
    func setVisibleMapArea(polyline: MKPolyline) {
        let edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 75.0, left: 75.0,
                                                    bottom: 310.0, right: 75.0)
        DispatchQueue.main.async {
            self.setVisibleMapRect(polyline.boundingMapRect,
                                   edgePadding: edgeInsets, animated: false)
            self.layoutIfNeeded()
        }
    }

    func addAnnotationAndSelect(forCoordinates coords: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coords
        self.addAnnotation(annotation)
        self.selectAnnotation(annotation, animated: true)
    }
}

extension MKMapItem {
  convenience init(coordinate: CLLocationCoordinate2D, name: String) {
    self.init(placemark: .init(coordinate: coordinate))
    self.name = name
  }
}

extension UIViewController {
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {
        if present {
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            loadingView.alpha = 0
            loadingView.tag = 1

            let blurView = UIVisualEffectView()
            blurView.frame = self.view.frame
            blurView.alpha = 0.99
            blurView.effect = UIBlurEffect(style: .systemMaterialDark)
            
            let indicator = UIActivityIndicatorView()
            indicator.style = .large
            indicator.color = .white
            indicator.center = loadingView.center

            let label = UILabel()
            label.text = message
            label.font = UIFont.boldSystemFont(ofSize: 24)
            label.textColor = .white
            label.textAlignment = .center
            label.alpha = 0.87
            
            view.addSubview(loadingView)
            loadingView.addSubview(blurView)
            loadingView.addSubview(indicator)
            loadingView.addSubview(label)

            label.centerX(inView: view)
            label.anchor(top: indicator.bottomAnchor, paddingTop: 32)

            indicator.startAnimating()

            UIView.animate(withDuration: 0.3, delay: 0) {
                loadingView.alpha = 1
            }
        } else {
            view.subviews.forEach { subview in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3, delay: 0, options: []) {
                        subview.alpha = 0
                    } completion: { _ in
                        subview.removeFromSuperview()
                    }

                }
            }
        }
    }

    func presentAlertController(title: String, withMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension UIView {
    func applyBackgroundBlur(style: UIBlurEffect.Style, mframe: CGRect? = nil) {
        let blurView = UIVisualEffectView()
        blurView.frame = mframe ?? self.frame
        blurView.effect = UIBlurEffect(style: style)
        self.addSubview(blurView)
    }
}
