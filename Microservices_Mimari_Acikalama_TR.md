# Spring Cloud Microservices Mimarisi - Açıklamalar

Bu dosya, projedeki farklı bileşenleri detaylı olarak açıklar.

---

## 📋 İçindekiler

1. [API Modülü](#api-modülü)
2. [Util Modülü](#util-modülü)
3. [Product Service](#product-service)
4. [Recommendation Service](#recommendation-service)
5. [Review Service](#review-service)
6. [Product Composite Service](#product-composite-service)
7. [Gateway](#gateway)
8. [Authorization Server](#authorization-server)
9. [İlişkisel Diyagram](#ilişkisel-diyagram)

---

## 🎯 API Modülü

**Konum:** `api/src/main/java/se/magnus/api/`

### Amaç
Microservices'lerin birbirleriyle konuşabilmesi için ortak veri formatlarını (DTO'ları) ve servis sözleşmelerini (interface'leri) içerir.

### Ana Bileşenler

#### 1. Composite Paket
- **ProductCompositeDTO**: Ürün, öneriler ve incelemeleri bir arada gösteren birleştirilmiş görünüm
- **RecommendationSummaryDTO**: Bir ürün için tüm önerilerin listesi
- **ReviewSummaryDTO**: Bir ürün için tüm incelemelerin listesi
- **ServiceAddressesDTO**: Servislerin endpoint adreslerini gösterir (teknik bilgi, kullanıcıya gösterilmez)

#### 2. Core Paket
- **ProductDTO**: Ürün bilgilerini taşır (productId, productId, name, description, price)
- **Product**: Veritabanı entity'si için temel sınıf (MapStruct için)
- **ProductService**: Ürün servisi için kontrat/interface
- **RecommendationDTO** & **RecommendationService**: Öneri servisi için
- **ReviewDTO** & **ReviewService**: İnceleme servisi için

#### 3. Event Paket
- **Event**: Domain olaylarını taşır (örneğin fiyat güncellendiğinde)

#### 4. Exception Paket
- **BadRequestException**: Geçersiz istekler için
- **EventProcessingException**: Olay işleme hataları için
- **InvalidInputException**: Geçersiz girdiler için
- **NotFoundException**: Bulunamayan kaynaklar için

### Tasarım Prensipleri

**Neden ayrı bir API modülü?**
- **Sözleşme Odaklı**: Servisler arasındaki iletişimi tanımlar
- **Bağımlılık Yönetimi**: Tüm servisler aynı DTO'lara bağımlı olur
- **Güvenlik**: Sensitif alanlar (örn. serviceAddresses) kullanıcıya gösterilmez

---

## 🛠️ Util Modülü

**Konum:** `util/src/main/java/se/magnus/util/`

### Amaç
Tüm microservices'ler tarafından paylaşılan yardımcı bileşenleri içerir.

### Ana Bileşenler

#### 1. ServiceUtil
- Servisin çalıştığı host, port ve ortam bilgilerini döndürür
- **getURL()**: Servisin HTTP URL'ini oluşturur
- **toString()**: Hizmet detaylarını formatlar

```java
{
  "host": "product-service",
  "port": "8081",
  "environment": "prod"
}
```

#### 2. GlobalControllerExceptionHandler
- Tüm servislerdeki hataları yakalar
- Kullanıcı dostu hata mesajları döndürür
- Teknik detayları gizler

```java
@ExceptionHandler(Exception.class)
public ResponseEntity<HttpErrorInfo> handleException(...) {
    // Hata bilgilerini kullanıcı dostu şekilde döndürür
}
```

### Tasarım Prensipleri

**Neden paylaşılan bir util modülü?**
- **Tutarlılık**: Tüm servislerde aynı hata işleme davranışı
- **Tekrarın Önlenmesi**: Kod tekrarı azalır
- **Ortak İşlevsellik**: Tek bir yerde yönetilen ortak işlevsellik

---

## 📦 Product Service

**Konum:** `microservices/product-service/`

### Amaç
Ürün bilgilerini (ürün kimliği, açıklama, fiyat) saklar ve yönetir.

### Teknik Detaylar
- **Veritabanı**: MongoDB (NoSQL)
- **Programlama Modeli**: Reactive (Spring WebFlux)
- **HTTP Port**: 8081

### Bileşenler

#### 1. ProductEntity
```java
@Document(collection = "products")
public class ProductEntity {
    @Id
    private String id;
    private Integer productId;
    private String name;
    private String description;
    private BigDecimal price;
}
```

#### 2. ProductRepository
- Spring Data MongoDB ile oluşturulur
- `findByProductId()` metodu ile ürün araması
- Reactive repository (CrudRepository yerine)

#### 3. ProductMapper
```java
@Mapper(componentModel = "spring")
public interface ProductMapper {
    Product toProduct(ProductEntity entity);
    ProductEntity toProductEntity(Product product);
}
```
- MapStruct kullanır
- Entity ve DTO arasında otomatik çevrim
- `@Autowired` MapstructImpl kullanır

#### 4. ProductServiceApplication
- Spring Boot uygulamasının giriş noktası
- `@EnableMongoRepositories` ile MongoDB desteklenir

#### 5. MessageProcessorConfig
- Domain olaylarını yayınlar
- Örneğin: Product fiyatı güncellendiğinde
```java
@Async("asyncTaskExecutor")
public void publishPriceChange(Product priceChange) {
    applicationEventPublisher.publishEvent(priceChange);
}
```

#### 6. ProductServiceImpl
- Ürün işlevselliğini gerçekleştiren ana servis sınıfı
- **findCompositeProductDetails**: Composite servisi için ürün bilgilerini getirir
- **Reactive**: Mono<Product> döndürür (tek ürün)
- **Non-blocking**: Uygulama beklerken başka işler yapabilir

### Veri Akışı
```
Kullanıcı → Product Service → MongoDB → Ürün Bilgileri
```

### API Endpoints
```
GET /product-composite/1  → Ürün detaylarını döndürür
```

---

## 💡 Recommendation Service

**Konum:** `microservices/recommendation-service/`

### Amaç
Ürün önerilerini saklar (hangi ürün için hangi öneriler mevcut).

### Teknik Detaylar
- **Veritabanı**: MongoDB (NoSQL)
- **Programlama Modeli**: Reactive (Spring WebFlux)
- **HTTP Port**: 8083

### Bileşenler

#### 1. RecommendationEntity
```java
@Document(collection = "recommendations")
public class RecommendationEntity {
    @Id
    private String id;
    private Integer productId;
    private String recommendationId;
    private String author;
    private String content;
}
```

#### 2. RecommendationRepository
- Spring Data MongoDB ile oluşturulur
- `findByProductId()` ile ürün bazlı önerileri getirir

#### 3. RecommendationMapper
```java
@Mapper(componentModel = "spring")
public interface RecommendationMapper {
    Recommendation toRecommendation(RecommendationEntity entity);
}
```

#### 4. RecommendationServiceImpl
- Tüm önerileri toplar
- **Flux<RecommendationSummary>**: Birden fazla öneri için
- **Reactive**: Non-blocking

### Veri Akışı
```
Kullanıcı → Recommendation Service → MongoDB → Öneriler
```

### API Endpoints
```
GET /recommendations/1  → Bir ürün için tüm önerileri döndürür
```

---

## ⭐ Review Service

**Konum:** `microservices/review-service/`

### Amaç
Ürün incelemelerini saklar (kullanıcı yorumları, yıldız derecelendirmeleri).

### Teknik Detaylar
- **Veritabanı**: MySQL (SQL)
- **Programlama Modeli**: Reactive (Spring WebFlux)
- **HTTP Port**: 8082

### Bileşenler

#### 1. ReviewEntity
```java
@Table(name = "reviews")
public class ReviewEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Integer productId;
    private String reviewer;
    private String reviewSubject;
    private Integer reviewRating;
    private String reviewMessage;
}
```

#### 2. ReviewRepository
- Spring Data JPA ile oluşturulur
- `findByProductId()` ile ürün bazlı incelemeleri getirir

#### 3. ReviewMapper
```java
@Mapper(componentModel = "spring")
public interface ReviewMapper {
    Review toReview(ReviewEntity entity);
}
```

#### 4. ReviewServiceImpl
- Tüm incelemeleri toplar
- **Flux<ReviewSummary>**: Birden fazla inceleme için
- **Reactive**: Non-blocking

### Veri Akışı
```
Kullanıcı → Review Service → MySQL → İncelemeler
```

### API Endpoints
```
GET /reviews/1  → Bir ürün için tüm incelemeleri döndürür
```

---

## 🎵 Product Composite Service

**Konum:** `microservices/product-composite-service/`

### Amaç
Ürün bilgilerini, incelemeleri ve önerileri birleştirir. Bir "orchestrator" görevi görür.

### Teknik Detaylar
- **Veritabanı**: Yok (stateless)
- **Programlama Modeli**: Reactive (Spring WebFlux)
- **HTTP Port**: 8080
- **Circuit Breaker**: Resilience4j

### Bileşenler

#### 1. ProductCompositeServiceApplication
- Ana uygulama başlatıcısı
- `@EnableEurekaServer`: Service discovery için (eğer kullanılıyorsa)
- `@EnableReactiveBus`: Centralized bus için

#### 2. ProductCompositeServiceImpl (Ana İş Mantığı)
```java
public class ProductCompositeServiceImpl implements ProductCompositeService {
    
    @Autowired
    private ObjectMapper mapper;
    
    @Autowired
    private ProductCompositeIntegration integration;
    
    @Autowired
    private CircuitBreakerFactory cbFactory;
    
    @Override
    public Mono<ProductComposite> getCompositeProduct(int productId) {
        // 1. Ürün bilgilerini al
        Mono<Product> productMono = ...
        
        // 2. İncelemeleri al (Circuit Breaker ile)
        Mono<List<ReviewSummary>> reviewsMono = ...
        
        // 3. Önerileri al (Circuit Breaker ile)
        Mono<List<RecommendationSummary>> recommendationsMono = ...
        
        // 4. Birleştir
        return productMono.zipWith(reviewsMono, recommendationsMono);
    }
}
```

**İş Akışı:**
1. Kullanıcıdan ürün ID'sini alır
2. Product servisi'ne istek gönderir
3. Review servisi'ne istek gönderir
4. Recommendation servisi'ne istek gönderir
5. Tüm verileri birleştirir
6. ProductComposite DTO'sunu döndürür

#### 3. Circuit Breaker (Resilience4j)
```java
private CircuitBreaker reviewsCircuitBreaker;
private CircuitBreaker recommendationsCircuitBreaker;

reviewsCircuitBreaker = cbFactory.create("reviews");
recommendationsCircuitBreaker = cbFactory.create("recommendations");
```

**Circuit Breaker Pattern:**
- **Closed**: Normal durum, servisler çalışıyor
- **Open**: Servisler hata veriyor, istekler direkt reddediliyor
- **Half-Open**: Servisler tekrar deneniyor, eğer başarılıysa closed'a döner

**Neden Circuit Breaker?**
- Bir servis çökse bile diğerleri çalışmaya devam eder
- Sistem parçalarını korur
- Graceful degradation (kısım hizmet verme)

#### 4. ProductCompositeIntegration
- Feign client kullanır
- Dış servislerle iletişim kurar
```java
public interface ProductCompositeIntegration {
    @GetMapping("/product/{productId}")
    Mono<Product> getProduct(int productId);
    
    @GetMapping("/reviews/{productId}")
    Flux<ReviewSummary> getReviews(int productId);
    
    @GetMapping("/recommendations/{productId}")
    Flux<RecommendationSummary> getRecommendations(int productId);
}
```

### Veri Akışı
```
Kullanıcı → Composite Service → [Product + Review + Recommendation] → Birleştirilmiş Yanıt
```

### API Endpoints
```
GET /product-composite/1  → Birleştirilmiş ürün bilgileri döndürür
```

---

## 🚪 Gateway

**Konum:** `spring-cloud/gateway/`

### Amaç
Tek giriş noktasıdır. İstemcileri iç servislerden korur.

### Teknik Detaylar
- **HTTP Port**: 8443 (HTTPS)
- **HTTPS**: TLS ile güvenli bağlantı
- **Ön Yönlendirme (Load Balancing)**: İç servisler için

### Bileşenler

#### 1. GatewayConfiguration
```java
@Configuration
public class GatewayConfiguration {
    
    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("product-composite", r -> r
                .path("/product-composite/**")
                .filters(f -> f.rewritePath("/product-composite/(?<segment>.*)", 
                    "/${segment}"))
                .uri("lb://product-composite"))
            .route("auth-server", r -> r
                .path("/oauth/token")
                .uri("lb://auth-server"))
            .build();
    }
}
```

#### 2. SecurityConfig
```java
@Bean
public SecurityWebFilterChain securityWebFilterChain() {
    return SecurityWebFilterSpec
        .securityMatcher(requestMatcher("/auth-server/**"))
        .oauth2ResourceServer(oauth2 -> oauth2.jwt())
        .build();
}
```

### Neden Gateway?

**Güvenlik:**
- Tüm istekleri denetler
- Kimlik doğrulama ve yetkilendirme sağlar
- TLS ile şifreli bağlantı

**Yönetim:**
- Tek noktadan tüm istekleri yönetir
- İç servislerin varlıklarını gizler
- Yükleme dağıtımı için load balancer olarak çalışır

**Basitleştirme:**
- İstemcilerin sadece bir endpoint ile uğraşması gerekir
- Servis mimarisindeki değişiklikleri gizler

---

## 🔐 Authorization Server

**Konum:** `spring-cloud/authorization-server/`

### Amaç
Kimlik doğrulama ve yetkilendirme sağlar. OAuth2 ve OIDC (OpenID Connect) kullanır.

### Teknik Detaylar
- **HTTP Port**: 8444 (HTTPS)
- **Protokol**: OAuth2 Authorization Server, OIDC
- **HTTPS**: TLS ile güvenli bağlantı

### Bileşenler

#### 1. AuthorizationServerConfig
```java
@Configuration
public class AuthorizationServerConfig {
    
    @Bean
    @Order(1)
    public SecurityFilterChain securityFilterChain(HttpSecurity http) {
        return http
            .securityMatcher("/oauth2/**")
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/oauth2/**").permitAll()
                .anyRequest().authenticated())
            .oauth2AuthorizationServer(oauth2 -> oauth2
                .accessTokenConversion(token -> token.sign(jwtSigner)))
            .build();
    }
    
    @Bean
    public NimbusEncryptionManager encryptionManager() {
        return new NimbusEncryptionManager(jwkSet);
    }
}
```

#### 2. Jwks (JSON Web Key Set)
- RSA anahtarlarını oluşturur ve saklar
```java
public class Jwks {
    public static KeyPair createKeyPair() {
        return KeyGeneratorUtils.createRsaKeyPair();
    }
    
    public static String toJwkSet(KeyPair keyPair) {
        // Anahtarları JWK formatına dönüştürür
    }
}
```

#### 3. SecurityConfig
- Default security yapılandırması
- Spring Security ile entegre

### Kimlik Doğrulama Akışı

**1. Kullanıcı oturum açar:**
```
Kullanıcı → Authorization Server → OAuth2 Token
```

**2. Token kullanılarak servis çağrılır:**
```
İstemci → Gateway (Authorization: Bearer <token>) → İç Servisler
```

**3. Gateway token'ı doğrular:**
- JWT token'ını kontrol eder
- İmza doğrulaması yapar
- Sonra iç servislere yönlendirir

### Neden OAuth2/OIDC?

**Güvenlik:**
- Token tabanlı kimlik doğrulama
- JWT formatı, taşınabilir ve güvenli
- Merkezi kimlik doğrulama

**Kullanıcı Deneyimi:**
- Tek oturum açma (Single Sign-On)
- Token tekrar kullanılabilir
- Kullanıcı sadece bir kez oturum açar

---

## 📊 İlişkisel Diyagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         KULLANICI (WEB/CLIENT)                          │
└─────────────────────────────────────┬───────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          GATEWAY (8443 HTTPS)                            │
│  - Yönlendirme                                                           │
│  - HTTPS/TLS                                                             │
│  - Kimlik Doğrulama                                                       │
└─────────────────────────────────────┬───────────────────────────────────┘
                                      │
                ┌─────────────────────┼─────────────────────┐
                ▼                     ▼                     ▼
┌───────────────────────┐  ┌───────────────────────┐  ┌───────────────────────┐
│  PRODUCT COMPOSITE    │  │  AUTHORIZATION        │  │  CONFIG SERVER         │
│  SERVICE (8080)       │  │  SERVER (8444 HTTPS)  │  │  (Centralized Config)  │
│                       │  │                       │  │                        │
│  - Ürün bilgileri     │  │  - OAuth2 token       │  │  - Merkezi ayarlar      │
│  - İncelemeler        │  │  - OIDC               │  │  - Tüm servisler       │
│  - Öneriler           │  │  - RSA anahtarları     │  │    okur                 │
│                       │  │                       │  │                        │
│  ┌─────────────────┐  │  └───────────────────────┘  └───────────────────────┘
│  │ Circuit Breaker │  │
│  └─────────────────┘  │
│                       │
│  ┌─────────────────┐  │
│  │ Product         │  │
│  │ Composite       │  │
│  │ Integration     │  │
│  └────────┬────────┘  │
└───────────┼───────────┘
            │
    ┌───────┼───────┬───────────┐
    ▼       ▼       ▼           ▼
┌─────────┐ ┌─────────┐ ┌─────────┐  ┌───────────────────┐
│PRODUCT  │ │REVIEW   │ │RECOMMEND│  │  DOMAIN EVENTS     │
│SERVICE  │ │SERVICE  │ │ATION    │  │  (Asenkron)        │
│(8081)   │ │(8082)   │ │SERVICE  │  │                   │
│         │ │         │ │(8083)   │  │  ┌─────────────┐   │
│MongoDB  │ │MySQL    │ │MongoDB   │  │ │  Broker     │   │
│         │ │         │ │         │  │ │  (Kafka/RabbitMQ) │
└─────────┘ └─────────┘ └─────────┘  │  └─────────────┘   │
                                     └───────────────────────┘
```

### Servis İlişkileri

| Servis | Veritabanı | Port | Amaç |
|--------|-----------|------|------|
| Product Service | MongoDB | 8081 | Ürün bilgileri saklama |
| Review Service | MySQL | 8082 | Kullanıcı incelemeleri |
| Recommendation Service | MongoDB | 8083 | Ürün önerileri |
| Product Composite Service | None | 8080 | Veri birleştirme |
| Gateway | None | 8443 | Merkezi giriş |
| Authorization Server | None | 8444 | Kimlik doğrulama |

### Mesaj Akışı (Ürün Araması)

1. **Kullanıcı → Gateway**: `GET /product-composite/1`
2. **Gateway → Product Composite Service**: Yönlendirir
3. **Product Composite Service:**
   - Circuit Breaker: "Reviews" açık
   - Circuit Breaker: "Recommendations" açık
4. **Product Composite Service → Product Service**: Ürün bilgileri al
5. **Product Service → MongoDB**: Ürün verisi al
6. **Product Composite Service → Review Service**: İncelemeler al
7. **Review Service → MySQL**: İncelemeler al
8. **Product Composite Service → Recommendation Service**: Öneriler al
9. **Recommendation Service → MongoDB**: Öneriler al
10. **Product Composite Service → Kullanıcı**: Birleştirilmiş veri

---

## 🎓 Özet ve Öneriler

### Kullanılan Tasarım Prensipleri

1. **Single Responsibility**: Her servis tek bir sorumluluğa sahiptir
2. **API First**: DTO'lar sözleşme olarak tanımlanır
3. **Reactive Programming**: Non-blocking, yüksek performanslı
4. **Circuit Breaker**: Servis hatalarına karşı dayanıklılık
5. **Polyglot Persistence**: Her servisin veritabanı ihtiyacı
6. **Centralized Configuration**: Merkezi ayar yönetimi
7. **Security**: OAuth2, OIDC, TLS ile güvenli iletişim

### Öneriler

- **Prodüksiyonda**: Monitoring (Prometheus + Grafana) ekleyin
- **Prodüksiyonda**: Centralized Logging (ELK Stack) kullanın
- **Prodüksiyonda**: Kubernetes ile deployment yapın
- **Prodüksiyonda**: Service Mesh (Istio) ekleyin
- **Geliştirme**: Unit ve Integration testleri ekleyin
- **Geliştirme**: Load testing ile performansı test edin

---

**Kaynak:** Spring Microservices Architecture
**Güncelleme:** 2025
