import UIKit
import RxSwift

extension UIView {
    public static func insertHeader(_ view: UIView, text: String) -> UIStackView {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [
            label,
            view
        ])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setCustomSpacing(10, after: label)
        
        return stackView
    }

}
