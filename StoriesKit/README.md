# 📱 StoriesKit

![StoriesKit Demo](./assets/demo_large.gif)

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**StoriesKit** — это современная Swift библиотека для создания красивых историй в стиле Instagram Stories с поддержкой как UIKit, так и SwiftUI. Библиотека предоставляет готовые компоненты для отображения историй с поддержкой навигации, таймеров и интерактивных элементов.

## ✨ Особенности

- 🎨 **Красивый дизайн** — современный UI в стиле популярных социальных сетей
- ⚡ **Высокая производительность** — оптимизированная архитектура с использованием SwiftUI и Combine
- 🖼️ **Поддержка изображений** — загрузка изображений по URL с кэшированием (Kingfisher)
- ⏱️ **Автоматические таймеры** — настраиваемая длительность историй
- 🎯 **Интерактивность** — поддержка кнопок, ссылок и жестов
- 📱 **Адаптивность** — поддержка различных размеров экранов
- 🔄 **Навигация** — плавные переходы между историями и группами
- 🎛️ **Гибкая настройка** — богатые возможности кастомизации
- 🏗️ **Двойная поддержка** — работает как в UIKit, так и в SwiftUI

## 🚀 Быстрый старт

### Установка

Добавьте StoriesKit в ваш проект через Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/StoriesKit.git", from: "1.0.0")
]
```

### Базовое использование

#### UIKit

```swift
import StoriesKit

// Создание историй для UIKit
let storiesViewController = Stories.build(
    groups: [
        StoriesGroupModel(
            id: "user1",
            title: "Пользователь 1",
            avatarImage: .url(URL(string: "https://example.com/avatar.jpg")!),
            stories: [
                StoriesPageModel(
                    title: AttributedString("Заголовок истории"),
                    subtitle: AttributedString("Подзаголовок"),
                    backgroundColor: .systemBlue,
                    backgroundImage: StoriesImageModel(
                        image: .url(URL(string: "https://example.com/story.jpg")!)
                    ),
                    duration: 5.0
                )
            ]
        )
    ],
    delegate: self
)

// Презентация
present(storiesViewController, animated: true)
```

#### SwiftUI

```swift
import StoriesKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        // Создание чистой SwiftUI View
        Stories.buildSwiftUI(
            groups: [
                StoriesGroupModel(
                    id: "user1",
                    title: "Пользователь 1",
                    avatarImage: .url(URL(string: "https://example.com/avatar.jpg")!),
                    stories: [
                        StoriesPageModel(
                            title: AttributedString("Заголовок истории"),
                            subtitle: AttributedString("Подзаголовок"),
                            backgroundColor: .systemBlue,
                            backgroundImage: StoriesImageModel(
                                image: .url(URL(string: "https://example.com/story.jpg")!)
                            ),
                            duration: 5.0
                        )
                    ]
                )
            ],
            delegate: self
        )
    }
}
```

## 📖 Подробная документация

### Модели данных

#### StoriesGroupModel
Представляет группу историй (например, истории одного пользователя):

```swift
StoriesGroupModel(
    id: "unique_id",
    title: "Название группы",
    avatarImage: .url(URL(string: "avatar_url")!),
    stories: [/* массив историй */],
    isViewed: false
)
```

#### StoriesPageModel
Отдельная страница истории:

```swift
StoriesPageModel(
    title: AttributedString("Заголовок"),
    subtitle: AttributedString("Подзаголовок"),
    backgroundColor: .systemBlue,
    button: StoriesPageModel.Button(
        title: AttributedString("Кнопка"),
        backgroundColor: .white,
        corners: .radius(8),
        actionType: .link(URL(string: "https://example.com")!)
    ),
    backgroundImage: StoriesImageModel(
        image: .url(URL(string: "image_url")!)
    ),
    duration: 4.0
)
```

#### StoriesImageModel
Модель для изображений с поддержкой различных источников:

```swift
StoriesImageModel(
    image: .url(URL(string: "image_url")!), // или .image(UIImage)
    placeholder: UIImage(named: "placeholder"),
    fadeInDuration: 0.25,
    isViewed: false
)
```

### Делегат

Реализуйте протокол `IStoriesDelegate` для обработки событий:

```swift
extension YourViewController: IStoriesDelegate {
    func didClose() {
        // История закрыта
    }
    
    func didOpenLink(url: URL) {
        // Открытие ссылки
        UIApplication.shared.open(url)
    }
    
    func didOpenStory(storyId: String) {
        // Открытие конкретной истории
    }
}
```

### Типы кнопок

```swift
// Кнопка "Далее"
.actionType = .next

// Кнопка "Закрыть"
.actionType = .close

// Кнопка со ссылкой
.actionType = .link(URL(string: "https://example.com")!)
```

### Стили углов кнопок

```swift
// Без скругления
.corners = .none

// Круглая кнопка
.corners = .circle

// Кастомное скругление
.corners = .radius(12)
```

## 🚀 Примеры встраивания

### UIKit - Встраивание в существующий контроллер

```swift
import StoriesKit
import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var storiesContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStories()
    }
    
    private func setupStories() {
        // Создаем Stories контроллер
        let storiesViewController = Stories.build(
            groups: createStoriesGroups(),
            delegate: self
        )
        
        // Добавляем как дочерний контроллер
        addChild(storiesViewController)
        storiesContainerView.addSubview(storiesViewController.view)
        
        // Настраиваем Auto Layout
        storiesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            storiesViewController.view.topAnchor.constraint(equalTo: storiesContainerView.topAnchor),
            storiesViewController.view.leadingAnchor.constraint(equalTo: storiesContainerView.leadingAnchor),
            storiesViewController.view.trailingAnchor.constraint(equalTo: storiesContainerView.trailingAnchor),
            storiesViewController.view.bottomAnchor.constraint(equalTo: storiesContainerView.bottomAnchor)
        ])
        
        storiesViewController.didMove(toParent: self)
    }
    
    private func createStoriesGroups() -> [StoriesGroupModel] {
        return [
            StoriesGroupModel(
                id: "user1",
                title: "Пользователь 1",
                avatarImage: .url(URL(string: "https://example.com/avatar1.jpg")!),
                stories: [
                    StoriesPageModel(
                        title: AttributedString("Первая история"),
                        subtitle: AttributedString("Описание истории"),
                        backgroundColor: .systemBlue,
                        backgroundImage: StoriesImageModel(
                            image: .url(URL(string: "https://example.com/story1.jpg")!)
                        )
                    )
                ]
            )
        ]
    }
}

// MARK: - IStoriesDelegate
extension MainViewController: IStoriesDelegate {
    func didClose() {
        print("Stories закрыты")
    }
    
    func didOpenLink(url: URL) {
        UIApplication.shared.open(url)
    }
    
    func didOpenStory(storyId: String) {
        print("Открыта история: \(storyId)")
    }
}
```

### UIKit - Модальная презентация

```swift
import StoriesKit
import UIKit

class ViewController: UIViewController {
    
    @IBAction func showStoriesButtonTapped(_ sender: UIButton) {
        let storiesViewController = Stories.build(
            groups: createStoriesGroups(),
            delegate: self
        )
        
        // Настраиваем модальную презентацию
        storiesViewController.modalPresentationStyle = .overFullScreen
        storiesViewController.modalTransitionStyle = .crossDissolve
        
        present(storiesViewController, animated: true)
    }
    
    private func createStoriesGroups() -> [StoriesGroupModel] {
        // Ваши группы историй
        return []
    }
}

extension ViewController: IStoriesDelegate {
    func didClose() {
        dismiss(animated: true)
    }
    
    func didOpenLink(url: URL) {
        UIApplication.shared.open(url)
    }
    
    func didOpenStory(storyId: String) {
        print("Открыта история: \(storyId)")
    }
}
```

### SwiftUI - Встраивание в существующий View

```swift
import StoriesKit
import SwiftUI

struct MainView: View {
    @State private var showStories = false
    
    var body: some View {
        VStack {
            Text("Главный экран")
                .font(.title)
            
            Button("Показать Stories") {
                showStories = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Spacer()
        }
        .fullScreenCover(isPresented: $showStories) {
            StoriesView(
                groups: createStoriesGroups(),
                onClose: {
                    showStories = false
                }
            )
        }
    }
    
    private func createStoriesGroups() -> [StoriesGroupModel] {
        return [
            StoriesGroupModel(
                id: "user1",
                title: "Пользователь 1",
                avatarImage: .url(URL(string: "https://example.com/avatar1.jpg")!),
                stories: [
                    StoriesPageModel(
                        title: AttributedString("Первая история"),
                        subtitle: AttributedString("Описание истории"),
                        backgroundColor: .blue,
                        backgroundImage: StoriesImageModel(
                            image: .url(URL(string: "https://example.com/story1.jpg")!)
                        )
                    )
                ]
            )
        ]
    }
}

struct StoriesView: View {
    let groups: [StoriesGroupModel]
    let onClose: () -> Void
    
    var body: some View {
        Stories.buildSwiftUI(
            groups: groups,
            delegate: StoriesDelegate(onClose: onClose)
        )
    }
}

class StoriesDelegate: IStoriesDelegate {
    private let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    func didClose() {
        onClose()
    }
    
    func didOpenLink(url: URL) {
        UIApplication.shared.open(url)
    }
    
    func didOpenStory(storyId: String) {
        print("Открыта история: \(storyId)")
    }
}
```

### SwiftUI - Встраивание в NavigationView

```swift
import StoriesKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Добро пожаловать!")
                    .font(.title)
                
                NavigationLink(destination: StoriesScreenView()) {
                    Text("Перейти к Stories")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Главная")
        }
    }
}

struct StoriesScreenView: View {
    var body: some View {
        Stories.buildSwiftUI(
            groups: createStoriesGroups(),
            delegate: StoriesScreenDelegate()
        )
        .navigationBarHidden(true)
    }
    
    private func createStoriesGroups() -> [StoriesGroupModel] {
        return [
            StoriesGroupModel(
                id: "user1",
                title: "Пользователь 1",
                avatarImage: .url(URL(string: "https://example.com/avatar1.jpg")!),
                stories: [
                    StoriesPageModel(
                        title: AttributedString("История в навигации"),
                        subtitle: AttributedString("Это история внутри NavigationView"),
                        backgroundColor: .purple,
                        backgroundImage: StoriesImageModel(
                            image: .url(URL(string: "https://example.com/story1.jpg")!)
                        )
                    )
                ]
            )
        ]
    }
}

class StoriesScreenDelegate: IStoriesDelegate {
    func didClose() {
        // Можно использовать NavigationLink для возврата
        print("Stories закрыты")
    }
    
    func didOpenLink(url: URL) {
        UIApplication.shared.open(url)
    }
    
    func didOpenStory(storyId: String) {
        print("Открыта история: \(storyId)")
    }
}
```

### SwiftUI - Встраивание в TabView

```swift
import StoriesKit
import SwiftUI

struct TabContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Главная")
                }
            
            StoriesTabView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Stories")
                }
        }
    }
}

struct StoriesTabView: View {
    var body: some View {
        NavigationView {
            Stories.buildSwiftUI(
                groups: createStoriesGroups(),
                delegate: StoriesTabDelegate()
            )
            .navigationBarHidden(true)
        }
    }
    
    private func createStoriesGroups() -> [StoriesGroupModel] {
        return [
            StoriesGroupModel(
                id: "user1",
                title: "Пользователь 1",
                avatarImage: .url(URL(string: "https://example.com/avatar1.jpg")!),
                stories: [
                    StoriesPageModel(
                        title: AttributedString("Stories в табе"),
                        subtitle: AttributedString("Это Stories внутри TabView"),
                        backgroundColor: .green,
                        backgroundImage: StoriesImageModel(
                            image: .url(URL(string: "https://example.com/story1.jpg")!)
                        )
                    )
                ]
            )
        ]
    }
}

class StoriesTabDelegate: IStoriesDelegate {
    func didClose() {
        print("Stories в табе закрыты")
    }
    
    func didOpenLink(url: URL) {
        UIApplication.shared.open(url)
    }
    
    func didOpenStory(storyId: String) {
        print("Открыта история: \(storyId)")
    }
}
```

## 🎨 Кастомизация

### Цвета и стили
- Настройте `backgroundColor` для фона историй
- Используйте `AttributedString` для богатого форматирования текста
- Настройте цвета кнопок и их скругление

### Таймеры
- Установите `duration` для каждой истории (по умолчанию 4 секунды)
- Таймер автоматически приостанавливается при нажатии и возобновляется при отпускании

### Изображения
- Поддержка загрузки по URL с автоматическим кэшированием
- Placeholder изображения для лучшего UX
- Плавные переходы между изображениями

## 🏗️ Архитектура

StoriesKit построен на современной архитектуре с использованием:

- **SwiftUI** — для UI компонентов
- **Combine** — для реактивного программирования
- **MVVM** — архитектурный паттерн
- **Kingfisher** — для загрузки и кэширования изображений

### Основные компоненты

- `Stories` — главный класс для создания историй
- `ContainerView` — SwiftUI контейнер для историй
- `ContentView` — основной контент с навигацией
- `PageView` — отдельная страница истории
- `ViewModel` — управление состоянием и логикой
- `ViewController` — UIKit презентация
- `ProgressBarView` — индикатор прогресса
- `StoriesImageView` — отображение изображений

### События и состояние

- `ViewEvent` — события пользователя (тапы, свайпы, таймеры)
- `ViewState` — текущее состояние (группы, прогресс, индексы)
- `IStoriesDelegate` — протокол для обработки событий

## 📱 Требования

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## 🔧 Зависимости

- [Kingfisher](https://github.com/onevcat/Kingfisher) — для загрузки изображений

## 📄 Лицензия

StoriesKit распространяется под лицензией MIT. См. файл [LICENSE](LICENSE) для подробностей.

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие StoriesKit! Пожалуйста, ознакомьтесь с нашими [правилами контрибуции](CONTRIBUTING.md).

## 📞 Поддержка

Если у вас есть вопросы или предложения, создайте [issue](https://github.com/yourusername/StoriesKit/issues) или свяжитесь с нами.

---

**Сделано с ❤️ для iOS разработчиков**