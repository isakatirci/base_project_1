# Microservices Architecture - Complete Guide
## YouTube Video Transcript

---

## [00:00 - Introduction]

**[Camera: Host on screen, background showing a modern office or home setup]**

**Host:** "Merhaba! Bugün size spring-microservices-mongo-mysql-ademozdeme adında bir projeyi detaylı olarak anlatacağım. Bu proje, gerçek dünya senaryolarını simüle eden, Spring Framework kullanılarak geliştirilmiş tam kapsamlı bir microservices mimarisi örneği.

**[Camera: Ekran paylaşımına geçiş, project root directory gösteriliyor]**

Bu videoyu izledikten sonra:
- Microservices mimarisinin temel mantığını anlayacaksınız
- API modülü, util modülü ve farklı microservices yapılandırmasını göreceksin
- Spring WebFlux ve reactive programlama mantığını öğreneceksiniz
- Circuit Breaker pattern'in nasıl çalıştığını göreceksiniz
- Gateway ve OAuth2 Authorization Server'ın önemini kavrayacaksınız
- Docker Compose ile nasıl deploy edileceğini öğreneceksiniz

Şimdi başlayalım!"

---

## [01:30 - Proje Genel Yapısı]

**[Camera: IDE'de proje ağacı gösteriliyor]**

**Host:** "İlk olarak proje yapısına bakalım. Proje dört ana bölümde organize edilmiş:

**İlk bölüm: API.** Bu bizim 'paylaşılan dilimiz'. Mikroservices'lerin birbirleriyle konuşabilmesi için hangi veri formatlarını kullanacaklarını buraya yazıyoruz.

**İkinci bölüm: Util.** Bu modül, tüm servislerin kullanabileceği yardımcı kodları içeriyor.

**Üçüncü bölüm: Microservices.** Burası sistemin asıl 'beyin' kısmı. Burada gerçek iş mantığı yer alıyor.

**Dördüncü bölüm: Spring-Cloud.** Bu, trafiği yöneten ve güvenliği sağlayan 'altyapı' parçaları için kullanılıyor.

Böyle bir yapı kullanmanın sebebi: Her şeyi tek bir klasöre koymak, çok kısa sürede karışık bir durum yaratır. Bu yapı düzeni sağlar."

---

## [04:00 - Pom.xml - Master Konfigürasyon]

**[Camera: Root pom.xml dosyası açılıyor]**

**Host:** "Root klasörde bir pom.xml dosyası var. Bu Maven'in master konfigürasyon dosyası. Bu dosya ile şunu söylüyoruz: 'Sadece oluşturduğum klasörler değil, tüm modüller tek büyük bir sistemin parçaları'.

Pom.xml'ta görebilirsiniz ki, burada tüm modüllerin bağımlılıkları merkezi olarak tanımlanmış. Örneğin MapStruct, Spring Boot, Spring Cloud gibi bağımlılıkların versiyonları burada tek bir yerde kontrol ediliyor.

Bu sayede, bir bağımlılık versiyonunu güncellemek istediğinizde, sadece bu dosyayı değiştirmeniz yeterli. Tüm projede otomatik olarak geçerli olur."

---

## [05:30 - API Modülü - Paylaşılan Dil]

**[Camera: api klasörü açılıyor, package yapısı gösteriliyor]**

**Host:** "Şimdi api klasörüne girelim. Microservices dünyasında, servislerin birbirlerini anlayabilmesi için ortak bir dile ihtiyacımız var.

**DTO'lar (Data Transfer Objects):**
Örnekte gördüğünüz Product, Recommendation ve Review DTO'ları, Java record'lar. Basit veri taşıma yapıları. Örneğin Product DTO'su şunları içeriyor:
- productId
- name
- description
- price

**Servis Interface'leri:**
ProductService, RecommendationService ve ReviewService interface'leri, 'blueprint' veya kontrat görevi görür. Bir servisin bu interface'i uygulaması, 'en azından bu metodları implement etmiş olur' anlamına gelir.

**Örnek:** ProductService interface'i, 'Product ID ile ürün bulabilen' bir servisin olacağını garanti eder. Mantık henüz yazılmamış, sadece sözleşme var.

**[Camera: exceptions klasörü gösteriliyor]**

**Exception Handler'lar:**
BadRequestException, InvalidInputException, NotFoundException gibi exception'lar, sistemin daha iyi hata mesajları sunması için kullanılıyor."

---

## [08:00 - Util Modülü - Güvenlik Ağı]

**[Camera: util klasörü ve GlobalControllerExceptionHandler gösteriliyor]**

**Host:** "Şimdi util klasörüne bakalım. Bu modülde bir tane önemli sınıf var: GlobalControllerExceptionHandler.

Bu sınıf bir 'güvenlik ağı' gibi çalışır. Bir kullanıcı ürün arıyor ve ürün bulunamıyor. Olayın nasıl işlendiğini görelim:

**İş Akışı:**
1. Bir servis hatayı yakalar
2. GlobalControllerExceptionHandler hatayı yakalar
3. User'a anlaşılır bir hata mesajı gösterir
4. Teknik detaylar gizlenir, sadece gerekli bilgi verilir

Bu sayede, kullanıcıya 'karışık teknik yazı' yerine 'aranan ürün bulunamadı' gibi anlaşılır bir mesaj gösterilir."

---

## [10:00 - Ürün Servisi - İlk 'Beyin']

**[Camera: microservices/product-service klasörü açılıyor]**

**Host:** "Şimdi microservices/product-service klasörüne geçiyoruz. Bu servis, ürünleri yönetmekten sorumlu.

**Veri Modeli:**
ProductEntity sınıfı, MongoDB'de veritabanı varlığımızı temsil eder. Şunu fark etmişsinizdir: API'deki DTO ile veritabanındaki entity farklı yapıdadır.

**MapStruct - Otomatik Çevirmen:**
Bu farkı kapatmak için MapStruct kullanıyoruz. Örneğin ProductMapper, veritabanındaki veriyi API formatına otomatik olarak dönüştürür.

Örneğin:
```
ProductEntity -> Product (API) -> MapStruct -> ProductDTO
```

Bu sayede, 20 satır kod yazmak yerine, 1 satırla mapping yapılmış olur."

---

## [12:30 - Reactive Programming (Spring WebFlux)]

**[Camera: productService Application ve ilgili servis dosyaları gösteriliyor]**

**Host:** "Şimdi en önemli kısımlardan birine geliyoruz: Reactive Programming.

Spring WebFlux kullanarak reactive bir yapı kuruyoruz. Klasik bir yaklaşım ile reactive yaklaşım arasındaki farkı anlatayım:

**Klasik (Blocking) Yaklaşım:**
- Uygulama veritabanına istek gönderir
- Veri gelene kadar bekler
- Bu sırada hiçbir şey yapamaz
- Sonuç: Sadece bir kullanıcıyla çalışabilir

**Reactive (Non-blocking) Yaklaşım:**
- Veritabanına istek gönderilir
- 'Veri gelince haber ver' denir
- Uygulama başka işlerle uğraşabilir
- Sonuç: Binlerce kullanıcı aynı anda desteklenebilir

**Reactive Types:**
- **Mono:** Tek bir veriyi temsil eder (örneğin bir ürün)
- **Flux:** Birden fazla veriyi temsil eder (örneğin ürün listesi)

Bu sayede, servisimiz hem hızlı hem de yüksek performanslı oluyor."

---

## [14:00 - Polyglot Persistence - Veritabanı Seçimi]

**[Camera: Üç servisin veritabanı yapıları yan yana gösteriliyor]**

**Host:** "Şimdi veritabanı seçimlerini görelim. Neden bazı servisler MongoDB kullanıyor, bazıları MySQL kullanıyor?

**Product Servisi - MongoDB:**
- Ürün verisi esnektir
- Zamanla değişen alanlar olabilir
- MongoDB belgeler halinde veri tutar - daha esnektir
- 'Document database' yapısı bu senaryolara çok uygun

**Review Servisi - MySQL:**
- İnce yapılandırılmış veridir
- Kullanıcı ID, ürün ID ve yıldız ratingi gibi sabit alanlar vardır
- MySQL, bu tür yapılandırılmış veriler için mükemmeldir
- Geleneksel tablo yapısı tam uyumludur

**Recommendation Servisi - MongoDB:**
- Öneri verisi bazen karmaşık ve değişken olabilir
- MongoDB bu senaryolarda esneklik sağlar

**Neden bu yapıya 'Polyglot Persistence' diyoruz?**
Farklı problemler için farklı çözümler kullanmak. Her veritabanının kendine özgü güçlü yönleri vardır. Doğru aracı doğru iş için kullanmak en iyi sonucu verir."

---

## [16:00 - İnceleme ve Öneri Servisleri]

**[Camera: review-service ve recommendation-service klasörleri gösteriliyor]**

**Host:** "Sistemimizin sadece ürün bilgilendirme yetmemeli. İncelemeler ve öneriler de gerekiyor.

**Review Servisi:**
- Kullanıcıların ürün hakkında yazdığı incelemeleri yönetir
- MySQL kullanır
- Her inceleme şunları içerir: kullanıcı ID, ürün ID, yıldız ratingi, yorum metni

**Recommendation Servisi:**
- Benzer ürün önerileri sunar
- MongoDB kullanır
- Ürün bazlı önerileri saklar

**Her iki servis de aynı pattern'i kullanır:**
1. Data model'i tanımlanır
2. MapStruct ile mapping yapılır
3. Reactive types (Mono ve Flux) kullanılır

Şimdi üç ayrı servise sahibiz. Bunlar farklı odalardaki farklı insanlar gibidir - şu ana kadar birbirleriyle konuşmadılar. Halletmeye çalışalım."

---

## [18:00 - The Orchestrator (Ürün Composite Servisi)]

**[Camera: product-composite-service klasörü açılıyor]**

**Host:** "Şimdi product-composite-service'e geçiyoruz.

Kullanıcı ürün sayfasını görmek istediğinde: ürün bilgileri, incelemeler ve önerilere ihtiyacı var. Kullanıcının üç ayrı servise istek göndermesi yerine, bir 'Composite' servisi oluşturuyoruz. Bu servisin görevi, tüm servisleri çağırıp veriyi bir araya getirmek.

**Circuit Breaker - Resilience4j:**
Peki Review servisi çökünse ne olacak? Tüm sayfanın çökmesini istemeyiz. İşte bu noktada Resilience4j devreye girer.

Circuit Breaker'ı elektrik pano gibi düşünün. Bir odada kısa devre olursa, pano o odaya olan elektriği keser ama evin geri kalanı çalışmaya devam eder. Kodda da aynı şey olur:

**Normal Durum:**
- Composite servisi Product, Review, Recommendation servislerini çağırır
- Tüm veriyi toplayıp kullanıcıya gönderir

**Review servisi çökerse:**
- Circuit Breaker 'atlar'
- Composite servisi 'Şu an incelemeleri alamıyorum ama ürün bilgilerini görebilirsiniz' der
- Sistem 'resilient' yani kısmi arızalara karşı dayanıklı olur

Bu sayede sistem, bir servisin çökmesine rağmen temel işlevlerini sürdürebilir."

---

## [20:30 - Front Kapı (Gateway ve Güvenlik)]

**[Camera: gateway klasörü gösteriliyor]**

**Host:** "Servislerimiz çalışıyor ama şu anda internete açık durumdalar. Bu tehlikeli. Bir kapı girişi gerekiyor.

**Gateway:**
spring-cloud klasöründe bir Gateway oluşturuyoruz. Gateway, sisteme tek giriş noktasıdır. Kullanıcı bir ürün istediğinde Gateway'e başvurur ve Gateway doğru servise yönlendirir. Bu sayede:
- İç servisler gizli ve güvenli kalır
- Tüm istekler merkezi olarak yönetilir

**Authorization Server:**
Ama kullanıcı kim? Bu noktada OAuth2 ve OIDC kullanıyoruz. Her servis şifre sormak yerine, kullanıcı bir kez oturum açıyor. Authorization Server onlara bir 'Token' veriyor - bir dijital VIP kart gibi.

Kullanıcı bu kartı Gateway'e gösteriyor ve Gateway içerideki servislere izin veriyor.

**TLS (Transport Layer Security):**
Daha da güvenliği artırmak için TLS kullanıyoruz. Bu, kullanıcı ile Gateway arasındaki verilerin şifrelenmesini sağlar. Böylece hackerlar veriyi çalamaz. 8443 portunda HTTPS kullandığımızı göreceksiniz.

Artık güvenli ve yönetilen bir giriş noktasına sahibiz."

---

## [22:30 - Merkezi Konfigürasyon ve Mesajlaşma]

**[Camera: config-repo klasörü ve message processor yapıları gösteriliyor]**

**Host:** "Neredeyse bitti, ama profesyonel dokunuşlardan iki tanesi daha kaldı.

**Birinci: Merkezi Konfigürasyon:**
Şu anda, veritabanı şifresini değiştirmek istediğinizde, her serviste değiştirmeniz ve hepsini yeniden başlatmanız gerekir. Kâbus gibi!

config-repo klasöründe tüm .yml konfigürasyon dosyaları saklanır. Servisler başladıklarında Config Server'a bağlanıp ayarlarını çekerler. Dosyayı değiştirdiğinizde, servisler yeniden başlamadan güncellenir!

**İkinci: Olay-Bazlı Mesajlaşma:**
Bazen servislerin cevap beklemesi gerekmez. Örneğin, ürün fiyatı değiştiğinde Recommendation servisinin haberdar olması gerekir.

Product servisi doğrudan Recommendation servisine çağırmak yerine, bir 'Mesaj' gönderir. Broker kullanabiliriz - RabbitMQ veya Kafka.

Product servisi brokere bağırır: 'X ürün değişti!'
Recommendation servisi dinler ve 'Dinledim, kayıtlarımı güncelleyeceğim' der.

Bu 'Asenkron İletişim' sistemi inanılmaz hızlı yapar çünkü servisler birbirlerini beklemek zorunda değildir."

---

## [24:30 - Docker Compose ile Birleştirme]

**[Camera: docker-compose.yml dosyası gösteriliyor]**

**Host:** "Birçok hareketli parçamız var: dört servis, bir gateway, bir auth server, MongoDB, MySQL ve RabbitMQ. Bunları tek tek başlatmak sonsuz zaman alır.

Bu noktada Docker Compose kullanıyoruz.

**docker-compose.yml dosyası bir tarif gibidir. Şunu söyler:**
- Bir MongoDB container'ı başlat
- Bir MySQL container'ı başlat
- Tüm Java servislerini başlat

.env dosyası da şifreleri ve kullanıcı adlarını güvenli bir şekilde saklar - bunları script içinde hardcoded olarak tutmak yerine.

Şimdi sihirli an. docker compose up -d --build komutunu çalıştırıyorum.

Docker imajları oluşturacak, veritabanlarını başlatacak, ağı birbirine bağlayacak ve servisleri başlatacak.

Eğer loglarda 'Started ProductService in 3 seconds' görüyorsanız, işe yarıyor demektir!"

---

## [26:30 - Final Demo ve Testler]

**[Camera: Tarayıcı açılıyor, uygulama test ediliyor]**

**Host:** "Şimdi test edelim.

Tarayıcımda Gateway URL'ini açıyorum. Authorization Server üzerinden giriş yapıyorum, token'ımı alıyorum ve bir ürün sayfası istiyorum.

İşte görüyorsunuz! Composite servisi Product, Review ve Recommendation servislerinden veriyi topladı ve her şey mükemmel şekilde görünüyor.

**İlginç Test:** Review servisini manuel olarak durdurup sayfayı yenilersem... Bakın? Sayfa hala yükleniyor! Circuit Breaker devreye girdi, incelemeler gelmese bile ürün bilgilerini görebiliyoruz."

---

## [28:30 - Sonuç ve Özet]

**[Camera: Host ekrana geri dönüyor]**

**Host:** "Bugün size tam kapsamlı bir microservices mimarisini anlattık. Bu videoda neler gördük?

- API modülü ve util modülü yapılandırması
- Farklı microservices yapılandırması
- Spring WebFlux ve reactive programlama
- Circuit Breaker pattern
- Gateway ve OAuth2 Authorization Server
- Docker Compose ile deploy

Bu mimari, gerçek dünya uygulamalarınızı oluşturmak için sağlam bir temel sağlar. Her bileşen, sistemimize belirli bir değer ekler ve birlikte çalıştıklarında güçlü, ölçeklenebilir bir sistem oluştururlar.

Sormak istediğiniz bir soru varsa yorumlarda paylaşabilirsiniz. Bir sonraki videoda görüşmek üzere!"

**[Ekran kaydı bitiyor, outro müziği başlıyor]**

---

## Ek Bilgiler

### Kullanılan Teknolojiler:
- **Spring Boot 3.4.2**: Ana framework
- **Spring WebFlux**: Reactive programlama
- **MapStruct**: DTO mapping
- **Resilience4j**: Circuit breaker pattern
- **MongoDB**: NoSQL veritabanı
- **MySQL**: İlişkisel veritabanı
- **OAuth2/OIDC**: Kimlik doğrulama
- **Docker Compose**: Container yönetimi
- **Kafka**: Olay mesajlaşması (opsiyonel)

### Proje Özellikleri:
- Reactive ve non-blocking mimari
- Circuit breaker pattern ile resilience
- Polyglot persistence (MongoDB + MySQL)
- Merkezi konfigürasyon yönetimi
- Mikroservice'ler arası asenkron iletişim
- TLS şifreleme ile güvenlik
- API gateway ile merkezi erişim kontrolü

---

**Kaynak Kod:** https://github.com/ademozdeme/spring-microservices-mongo-mysql

**Son Güncelleme:** 2025
