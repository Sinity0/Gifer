import UIKit

class FeedView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        if let patternImage = UIImage(named: Constants.viewPatternName) {
            self.backgroundColor = UIColor(patternImage: patternImage)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        return searchBar
    }
}

