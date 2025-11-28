import Foundation
import Domain

public enum MovieDetailsViewModelFactory {
    public static func make(
        movie: Movie,
        posterImagesRepository: PosterImagesRepository
    ) -> MovieDetailsViewModel {
        return DefaultMovieDetailsViewModel(
            movie: movie,
            posterImagesRepository: posterImagesRepository
        )
    }
}
