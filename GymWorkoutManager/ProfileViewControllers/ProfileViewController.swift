//
//  ProfileViewController.swift
//  GymWorkoutManager
//
//  Created by Liguo Jiao on 16/5/14.
//  Copyright © 2016年 McKay. All rights reserved.
//

import UIKit
import RealmSwift
import JVFloatLabeledTextField


class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    // MARK: - IBOutlet
    @IBOutlet var profilePicture: RoundButton!
    @IBOutlet var headerView: UIView!
    @IBOutlet var name: JVFloatLabeledTextField!
    @IBOutlet var bodyWeight: JVFloatLabeledTextField!
    @IBOutlet var age: JVFloatLabeledTextField!
    @IBOutlet var bodyHeight: JVFloatLabeledTextField!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var viewForAdaptForKeyboard: UIView!
    
    var keyboardIsShown = false
    
    var tapRecognizer: UITapGestureRecognizer? = nil

    //@IBOutlet weak var backgroundScrollView: UIScrollView!
    
    // MARK: - Variables
    var curentUser:Person?
    
    @IBAction func female(sender: AnyObject) {
        femaleButton.backgroundColor = GWMColorPurple
        maleButton.backgroundColor = GWMColorYellow
        DatabaseHelper.sharedInstance.beginTransaction()
        curentUser?.sex = "female"
        DatabaseHelper.sharedInstance.commitTransaction()
        let cusers = DatabaseHelper.sharedInstance.queryAll(Person())
        guard let numberOfUser = cusers?.count else {
            return
        }
        checkUser(numberOfUser)
    }
    @IBAction func male(sender: AnyObject) {
        maleButton.backgroundColor = GWMColorPurple
        femaleButton.backgroundColor = GWMColorYellow
        DatabaseHelper.sharedInstance.beginTransaction()
        curentUser?.sex = "male"
        DatabaseHelper.sharedInstance.commitTransaction()
        let cusers = DatabaseHelper.sharedInstance.queryAll(Person())
        guard let numberOfUser = cusers?.count else {
            return
        }
        checkUser(numberOfUser)
    }
    
    private func checkUser(numberOfUser:Int) {
        if numberOfUser <= 0 {
            curentUser!.id = NSUUID.init().UUIDString
            DatabaseHelper.sharedInstance.insert(curentUser!)
        }
    }
    
    
    // MARK: Profile Image
    @IBAction func selectPicture(sender: AnyObject) {
        let alert = UIAlertController(title: "Profile image", message: "Upload your profile image.", preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (UIAlertAction) in
            self.popupImageSelection(UIImagePickerControllerSourceType.Camera)
        }))
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .Default, handler: { (UIAlertAction) in
            self.popupImageSelection(UIImagePickerControllerSourceType.PhotoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func popupImageSelection(type: UIImagePickerControllerSourceType) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = type
        myPickerController.allowsEditing = true
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
        
        DatabaseHelper.sharedInstance.beginTransaction()
        curentUser?.name = name.text ?? ""
        curentUser?.age = Int(age.text ?? "0") ?? 0
        curentUser?.weight = bodyWeight.text ?? ""
        curentUser?.height = bodyHeight.text ?? ""
        DatabaseHelper.sharedInstance.commitTransaction()
        let cusers = DatabaseHelper.sharedInstance.queryAll(Person())
        guard let numberOfUser = cusers?.count else {
            return
        }
        checkUser(numberOfUser)
        viewForAdaptForKeyboard.frame.origin.y = 0
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.placeholder != name.placeholder {
            return numberEnterOnly(replacementString: string)
        } else {
            return true
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        let imageWithFixedDirection = fixOrientation(image)
        DatabaseHelper.sharedInstance.beginTransaction()
        if let imageSourceData = UIImagePNGRepresentation(imageWithFixedDirection) {
            if curentUser!.profilePicture != nil {
                curentUser!.profilePicture = nil
            }
            curentUser!.profilePicture = imageSourceData
            profilePicture.setImage(UIImage(data: imageSourceData), forState: .Normal)
//            profilePicture.setBackgroundImage(UIImage(data: imageSourceData), forState: .Normal)
        }
        DatabaseHelper.sharedInstance.commitTransaction()
        
        let cusers = DatabaseHelper.sharedInstance.queryAll(Person())
        guard let numberOfUser = cusers?.count else {
            return
        }
        checkUser(numberOfUser)
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func fixOrientation(image:UIImage) -> UIImage {
        if (image.imageOrientation == UIImageOrientation.Up) {
            return image
        }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        image.drawInRect(rect)
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    private func resizeToAspectFit(viewSize: CGSize, bounds: CGRect, sourceImage: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(viewSize)
        sourceImage.drawInRect(bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func profilePictureStyleSheet() {
        profilePicture.layer.borderWidth = 1
        profilePicture.backgroundColor = GWMColorPurple
        profilePicture.layer.shadowColor = UIColor.blackColor().CGColor
        profilePicture.layer.shadowOffset = CGSize(width: 0, height: 0)
        profilePicture.layer.shadowRadius = 15
        profilePicture.layer.shadowOpacity = 0.8
    }
    
    // MARK: Navigation Controller
    private func navigationControllerStyleSheet() {
        self.navigationController?.navigationBar.topItem?.title = "Profile"
        // make the navigation bar edge disappear
        let navBarLineView = UIView(frame: CGRectMake(0,
            CGRectGetHeight((navigationController?.navigationBar.frame)!),
            CGRectGetWidth((self.navigationController?.navigationBar.frame)!),
            1))
        navBarLineView.backgroundColor = GWMColorYellow
        self.navigationController?.navigationBar.addSubview(navBarLineView)

        self.tabBarController?.tabBar.backgroundColor = GWMColorYellow
        self.tabBarController?.tabBar.tintColor = GWMColorPurple
        self.tabBarController?.tabBar.barTintColor = GWMColorYellow
        self.tabBarController?.tabBar.translucent = false
    }
    
    // MARK: textFieldStyleSheet
    private func setLayer(input:JVFloatLabeledTextField) -> CALayer {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = GWMColorYellow.CGColor
        border.frame = CGRect(x: 0, y: input.frame.size.height - width, width:  input.frame.size.width, height: input.frame.size.height)
        border.borderWidth = width
        return border
    }
    
    private func textFieldStyleSheet() {
        name.layer.addSublayer(setLayer(name))
        name.textColor = UIColor.whiteColor()
        name.layer.masksToBounds = true
        name.delegate = self
        
        bodyWeight.layer.addSublayer(setLayer(bodyWeight))
        bodyWeight.textColor = UIColor.whiteColor()
        bodyWeight.layer.masksToBounds = true
        bodyWeight.delegate = self
        
        bodyHeight.layer.addSublayer(setLayer(bodyHeight))
        bodyHeight.textColor = UIColor.whiteColor()
        bodyHeight.layer.masksToBounds = true
        bodyHeight.delegate = self
        
        age.layer.addSublayer(setLayer(age))
        age.textColor = UIColor.whiteColor()
        age.layer.masksToBounds = true
        age.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if name.isFirstResponder() {
            age.becomeFirstResponder()
        } else if age.isFirstResponder() {
            bodyHeight.becomeFirstResponder()
        } else if bodyHeight.isFirstResponder() {
            bodyWeight.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePictureStyleSheet()
        navigationControllerStyleSheet()
        textFieldStyleSheet()
        //backgroundScrollView.contentSize.height = 2500
        let backgroundImage = resizeToAspectFit(self.view.frame.size,bounds: self.view.bounds, sourceImage: UIImage(named: "profileBackground.jpg")!)
        self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        let image = resizeToAspectFit(headerView.frame.size,bounds: headerView.bounds, sourceImage: UIImage(named: "profileHeader.png")!)
        self.headerView.backgroundColor = UIColor(patternImage: image)
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        tapRecognizer?.delegate = self
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            self.view.transform = CGAffineTransformMakeScale(0.85, 0.85)
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
        
        keyboardIsShown = false
        
        profilePicture.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        profilePicture.imageView?.layer.cornerRadius = 0.5 * profilePicture.bounds.width
        
        let cusers = DatabaseHelper.sharedInstance.queryAll(Person())
        self.navigationController?.navigationBar.topItem?.title = "Profile"
        curentUser = cusers?.first
        if curentUser == nil {
            curentUser = Person()
        }
        
        if let user = curentUser {
            DatabaseHelper.sharedInstance.beginTransaction()
            if let userPicture = user.profilePicture{
                profilePicture.setImage(UIImage(data: userPicture), forState: .Normal)
            }
            name.text = user.name
            bodyHeight.text = user.height
            bodyWeight.text = user.weight
            if case user.age = 0 {
                return
            } else {
                age.text = "\(user.age)"

            }
            if user.sex == "male" {
                maleButton.backgroundColor = GWMColorPurple
                femaleButton.backgroundColor = GWMColorYellow
            } else if user.sex == "female" {
                femaleButton.backgroundColor = GWMColorPurple
                maleButton.backgroundColor = GWMColorYellow
            }
            DatabaseHelper.sharedInstance.commitTransaction()
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - ProfileViewController (Show/Hide Keyboard)

extension ProfileViewController:UIGestureRecognizerDelegate {
    
    
    func addKeyboardDismissRecognizer() {
        print("add keyboard dissmiss recognizer")
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let view = touch.view {
            if view is UIButton{
                return false
            }
        }
        return true
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("keyboard will show")
        print("height is " + String(getKeyboardHeight(notification)/2))
        print("view frame origin y is " + String(view.frame.origin.y))
        if(!keyboardIsShown){
            view.frame.origin.y -= getKeyboardHeight(notification) / 2
        }
        keyboardIsShown = true
    }

    
    func keyboardWillHide(notification: NSNotification) {
        print("keyboard will hide")
        view.frame.origin.y = 0.0
        keyboardIsShown = false
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}
