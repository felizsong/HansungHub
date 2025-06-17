import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var card1View: UIView!
    @IBOutlet weak var card2View: UIView!
    @IBOutlet weak var card3View: UIView!
    @IBOutlet weak var card4View: UIView!
    @IBOutlet weak var card5View: UIView!
    @IBOutlet weak var card6View: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cardViews = [card1View, card2View, card3View, card4View, card5View, card6View]

        for (index, cardView) in cardViews.enumerated() {
            guard let cardView = cardView else { continue }

            // 스타일 설정
            cardView.layer.borderColor = UIColor(hex: "#D0D0D0").cgColor
            cardView.layer.borderWidth = 1
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.1
            cardView.layer.shadowRadius = 4
            cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
            cardView.clipsToBounds = false

            // 탭 제스처 추가
            cardView.tag = index
            cardView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
            cardView.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func handleCardTap(_ sender: UITapGestureRecognizer) {
        if let view = sender.view {
            cardTapped(index: view.tag)
        }
    }

    func cardTapped(index: Int) {
        let facilityTitles = ["상상베이스", "상상파크 플러스", "학술정보관", "집중 열람실", "체육시설", "기자재 대여"]
        let facilityImages = ["card1_image", "card2_image", "card3_image", "card4_image", "card5_image", "card6_image"]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "FacilityDetailViewController") as? FacilityDetailViewController {
            detailVC.facilityTitle = facilityTitles[index]
            detailVC.facilityImage = UIImage(named: facilityImages[index])
            
            // 탭바 숨김
            detailVC.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }

}

