import UIKit

class RoomCell: UICollectionViewCell {
    @IBOutlet weak var roomButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        roomButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roomButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            roomButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            roomButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            roomButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        roomButton.layer.cornerRadius = 15
        roomButton.layer.borderWidth = 1
        roomButton.layer.borderColor = UIColor(hex: "#D0D0D0").cgColor
        roomButton.clipsToBounds = true
        roomButton.isUserInteractionEnabled = false
        roomButton.contentEdgeInsets = .zero

        // 폰트 지정
        roomButton.titleLabel?.font = UIFont(name: "MangoDdobak-R", size: 12)

        // 줄바꿈 방지 및 크기 자동 조절
        roomButton.titleLabel?.numberOfLines = 1
        roomButton.titleLabel?.lineBreakMode = .byTruncatingTail
        roomButton.titleLabel?.adjustsFontSizeToFitWidth = true
        roomButton.titleLabel?.minimumScaleFactor = 0.8
    }

    func configure(title: String, selected: Bool) {
        roomButton.setTitle(title, for: .normal)

        if selected {
            roomButton.backgroundColor = UIColor(hex: "#50453B")
            roomButton.setTitleColor(UIColor(hex: "#FBFAF9"), for: .normal)
            roomButton.layer.borderColor = UIColor.clear.cgColor
        } else {
            roomButton.backgroundColor = .white
            roomButton.setTitleColor(.black, for: .normal)
            roomButton.layer.borderColor = UIColor(hex: "#D0D0D0").cgColor
        }
    }
}
