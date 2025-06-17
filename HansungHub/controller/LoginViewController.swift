import UIKit
import WebKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var studentIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var autoLoginButton: UIButton!
    @IBOutlet weak var autoLoginLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    var isAutoLoginChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginStatusLabel.text = "학번/비밀번호로 로그인이 가능합니다."
        updateCheckboxUI()
        // 비밀번호 가림
        passwordTextField.isSecureTextEntry = true

        addPadding(to: studentIdTextField)
        addPadding(to: passwordTextField)
        
        // 폰트 적용
        loginStatusLabel.font = UIFont(name: "MangoDdobak-L", size: 12)
        studentIdTextField.font = UIFont(name: "MangoDdobak-R", size: 14)
        passwordTextField.font = UIFont(name: "MangoDdobak-R", size: 14)
        autoLoginLabel.font = UIFont(name: "MangoDdobak-L", size: 12)
        loginButton.titleLabel?.font = UIFont(name: "MangoDdobak-B", size: 16)
        
        // 로그인 버튼 스타일
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
        loginButton.layer.borderWidth = 0
        
        // 자동로그인
        autoLoginButton.layer.cornerRadius = 2
        autoLoginButton.layer.borderWidth = 1
        autoLoginButton.layer.borderColor = UIColor(hex: "#D0D0D0").cgColor
        autoLoginButton.backgroundColor = .white
        autoLoginButton.clipsToBounds = true
        
        // 자동로그인 label에 탭 제스처 등록
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(autoLoginTapped))
        autoLoginLabel.isUserInteractionEnabled = true
        autoLoginLabel.addGestureRecognizer(tapGesture)
    }
    
    // 체크박스 버튼 클릭
    @IBAction func autoLoginTapped(_ sender: Any? = nil) {
        isAutoLoginChecked.toggle()
        updateCheckboxUI()
    }
    
    private func updateCheckboxUI() {
        let imageName = isAutoLoginChecked ? "square.fill" : "square"
        autoLoginButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        let studentId = studentIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !studentId.isEmpty, !password.isEmpty else {
            loginStatusLabel.text = "아이디와 비밀번호를 입력해 주세요."
            return
        }
        
        // 관리자 계정
        if studentId == "admin" && password == "admin1234" {
            saveLoginState(studentId: studentId)
            moveToMain()
            return
        }
        
        // 일반 사용자용 로그인
        loginToHansung(studentId: studentId, password: password) { success in
            DispatchQueue.main.async {
                if success {
                    self.saveLoginState(studentId: studentId)
                    self.moveToMain()
                } else {
                    self.loginStatusLabel.text = "아이디 또는 비밀번호가 잘못되었습니다."
                }
            }
        }
    }
    
    func saveLoginState(studentId: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(studentId, forKey: "studentId")
        userDefaults.set(true, forKey: "isLogIn")
        userDefaults.set(isAutoLoginChecked, forKey: "autoLogin")
    }
    
    func moveToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            tabBarVC.modalPresentationStyle = .fullScreen
            present(tabBarVC, animated: true, completion: nil)
        }
    }
    
    
    func loginToHansung(studentId: String, password: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://learn.hansung.ac.kr/login/index.php")!
        
        // 초기 요청
        let initialRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: initialRequest) { data, response, error in
            guard error == nil else {
                print("초기 요청 실패: \(error!)")
                completion(false)
                return
            }
            
            // 로그인 요청
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let bodyString = "username=\(studentId)&password=\(password)"
            request.httpBody = bodyString.data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            // 쿠키 저장
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("로그인 요청 실패: \(error!)")
                    completion(false)
                    return
                }
                
                if let html = String(data: data, encoding: .utf8),
                   !html.contains("잘못 입력") {
                    // 로그인 성공
                    print("로그인 성공")
                    completion(true)
                } else {
                    // 로그인 실패
                    print("로그인 실패")
                    completion(false)
                }
            }.resume()
        }.resume()
    }
}

// 텍스트필드에 패딩 값
func addPadding(to textField: UITextField) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
    textField.leftView = paddingView
    textField.leftViewMode = .always
}


extension UIColor {
    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }

        var rgb: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
