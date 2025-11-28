import Foundation
import SwiftUI

@available(iOS 13.0, *)
extension MoviesQueryListItemViewModel: Identifiable { }

@available(iOS 13.0, *)
public struct MoviesQueryListView: View {
    @ObservedObject var viewModelWrapper: MoviesQueryListViewModelWrapper
    
    public var body: some View {
        List(viewModelWrapper.items) { item in
            Button(action: {
                self.viewModelWrapper.viewModel?.didSelect(item: item)
            }) {
                Text(item.query)
            }
        }
        .onAppear {
            self.viewModelWrapper.viewModel?.viewWillAppear()
        }
    }
}

@available(iOS 13.0, *)
public final class MoviesQueryListViewModelWrapper: ObservableObject {
    public var viewModel: MoviesQueryListViewModel?
    @Published public var items: [MoviesQueryListItemViewModel] = []
    
    public init(viewModel: MoviesQueryListViewModel?) {
        self.viewModel = viewModel
        viewModel?.items.observe(on: self) { [weak self] values in self?.items = values }
    }
}

#if DEBUG
@available(iOS 13.0, *)
struct MoviesQueryListView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesQueryListView(viewModelWrapper: previewViewModelWrapper)
    }
    
    static var previewViewModelWrapper: MoviesQueryListViewModelWrapper = {
        var viewModel = MoviesQueryListViewModelWrapper(viewModel: nil)
        viewModel.items = [MoviesQueryListItemViewModel(query: "item 1"),
                           MoviesQueryListItemViewModel(query: "item 2")
        ]
        return viewModel
    }()
}
#endif
