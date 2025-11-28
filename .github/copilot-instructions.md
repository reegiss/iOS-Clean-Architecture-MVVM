````instructions
Project: iOS-Clean-Architecture-MVVM — AI coding assistant guidance

Keep guidance concise and focused on codebase-specific patterns, not generic best practices.

- Big picture:
  - This is a layered Clean Architecture + MVVM iOS template. Key layers:
    - `Domain/` — Entities, Use Cases, and Repository interfaces (no framework/UI imports).
    - `Data/` — Repository implementations, networking DTOs, and persistence (Core Data storage under `Data/PersistentStorages`).
    - `Presentation/` (ExampleMVVM/Presentation) — ViewModels, Views, and Flow Coordinators. Views are mostly Storyboards; a SwiftUI example exists.
    - `Infrastructure/` — low-level network and transfer services used by Data layer.

  **Architecture details & data flow**

  - High-level request flow (UI → network → UI):
    1. View / ViewController receives user action and calls a `ViewModel` in `ExampleMVVM/Presentation/*/ViewModel`.
    2. `ViewModel` invokes a Use Case from `Domain/UseCases` (e.g. `SearchMoviesUseCase`) which encapsulates application rules.
    3. Use Case depends on repository interfaces from `Domain/Interfaces/Repositories` and delegates data operations to a concrete implementation in `Data/Repositories` (e.g. `DefaultMoviesRepository.swift`).
    4. Repository coordinates between `Infrastructure/Network` (`NetworkService` / `DataTransferService`) and local persistence (`Data/PersistentStorages/*`) and performs DTO mapping located in `ExampleMVVM/Data/Network/DataMapping`.
    5. Repository returns domain entities to the Use Case; Use Case maps/validates results and returns them to the `ViewModel`.
    6. `ViewModel` publishes state via `Observable` (`ExampleMVVM/Presentation/Utils/Observable.swift`) to update the View.

  - Important runtime notes:
    - DI: concrete repositories and services are registered in `ExampleMVVM/Application/DIContainer/AppDIContainer.swift` and per-scene DI in `MoviesSceneDIContainer.swift`.
    - Flow coordinators (e.g. `MoviesSearchFlowCoordinator.swift`) own navigation and construction of scene DI containers and view controllers.
    - Networking: `Infrastructure/Network/NetworkService.swift` handles low-level requests and error normalization. `DataTransferService.swift` adapts responses for repositories.
    - DTO mapping: mapping extensions (e.g. `MoviesResponseDTO+Mapping.swift`) convert DTOs → Domain Entities. Keep mapping logic inside Data layer.
    - Threading: asynchronous work uses `DispatchQueueType` abstraction (`Common/DispatchQueueType.swift`) so tests can inject `DispatchQueueTypeMock` from `Infrastructure/Mocks`.
    - Cancellation: long-running tasks return `Cancellable` (`Common/Cancellable.swift`) so `ViewModel`s can cancel subscriptions.

  - Caching & persistence patterns:
    - Query history is persisted in `ExampleMVVM/Data/PersistentStorages/MoviesQueriesStorage`.
    - Movie response caching is illustrated in `DefaultMoviesRepository.swift` and `MoviesResponseStorage`.

  - Error handling:
    - Network and domain errors are surfaced via standard `Result`/error callbacks and normalized using `Common/ConnectionError.swift`.
    - `ViewModel`s map errors into UI-friendly messages; look at `MoviesListViewModel.swift` for examples.

  - Tests & mocks:
    - Unit tests target Use Cases and ViewModels under `ExampleMVVMTests/` — mock repositories or `DispatchQueueType` where needed.
    - Use `Infrastructure/Mocks/DispatchQueueTypeMock.swift` in tests to control async scheduling.


- Important files & places to modify when adding features:
  - Add business rules in `Domain/Entities` and `Domain/UseCases` and expose repository protocols in `Domain/Interfaces/Repositories`.
  - Implement repository behavior in `Data/Repositories/*` and DTO mapping in `ExampleMVVM/Data/Network/DataMapping`.
  - Register concrete implementations in `ExampleMVVM/Application/DIContainer/AppDIContainer.swift` and scene DI in `MoviesSceneDIContainer.swift`.
  - Presentation: create/modify ViewModels in `ExampleMVVM/Presentation/*/ViewModel`, wire views in Storyboards under `ExampleMVVM/Presentation/*/View` and coordinate flows via `Flows/*FlowCoordinator.swift`.

- Project-specific conventions & patterns to follow:
  - Keep `Domain` layer free of UIKit/Foundation specific implementations. Interfaces live in `Domain/Interfaces/Repositories` and are implemented in `Data`.
  - Use `Observable` (`ExampleMVVM/Presentation/Utils/Observable.swift`) for simple data binding in ViewModels (no external Rx libs).
  - Use `Cancellable` protocol (root `Common/Cancellable.swift`) to cancel async work where needed.
  - DTO mapping pattern: mapping extension files named like `MoviesResponseDTO+Mapping.swift` in `Data/Network/DataMapping`.
  - Caching & persistence examples: `ExampleMVVM/Data/PersistentStorages/CoreDataStorage` and repository caching in `DefaultMoviesRepository.swift`.

- Build, test, and CI workflows (specific commands):
  - CI in repo uses Travis + Fastlane. Local test and CI example:
    - Install project fastlane gems (use `bundle`):
      ```bash
      cd /Users/regis/develop/template/iOS-Clean-Architecture-MVVM
      bundle install
      ```
    - Run unit/UI tests via fastlane (Travis uses this):
      ```bash
      bundle exec fastlane scan --scheme ExampleMVVM
      ```
    - Alternative: run tests with xcodebuild locally:
      ```bash
      xcodebuild test -workspace ExampleMVVM.xcworkspace -scheme ExampleMVVM -destination 'platform=iOS Simulator'
      ```

- Testing & where to add tests:
  - Unit tests live under `ExampleMVVMTests/` grouped by layer (Domain, Infrastructure, Presentation). Follow existing tests for Use Cases and ViewModels.
  - UI tests are under `ExampleMVVMUITests/Presentation/MoviesScene/`.

- Quick navigation examples (useful file pointers):
  - App entry & DI: `ExampleMVVM/Application/AppDelegate.swift` and `ExampleMVVM/Application/DIContainer/AppDIContainer.swift`.
  - Movies feature: ViewModel `ExampleMVVM/Presentation/MoviesScene/MoviesList/ViewModel/MoviesListViewModel.swift`, repository `ExampleMVVM/Data/Repositories/DefaultMoviesRepository.swift`, queries storage at `ExampleMVVM/Data/PersistentStorages/MoviesQueriesStorage`.
  - Network service: `Infrastructure/Network/NetworkService.swift` and `Infrastructure/Network/DataTransferService.swift`.

- When editing code, follow this change flow for feature work:
  1. Add/extend `Domain` entity + use case + repository interface.
  2. Implement repository behavior and DTO mapping in `Data`/`Infrastructure`.
  3. Register concrete instances in the DI container(s).
  4. Add ViewModel and connect UI (Storyboard/SwiftUI) and update/implement a Flow Coordinator if navigation is required.
  5. Add unit tests mirroring other tests in `ExampleMVVMTests`.

- Notes for the AI assistant:
  - Avoid changing architectural boundaries; prefer adding new files following the existing layered layout.
  - Preserve Storyboard IDs and outlets when modifying UI ViewControllers — many controllers are connected to DI and ViewModels.
  - Use existing examples (Movies feature) as templates for naming, DI registration, and DTO mapping style.
  - If updating dependency versions or CI flows (Gemfile, .travis.yml, Fastfile), list exact commands to run locally for verification.

- Note: The project does not include an `.xcworkspace` file. Ensure to generate one if needed for Xcode workflows.

If anything above is unclear or you want more examples (e.g., a small patch showing adding a Use Case + repo + ViewModel), tell me which area to expand.
````
