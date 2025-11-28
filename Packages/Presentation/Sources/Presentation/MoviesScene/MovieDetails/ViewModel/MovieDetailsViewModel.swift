import Foundation
import Domain
import Common

public protocol MovieDetailsViewModelInput {
    func updatePosterImage(width: Int)
}

public protocol MovieDetailsViewModelOutput {
    var title: String { get }
    var posterImage: Observable<Data?> { get }
    var isPosterImageHidden: Bool { get }
    var overview: String { get }
}

public protocol MovieDetailsViewModel: MovieDetailsViewModelInput, MovieDetailsViewModelOutput { }

final class DefaultMovieDetailsViewModel: MovieDetailsViewModel {
    
    private let posterImagePath: String?
    private let posterImagesRepository: PosterImagesRepository
    private var imageLoadTask: Task<Void, Never>?

    // MARK: - OUTPUT
    let title: String
    let posterImage: Observable<Data?> = Observable(nil)
    let isPosterImageHidden: Bool
    let overview: String
    
    init(
        movie: Movie,
        posterImagesRepository: PosterImagesRepository
    ) {
        self.title = movie.title ?? ""
        self.overview = movie.overview ?? ""
        self.posterImagePath = movie.posterPath
        self.isPosterImageHidden = movie.posterPath == nil
        self.posterImagesRepository = posterImagesRepository
    }
}

// MARK: - INPUT. View event methods
extension DefaultMovieDetailsViewModel {
    
    func updatePosterImage(width: Int) {
        guard let posterImagePath = posterImagePath else { return }

        imageLoadTask?.cancel()
        imageLoadTask = Task {
            do {
                let data = try await posterImagesRepository.fetchImage(
                    with: posterImagePath,
                    width: width
                )
                await MainActor.run { [weak self] in
                    guard self?.posterImagePath == posterImagePath else { return }
                    self?.posterImage.value = data
                }
            } catch {
                // Silently fail on image loading
            }
        }
    }
}
