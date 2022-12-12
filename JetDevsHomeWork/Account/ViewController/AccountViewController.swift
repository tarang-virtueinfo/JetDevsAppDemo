//
//  AccountViewController.swift
//  JetDevsHomeWork
//
//  Created by Gary.yao on 2021/10/29.
//

import UIKit
import Kingfisher

class AccountViewController: UIViewController {

	@IBOutlet weak var nonLoginView: UIView!
	@IBOutlet weak var loginView: UIView!
	@IBOutlet weak var daysLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var headImageView: UIImageView!
	override func viewDidLoad() {
        super.viewDidLoad()

		self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
		nonLoginView.isHidden = false
		loginView.isHidden = true
        
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "X-AccessToken") != nil {
            if let accessToken = defaults.object(forKey: "X-AccessToken") as? String {
                print(accessToken)
                if let userInfo = defaults.object(forKey: "UserInfo") as? Data {
                    let decoder = JSONDecoder()
                    if let loadedPerson = try? decoder.decode(User.self, from: userInfo) {
                        print(loadedPerson.userID)
                        
                        nonLoginView.isHidden = true
                        loginView.isHidden = false
                        
                        nameLabel.text = loadedPerson.userName
                        daysLabel.text = "Created \(loadedPerson.createDayAgo) days ago"
                        
                    }
                }
            }
        }
    }
	
    @IBAction func loginButtonTap(_ sender: UIButton) {
        let loginViewModel = LoginViewModel(useCase: DefaultLoginUseCase.init())
        let loginViewController = LoginViewController.init(with: loginViewModel, delegate: self)
        let navigation = UINavigationController(rootViewController: loginViewController)
        navigation.modalPresentationStyle = .fullScreen
        present(navigation, animated: true)
    }
    
}

extension AccountViewController: LoginViewControllerDelegate {
    
    func didLoginSuccess(_ viewController: LoginViewController, response: LoginResponse) {
        viewController.navigationController?.dismiss(animated: true)
        guard let user = response.data.user else {
            return
        }
        print(response)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "UserInfo")
            defaults.synchronize()
        }
        
        nonLoginView.isHidden = true
        loginView.isHidden = false
        
        nameLabel.text = user.userName
        daysLabel.text = "Created \(user.createDayAgo) days ago"
    }
}
