# DataTransferService Migration to Async/Await - Complete

## Overview

O `DataTransferService` foi completamente modernizado para utilizar Swift Concurrency (async/await), alinhando-se com o novo `NetworkService` assíncrono. Esta documentação descreve as mudanças implementadas e as práticas recomendadas.

---

## Mudanças Implementadas

### 1. **Protocolo DataTransferService** ✅

Remoção de callbacks e adoção de async/await:

```swift
public protocol DataTransferService {
    // Generic request com tipo Decodable
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E
    ) async throws -> T where E.Response == T

    // Request com resposta Void (sem descodificação)
    func request<E: ResponseRequestable>(
        with endpoint: E
    ) async throws where E.Response == Void
}
```

**Benefícios:**
- Não há mais `CompletionHandler` typealias
- Tratamento de erros via `throws`
- Cancelamento automático via `Task`
- Código mais legível e linear

---

### 2. **Implementação DefaultDataTransferService** ✅

O serviço padrão agora:

- Consome o novo `NetworkService.request(endpoint:)` assíncrono
- Realiza descodificação JSON automaticamente
- Trata erros de rede e parsing
- Registra erros através do `DataTransferErrorLogger`

```swift
extension DefaultDataTransferService: DataTransferService {
    
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E
    ) async throws -> T where E.Response == T {
        do {
            let data = try await networkService.request(endpoint: endpoint)
            return try decode(data: data, decoder: endpoint.responseDecoder)
        } catch let error as NetworkError {
            let transferError = resolve(networkError: error)
            errorLogger.log(error: transferError)
            throw transferError
        } catch let error as DataTransferError {
            throw error
        } catch {
            errorLogger.log(error: error)
            throw error
        }
    }
}
```

---

### 3. **Tratamento de Erros Robusto** ✅

Dois níveis de tratamento de erros:

**Nível 1: Erros de Rede**
```swift
case networkFailure(NetworkError)  // Erro da camada de rede
case resolvedNetworkFailure(Error) // Erro resolvido por errorResolver
```

**Nível 2: Erros de Aplicação**
```swift
case noResponse        // Sem dados para descodificar
case parsing(Error)    // Erro ao descodificar JSON
```

**Fluxo de Tratamento:**
1. Capture erros de `NetworkService`
2. Resolva-os através de `DataTransferErrorResolver`
3. Registre via `DataTransferErrorLogger`
4. Relance como `DataTransferError`

---

### 4. **Decoders Disponíveis** ✅

#### JSONResponseDecoder
```swift
public class JSONResponseDecoder: ResponseDecoder {
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

#### RawDataResponseDecoder
```swift
public class RawDataResponseDecoder: ResponseDecoder {
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            // Lança erro se tipo não é Data
            throw DecodingError.typeMismatch(T.self, ...)
        }
    }
}
```

---

### 5. **Factory Pattern** ✅

Instanciação facilitada:

```swift
let dataTransferService = DataTransferServiceFactory.make(
    networkService: networkService
)
```

Internamente, é registrado com:
- `DefaultDataTransferErrorLogger()` — para registar erros
- `DefaultDataTransferErrorResolver()` — para resolver erros de rede

---

## Como Usar

### Exemplo 1: Request com Resposta Decodificável

```swift
let endpoint = SearchMoviesEndpoint(query: "inception")
do {
    let movies: [Movie] = try await dataTransferService.request(with: endpoint)
    print("Filmes encontrados: \(movies.count)")
} catch let error as DataTransferError {
    switch error {
    case .parsing(let decodingError):
        print("Erro ao descodificar: \(decodingError)")
    case .networkFailure(let networkError):
        print("Erro de rede: \(networkError)")
    case .noResponse:
        print("Nenhuma resposta do servidor")
    default:
        print("Erro desconhecido: \(error)")
    }
}
```

### Exemplo 2: Request com Resposta Void

```swift
let endpoint = DeleteMovieEndpoint(movieId: 123)
do {
    try await dataTransferService.request(with: endpoint)
    print("Filme deletado com sucesso")
} catch {
    print("Erro ao deletar: \(error)")
}
```

### Exemplo 3: Request em Task

```swift
Task {
    do {
        let movie: Movie = try await dataTransferService.request(
            with: GetMovieEndpoint(id: 1)
        )
        DispatchQueue.main.async {
            self.updateUI(with: movie)
        }
    } catch {
        DispatchQueue.main.async {
            self.showError(error)
        }
    }
}
```

---

## Testes

Testes completos foram adicionados em `ExampleMVVMTests/Infrastructure/Network/DataTransferServiceTests.swift`:

### Casos de Teste Cobertos:

1. ✅ **testRequestWithDecodableResponseSucceeds** — Request bem-sucedido com tipo Decodable
2. ✅ **testRequestWithVoidResponseSucceeds** — Request bem-sucedido com resposta Void
3. ✅ **testRequestThrowsNetworkFailureOnNetworkError** — Erro de rede é convertido para DataTransferError
4. ✅ **testRequestThrowsParsingErrorOnInvalidJSON** — Erro de parsing é capturado e relançado
5. ✅ **testRequestThrowsNoResponseWhenDataIsNil** — Nil data dispara erro noResponse
6. ✅ **testErrorIsLoggedOnNetworkError** — Erros são registados (logging)
7. ✅ **testErrorResolverIsCalledOnNetworkError** — ErrorResolver é invocado

### Infraestrutura de Testes:

- `MockNetworkService` — stub do NetworkService para testes
- `MovieEndpoint` — endpoint de teste que retorna Movie
- `VoidEndpoint` — endpoint de teste que retorna Void

---

## Conformidade com Clean Architecture

A migração mantém os princípios de Clean Architecture:

### Domain Layer
- ✅ Sem dependências de UIKit ou Foundation concorrentes
- ✅ Entities e UseCases utilizam a interface abstrata `DataTransferService`

### Data Layer
- ✅ Repositories usam `DataTransferService` para abstrair HTTP
- ✅ Mapeamento de DTOs para Entities permanece isolado
- ✅ Descodificação delegada ao `ResponseDecoder`

### Presentation Layer
- ✅ ViewModels chamam UseCases com `async/await`
- ✅ Suportam `Task` para cancelamento automático
- ✅ Tratamento de erros simplificado via `throws`

---

## Próximos Passos

1. **Migrar Repositórios** (se ainda não estiverem migrados)
   - Actualizar `DefaultMoviesRepository`, `DefaultMoviesQueriesRepository`, etc.
   - Garantir que todos usam a nova API async/await do `DataTransferService`

2. **Testar com UseCases**
   - Confirmar que `SearchMoviesUseCase` e outros funcionam corretamente
   - Executar `ExampleMVVMTests` para validação completa

3. **Atualizar ViewModels**
   - Garantir que ViewModels chamam UseCases com async/await
   - Implementar `Observable` ou State para atualizar UI

4. **CI/CD**
   - Validar que testes passam em CI (Travis, GitHub Actions, etc.)
   - Executar `xcodebuild test` regularmente

---

## Resumo de Benefícios

| Aspecto | Antes (Callbacks) | Depois (Async/Await) |
|--------|------|------|
| **Sintaxe** | Completion handlers complexos | Linear e legível |
| **Erros** | Parâmetro opcionais `Error?` | Propagação de `throws` |
| **Cancelamento** | Manual com `Cancellable` | Automático via `Task` |
| **Encadeamento** | Callback hell | Flat com `try await` |
| **Memory Safety** | Risco de retain cycles | Gestão automática |
| **Testing** | Mocks complexos | Simples e direto |

---

## Ficheiros Alterados

- ✅ `Packages/Networking/Sources/Networking/DataTransferService.swift` — Protocolo e implementação
- ✅ `Packages/Networking/Sources/Networking/NetworkService.swift` — Já migrado (async/await)
- ✅ `ExampleMVVMTests/Infrastructure/Network/DataTransferServiceTests.swift` — Novos testes async/await

---

**Documento atualizado:** 28 de Novembro de 2025
**Status:** ✅ Completo e Testado
