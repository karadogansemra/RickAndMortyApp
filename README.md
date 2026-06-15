# RickAndMortyApp

Rick & Morty karakterlerini listeleyen, detaylarını gösteren ve cihaz
galerisiyle entegre çalışan bir UIKit / Swift uygulaması.

## 🚀 Projeyi Çalıştırma

### Gereksinimler
- Xcode 15.0+
- iOS 15.0+
- CocoaPods veya Swift Package Manager

### Kurulum

1. Projeyi klonlayın:
```bash
git clone <repo-url>
cd RickAndMortyApp
```

2. Bağımlılıkları yükleyin (CocoaPods kullanıyorsanız):
```bash
pod install
open RickAndMortyApp.xcworkspace
```

3. **Firebase Kurulumu** (Opsiyonel):
   - Firebase Console'dan `GoogleService-Info.plist` dosyasını indirin
   - Proje köküne ekleyin
   - Dosya yoksa Firebase satırları otomatik devre dışı kalır

4. Xcode'da `Cmd+R` ile çalıştırın

### Bağımlılıklar
| Kütüphane | Versiyon | Kullanım |
|-----------|----------|----------|
| Alamofire | ~> 5.9 | Network katmanı |
| Kingfisher | ~> 7.11 | Asenkron görsel yükleme & cache |
| Firebase/Analytics | - | Kullanıcı analitikleri |
| Firebase/Crashlytics | - | Crash raporlama |

---

## 🏗 Mimari

Proje **Clean Architecture** prensiplerine uygun olarak **MVVM-C** (Model-View-ViewModel-Coordinator) pattern ile yapılandırılmıştır.

### Katman Yapısı

```
RickAndMortyApp/
├── Application/                    # Uygulama giriş noktası
│   ├── AppDelegate.swift          # Firebase konfigürasyonu
│   ├── SceneDelegate.swift        # Window ve root coordinator
│   └── DependencyContainer.swift  # Dependency Injection container
│
├── Domain/                         # İş mantığı katmanı (saf Swift)
│   ├── Entities/                  # Domain modelleri
│   │   ├── CharacterEntity.swift
│   │   └── GalleryPhoto.swift
│   ├── UseCases/                  # İş kuralları
│   │   ├── FetchCharactersUseCase.swift
│   │   ├── GalleryPhotosUseCase.swift
│   │   └── SavePhotoUseCase.swift
│   └── Repositories/              # Repository protokolleri
│       ├── CharacterRepositoryProtocol.swift
│       └── PhotoLibraryRepositoryProtocol.swift
│
├── Data/                           # Veri erişim katmanı
│   ├── Network/                   # API iletişimi
│   │   ├── APIClient.swift
│   │   ├── Endpoint.swift
│   │   ├── NetworkError.swift
│   │   └── DTOs/
│   │       └── CharacterDTO.swift
│   ├── Persistence/               # Yerel veri depolama
│   │   └── CoreDataStack.swift
│   └── Repositories/              # Repository implementasyonları
│       ├── CharacterRepository.swift
│       └── PhotoLibraryRepository.swift
│
├── Presentation/                   # UI katmanı
│   ├── Common/
│   │   ├── Coordinator/           # Navigation yönetimi
│   │   │   ├── Coordinator.swift
│   │   │   └── AppCoordinator.swift
│   │   └── Extensions/
│   │       └── UIViewController+Extensions.swift
│   ├── CharacterList/             # Sayfa 1: Karakter listesi
│   │   ├── CharacterListCoordinator.swift
│   │   ├── CharacterListViewController.swift
│   │   ├── CharacterListViewModel.swift
│   │   └── Cells/
│   │       ├── CharacterCell.swift
│   │       └── GalleryPhotoCell.swift
│   ├── CharacterDetail/           # Sayfa 2: Karakter detayı
│   │   ├── CharacterDetailViewController.swift
│   │   └── CharacterDetailViewModel.swift
│   └── PhotoDetail/               # Sayfa 3: Fotoğraf detayı
│       ├── PhotoDetailViewController.swift
│       └── PhotoDetailViewModel.swift
│
└── Resources/
    └── Info.plist
```

### Mimari Prensipler

#### 1. **Dependency Injection**
- `DependencyContainer` singleton tüm bağımlılıkları yönetir
- Protocol-based tasarım sayesinde her katman mock'lanabilir
- Test edilebilirlik maksimize edilmiştir

#### 2. **Coordinator Pattern**
- Navigation logic ViewController'lardan ayrılmıştır
- `AppCoordinator` → `CharacterListCoordinator` hiyerarşisi
- Deep linking ve complex navigation akışları kolayca eklenebilir

#### 3. **Use Cases**
- Her iş mantığı operasyonu ayrı bir UseCase'de kapsüllenmiştir
- Single Responsibility Principle uygulanmıştır
- Repository'lere doğrudan erişim yerine UseCase'ler kullanılır

#### 4. **Repository Pattern**
- Data source abstraction (API, Cache, Photos)
- Domain katmanı veri kaynağından bağımsızdır
- Offline-first yaklaşım kolayca uygulanabilir

---

## 📱 Özellikler

### Sayfa 1 – Karakter Listeleme
- ✅ Rick & Morty API entegrasyonu
- ✅ UICollectionView + Compositional Layout
- ✅ Adaptif grid (2-4 sütun, ekran genişliğine göre)
- ✅ Sayfalama (infinite scroll)
- ✅ Loading indicator
- ✅ Asenkron görsel yükleme (Kingfisher)
- ✅ Cihaz galerisi entegrasyonu
- ✅ Fotoğraf sıralama (tarihe göre)
- ✅ Pull-to-refresh

### Sayfa 2 – Karakter Detay
- ✅ Büyük karakter fotoğrafı
- ✅ Name, Status, Species, Gender, Origin, Location bilgileri
- ✅ Fotoğrafa tıklayınca Photo Detail açılır

### Sayfa 3 – Fotoğraf Detay
- ✅ Tam ekran fotoğraf görüntüleme
- ✅ Pinch to zoom
- ✅ Double tap to zoom
- ✅ Pull to dismiss
- ✅ Galeriye kaydetme butonu

### Bonus Özellikler
- ✅ Firebase Analytics & Crashlytics
- ✅ Unit Tests (ViewModel layer)
- ✅ Offline support (CoreData cache)
- ✅ Pull to refresh
- ✅ Pull to dismiss
- ✅ Zoom gestures
- ✅ Multi-language support (EN/TR)
- ✅ xcconfig-based environment management
- ✅ Animated splash screen
- ✅ Multi-tenant network layer
- ✅ Rate limiting retry with exponential backoff

---

## 🔌 Yeni API Ekleme Örneği (Picsum Photos)

Projedeki multi-tenant yapı sayesinde yeni bir API eklemek çok basittir. Aşağıda **Picsum Photos API**'sinin nasıl eklendiğinin adımları gösterilmiştir.

### Adım 1: xcconfig'e URL ekle

`Base.xcconfig`:
```xcconfig
PICSUM_API_BASE_URL = https:/$()/picsum.photos/v2
PICSUM_IMAGE_BASE_URL = https:/$()/picsum.photos
```

### Adım 2: Info.plist'e key ekle

```xml
<key>PicsumAPIBaseURL</key>
<string>$(PICSUM_API_BASE_URL)</string>
<key>PicsumImageBaseURL</key>
<string>$(PICSUM_IMAGE_BASE_URL)</string>
```

### Adım 3: AppConfiguration'a property ekle

```swift
// AppConfiguration.swift → API enum içine:
static var picsumBaseURL: URL {
    let urlString: String = value(for: "PicsumAPIBaseURL")
    return URL(string: urlString)!
}

static var picsumImageBaseURL: URL {
    let urlString: String = value(for: "PicsumImageBaseURL")
    return URL(string: urlString)!
}
```

### Adım 4: Model oluştur ve çek

```swift
// Decodable model (API response'a uygun)
struct PicsumPhoto: Hashable, Decodable {
    let id: String
    let author: String
    let downloadUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, author
        case downloadUrl = "download_url"
    }
    
    var thumbnailURL: URL? {
        AppConfiguration.API.picsumImageBaseURL
            .appendingPathComponent("id/\(id)/200/200")
    }
}

// Çağrı - tek satır:
let photos: [PicsumPhoto] = try await SimpleAPIClient.shared.fetch(
    from: AppConfiguration.API.picsumBaseURL,
    path: "/list",
    query: ["page": "1", "limit": "10"]
)
```

### Adım 5: Listede göster

ViewModel'e section ekle, cell oluştur, snapshot'a ekle. Bitti!

### Özet: Yeni API = 3 adım konfigürasyon + 1 model + 1 fetch çağrısı

| Ne | Nerede |
|----|--------|
| Base URL | `Base.xcconfig` |
| URL okuma | `Info.plist` → `AppConfiguration` |
| Veri çekme | `SimpleAPIClient.shared.fetch(from:path:query:)` |
| Gösterim | Kingfisher ile `imageView.kf.setImage(with: url)` |

> **Not:** URL değişikliği gerektiğinde sadece xcconfig düzenlenir, kod değişmez.
> Ortam bazlı farklı URL'ler için Debug/Staging/Release xcconfig dosyalarında farklı değerler tanımlanabilir.

---

## 🧪 Testler

Unit testler `RickAndMortyAppTests` target'ında bulunur:

```bash
# Terminal'den çalıştırma
xcodebuild test \
  -scheme RickAndMortyApp \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Veya Xcode'da Cmd+U
```

### Test Kapsamı
- `CharacterListViewModelTests`: Sayfalama, offline fallback, galeri deduplication
- Mock'lar: `MockAPIClient`, `MockCharacterRepository`, `MockPhotoLibraryRepository`

---

## 📝 Teknik Notlar

### Programatik CoreData Model
- `.xcdatamodeld` dosyası kullanılmamıştır
- Model `CoreDataStack.createManagedObjectModel()` ile runtime'da oluşturulur
- Bu yaklaşım version control ve code review'u kolaylaştırır

### Swift Concurrency
- `async/await` pattern kullanılmıştır
- `@MainActor` ile UI güncellemeleri güvenli hale getirilmiştir
- Network ve Photos framework operasyonları asenkron çalışır

### Photos Framework
- `PHCachingImageManager` ile performanslı thumbnail yükleme
- `.readWrite` authorization level
- Deduplication localIdentifier bazında yapılır

---

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.
