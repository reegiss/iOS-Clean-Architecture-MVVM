import UIKit

@objc(MoviesQueriesTableViewController)
@objcMembers
public final class MoviesQueriesTableViewController: UITableViewController, StoryboardInstantiable {
    
    private var viewModel: MoviesQueryListViewModel?

    private var vm: MoviesQueryListViewModel {
        guard let vm = viewModel else { fatalError("MoviesQueriesTableViewController.viewModel must be set before use") }
        return vm
    }

    // MARK: - Lifecycle

    public static func create(with viewModel: MoviesQueryListViewModel) -> MoviesQueriesTableViewController {
        let view = MoviesQueriesTableViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: vm)
    }
    
    private func bind(to viewModel: MoviesQueryListViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in self?.tableView.reloadData() }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        vm.viewWillAppear()
    }

    // MARK: - Private

    private func setupViews() {
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = MoviesQueriesItemCell.height
        tableView.rowHeight = UITableView.automaticDimension
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MoviesQueriesTableViewController {
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.items.value.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoviesQueriesItemCell.reuseIdentifier, for: indexPath) as? MoviesQueriesItemCell else {
            assertionFailure("Cannot dequeue reusable cell \(MoviesQueriesItemCell.self) with reuseIdentifier: \(MoviesQueriesItemCell.reuseIdentifier)")
            return UITableViewCell()
        }
        cell.fill(with: vm.items.value[indexPath.row])

        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        vm.didSelect(item: vm.items.value[indexPath.row])
    }
}
