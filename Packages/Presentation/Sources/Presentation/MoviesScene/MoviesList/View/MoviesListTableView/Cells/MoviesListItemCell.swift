import UIKit
import Domain
import Common

@objc(MoviesListItemCell)
@objcMembers
final class MoviesListItemCell: UITableViewCell {

    static let reuseIdentifier = String(describing: MoviesListItemCell.self)
    static let height = CGFloat(130)

    @IBOutlet private var titleLabel: UILabel?
    @IBOutlet private var dateLabel: UILabel?
    @IBOutlet private var overviewLabel: UILabel?
    @IBOutlet private var posterImageView: UIImageView?

    private var viewModel: MoviesListItemViewModel?
    private var posterImagesRepository: PosterImagesRepository?
    private var imageLoadTask: Task<Void, Never>?

    func fill(
        with viewModel: MoviesListItemViewModel,
        posterImagesRepository: PosterImagesRepository?
    ) {
        self.viewModel = viewModel
        self.posterImagesRepository = posterImagesRepository

        titleLabel?.text = viewModel.title
        dateLabel?.text = viewModel.releaseDate
        overviewLabel?.text = viewModel.overview
        updatePosterImage(width: Int(posterImageView?.imageSizeAfterAspectFit.scaledSize.width ?? 0))
    }

    private func updatePosterImage(width: Int) {
        posterImageView?.image = nil
        guard let viewModel = viewModel, let posterImagePath = viewModel.posterImagePath else { return }

        imageLoadTask?.cancel()
        imageLoadTask = Task {
            do {
                let data = try await posterImagesRepository?.fetchImage(
                    with: posterImagePath,
                    width: width
                )
                await MainActor.run { [weak self] in
                    guard let currentPath = self?.viewModel?.posterImagePath, currentPath == posterImagePath else { return }
                    if let data = data {
                        self?.posterImageView?.image = UIImage(data: data)
                    }
                }
            } catch {
                // Silently fail on image loading
            }
        }
    }
}
