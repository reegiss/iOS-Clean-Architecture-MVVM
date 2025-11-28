import UIKit

final class MovieDetailsViewController: UIViewController, StoryboardInstantiable {

    @IBOutlet private var posterImageView: UIImageView?
    @IBOutlet private var overviewTextView: UITextView?

    // MARK: - Lifecycle

    private var viewModel: MovieDetailsViewModel?

    private var vm: MovieDetailsViewModel {
        guard let vm = viewModel else { fatalError("MovieDetailsViewController.viewModel must be set before use") }
        return vm
    }
    
    static func create(with viewModel: MovieDetailsViewModel) -> MovieDetailsViewController {
        let view = MovieDetailsViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: vm)
    }

    private func bind(to viewModel: MovieDetailsViewModel) {
        viewModel.posterImage.observe(on: self) { [weak self] in self?.posterImageView?.image = $0.flatMap(UIImage.init) }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = Int(posterImageView?.imageSizeAfterAspectFit.scaledSize.width ?? 0)
        vm.updatePosterImage(width: width)
    }

    // MARK: - Private

    private func setupViews() {
        title = vm.title
        overviewTextView?.text = vm.overview
        posterImageView?.isHidden = vm.isPosterImageHidden
        view.accessibilityIdentifier = AccessibilityIdentifier.movieDetailsView
    }
}
