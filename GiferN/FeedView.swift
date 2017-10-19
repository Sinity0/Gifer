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

    func setupUISearchController() -> UISearchController {
        let viewController = UISearchController(searchResultsController: nil)
        viewController.hidesNavigationBarDuringPresentation = false
        viewController.dimsBackgroundDuringPresentation = false
        viewController.obscuresBackgroundDuringPresentation = false
        return viewController
    }
}

