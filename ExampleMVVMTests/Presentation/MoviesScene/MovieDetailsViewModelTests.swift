import XCTest
@testable import ExampleMVVM

class MovieDetailsViewModelTests: XCTestCase {
    
    private enum PosterImageDownloadError: Error {
        case someError
    }
    
    func test_updatePosterImageWithWidthEventReceived_thenImageWithThisWidthIsDownloaded() async {
        // given
        let posterImagesRepository = PosterImagesRepositoryMock()

        guard let expectedImage = "image data".data(using: .utf8) else {
            XCTFail("Failed to create expected image fixture")
            return
        }
        posterImagesRepository.image = expectedImage

        let viewModel = DefaultMovieDetailsViewModel(
            movie: Movie.stub(posterPath: "posterPath"),
            posterImagesRepository: posterImagesRepository
        )
        
        posterImagesRepository.validateInput = { (imagePath: String, width: Int) in
            XCTAssertEqual(imagePath, "posterPath")
            XCTAssertEqual(width, 200)
        }
        
        // when
        viewModel.updatePosterImage(width: 200)
        
        // Give async task time to complete
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // then
        XCTAssertEqual(viewModel.posterImage.value, expectedImage)
        XCTAssertEqual(posterImagesRepository.completionCalls, 1)
    }
}
