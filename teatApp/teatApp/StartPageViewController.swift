//
//  StartPageViewController.swift
//  teatApp
//
//  Created by streifik on 06.12.2022.
//

import UIKit

class StartPageViewController: UIViewController {

    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let editProfileViewController = storyBoard.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController {
               self.show(editProfileViewController, sender: self)
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let editProfileViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
               
               self.show(editProfileViewController, sender: self)
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
          super.viewWillTransition(to: size, with: coordinator)
          if UIDevice.current.orientation.isLandscape {
              logoHeightConstraint.constant = 50
             
          } else {
              logoHeightConstraint.constant = 170
          }
      }

}
