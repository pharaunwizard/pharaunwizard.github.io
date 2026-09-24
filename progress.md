# Progress Log

## TASK-001 — Инициализация Blazor WebAssembly (.NET 10) — done

- Инициализирован git-репозиторий, сделан первый коммит.
- Создан проект `MarsCV` (Blazor WebAssembly standalone) через `dotnet new blazorwasm`.
- TargetFramework: `net10.0` (.NET 10 LTS), синтаксис C# 14.
- Добавлен `.gitignore` для .NET.
- Проверка: `dotnet build` — успешно, 0 предупреждений/ошибок.
- Проверка: `dotnet run --urls http://localhost:5199` — dev-сервер отвечает HTTP 200, в HTML присутствует загрузчик Blazor.

## TASK-002 — Структура папок проекта — done

Созданы каталоги:
- `Components/Sections` — секции страницы (Hero, About, Experience, Projects, Contacts).
- `Components/Experience` — компоненты таймлайна.
- `Components/Projects` — карточки проектов.
- `Models` — C#-модели данных.
- `Services` — сервисы (ContentService).
- `wwwroot/content` — JSON-контент.
- `wwwroot/img` — изображения.

Соответствует PRD §5.5.

## TASK-003 — Статический index.html — done

- `<html lang="ru">`.
- `<title>` и `meta description` с осмысленным текстом владельца.
- `meta viewport` для мобильных (`width=device-width, initial-scale=1.0, viewport-fit=cover`).

## TASK-004 — OpenGraph и Twitter Card — done

- Добавлены `og:type`, `og:site_name`, `og:title`, `og:description`, `og:image`, `og:image:width/height/alt`, `og:url`, `og:locale`.
- Добавлены `twitter:card` (`summary_large_image`), `twitter:title`, `twitter:description`, `twitter:image`.
- Сгенерировано изображение-превью `wwwroot/img/og-preview.png` размером ровно 1200×630.
- `og:url`/`og:image` указывают на публичный домен-плейсхолдер (уточняется на TASK-006/036).

## TASK-007 — C#-модели данных — done

Созданы модели (`MarsCV.Models`):
- `Profile`: Name, Role, Offer, PhotoUrl, About, Contacts.
- `ContactLink`: Type, Label, Url, Icon.
- `ExperienceItem`: Id, Company, Role, StartDate, EndDate, Location, Summary, Details, Achievements, Technologies.
- `Project`: Id, Title, Description, Technologies, RepoUrl, DemoUrl, ImageUrl.

Соответствует PRD §5.1–5.3. `dotnet build` — 0 ошибок.

## TASK-008 — ContentService + DI — done

- `Services/ContentService.cs`: загрузка `content/profile.json`, `content/experience.json`, `content/projects.json` через `HttpClient.GetFromJsonAsync`.
- Результаты кэшируются через поля `Task<...>` — повторные обращения к одним файлам не выполняются.
- Ошибки чтения/десериализации обрабатываются: возвращается `null` / пустой список (основа пустых состояний).
- Зарегистрирован в DI (`Program.cs`: `AddScoped<ContentService>()`).
- Проверка: сборка без ошибок; десериализация JSON в реальные модели подтверждена отдельным тестовым прогоном (см. ниже).

## TASK-009 — profile.json — done

- `wwwroot/content/profile.json`: name, role, offer, photoUrl, about (3 абзаца), contacts (telegram, hh, email).
- Валиден по схеме §5.1; десериализуется в `Profile`.

## TASK-010 — experience.json — done

- `wwwroot/content/experience.json`: 3 записи с разными периодами (2023, 2020, 2017).
- У всех заполнены summary, details, achievements, technologies.
- Валиден по схеме §5.2; десериализуется в `List<ExperienceItem>`.

## TASK-011 — projects.json — done

- `wwwroot/content/projects.json`: 4 проекта; заполнены title, description, technologies; часть repoUrl/demoUrl равна null.
- Валиден по схеме §5.3; десериализуется в `List<Project>`.

### Верификация контентного слоя (TASK-008–011)

Временный console-проект с линковкой реальных `Models/*.cs` и `System.Text.Json` (Web-настройки) успешно:
- десериализовал `profile.json` → 3 контакта, 3 абзаца about;
- `experience.json` → 3 записи;
- `projects.json` → 4 проекта.
Вывод: `DESERIALIZATION OK`. Плейсхолдер-фото: `wwwroot/img/profile.png`.

## TASK-012 — Главная страница из секций — done

- Созданы Razor-компоненты секций: `HeroSection`, `AboutSection`, `ExperienceSection`, `ProjectsSection`, `ContactSection` (`Components/Sections`).
- `Pages/Home.razor` собирает их в порядке Hero → About → Experience → Projects → Contacts (PRD §3.1).
- `Layout/MainLayout.razor` упрощён до вывода `@Body` (убрана шаблонная боковая навигация под одностраничник).
- Все секции получают данные через `ContentService`.
- Проверка: сборка без ошибок; headless-браузер (Chrome `--dump-dom`) подтвердил наличие всех пяти секций в правильном порядке с реальным контентом.

## TASK-021 — Mars-тема (CSS-переменные) — done

- `wwwroot/css/app.css` переписан: CSS-переменные палитры (фон «марсианская ночь», ржаво-оранжевые акценты, песочный доп. акцент, тёплый текст), шкала отступов (`--space-*`, `--section-pad-y`), масштаб типографики (`--fs-*`), радиусы, тени, транзишены.
- Глобальные стили: body-фон с марсианскими radial-градиентами, `.container`, `.section`, `.section__title`, `.btn--accent`, `.skeleton`, `.empty-state`, `.tech-list`, фокус-индикаторы.
- Перекрашен Blazor-загрузчик и `#blazor-error-ui`; добавлен базовый `prefers-reduced-motion` (развит в TASK-029).
- Убрана зависимость от Bootstrap CSS в `index.html` (кастомный CSS по PRD).
- Проверка: сборка без ошибок; скриншот headless-Chrome подтверждает единый марсианский стиль (тёмно-коричневый фон, ржаво-оранжевые акценты).

## TASK-013 — Таймлайн опыта (аккордеон) — done

- Созданы `ExperienceTimeline.razor` и `ExperienceItemCard.razor` (`Components/Experience`).
- Сортировка записей по `StartDate` по убыванию (свежие сверху).
- Аккордеон: в состоянии хранится единственный `openId`; открытие другой карточки закрывает предыдущую.
- Самая свежая запись раскрыта по умолчанию (первая после сортировки).
- Раскрытая карточка показывает `details`, `achievements` и `technologies`.
- Проверка (headless-Chrome DOM): ровно 1 карточка `exp-card--open`, 1 `exp-card--latest`, `aria-expanded="true"` ×1 и `"false"` ×2, «наст. время», «Достижения», «Технологии» присутствуют.

## TASK-022 — Hero (первый экран) — done

- CSS Hero: двухколоночная сетка (фото + контент) на десктопе, одноколоночная по центру ≤720px; `min-height: 100svh`; фото из `profile.json` с рамкой/тенью.
- Скролл-хинт «Полный опыт ниже» с анимированной стрелкой (`hero-bounce`, отключается reduced-motion).
- Добавлено глобальное `img { max-width: 100%; height: auto; }`.
- Проверка через Chrome DevTools Protocol (эмуляция 360×800): `scrollWidth = innerWidth = 360`, переполнений нет; скриншот подтверждает корректную одноколоночную вёрстку.
- Инструменты верификации: `serve-start.ps1`, `serve-stop.ps1`, `cdp.ps1` (эмуляция устройства + `Runtime.evaluate` + `Page.captureScreenshot`).

## TASK-023 — Блок «Обо мне» — done

- Оформлен блок: фон `--color-bg-soft` с разделителями, ограничение длины строки (`max-width: 72ch`), первый абзац-лид крупнее.
- Отображаются 3 абзаца из `profile.json` (`about`).
- Проверка (эмуляция 360×800): 3 абзаца, `scrollWidth = innerWidth = 360` — горизонтального скролла нет.

## TASK-024 — Оформление таймлайна — done

- Вертикальная линия с градиентом от акцента (сверху, свежие места) к прозрачному; маркеры-точки вынесены на линию (позиционированы абсолютно относительно карточки).
- Свежая запись акцентирована: акцентная рамка, светящийся маркер (`box-shadow`), бейдж «Текущее».
- Заголовок карточки переведён на `flex` с `flex-wrap` — корректно перестраивается на узких экранах; раскрытая карточка читаема (details/achievements/technologies).
- Проверка (эмуляция 1200): 1 открытая и 1 акцентная карточка, нет переполнения; скриншот подтверждает целостный стиль таймлайна.

## TASK-032 — Доступность таймлайна — done

- Заголовок карточки — нативный `<button>` (Enter/Space активируют по умолчанию), с `aria-expanded` и `aria-controls`.
- Раскрываемая панель: `role="region"`, `aria-labelledby` (ссылка на название компании), `aria-hidden` при закрытии.
- Видимый фокус-индикатор через глобальный `:focus-visible`.
- Проверка через CDP (trusted input): фокус на 2-й карточке + `Enter` → открылась «Orbit Retail», `aria-expanded=[false,true,false]`; фокус на 3-й + `Space` → открылась «Vector Soft», `aria-expanded=[false,false,true]`. Логика клика подтверждена отдельно.

## TASK-005 — Публикация портативной статики — done

- `dotnet publish -c Release` завершается успешно → `bin/Release/net10.0/publish/wwwroot`.
- В папке публикации: `index.html` (+`.br`/`.gz`), `_framework`, `content`, `css`, `img`; всего 43 `.br`-файла.
- Публикуемый `index.html` содержит статические OG-теги.
- Проверка: локальный статический сервер (Node, `static-server.js`) отдаёт сборку: `index.html` → 200, `_framework/blazor.webassembly*.js` → 200 (`text/javascript`), CDP-рендер подтверждает 5 секций, 3 карточки опыта, 4 проекта — не хуже dev-режима.
- Замечание: publish сообщает «Publishing without optimizations» (нет workload `wasm-tools`) — обрабатывается в TASK-034.

## TASK-006 — Хостинг и CI — BLOCKED (pending)

- Подготовлена инфраструктура деплоя (можно разворачивать сразу после получения доступа):
  - `wwwroot/staticwebapp.config.json` — SPA-fallback, MIME для `.wasm/.webp/.avif`, security-заголовки.
  - `wwwroot/_redirects` — SPA-fallback для Cloudflare Pages / Netlify.
  - `.github/workflows/deploy.yml` — сборка `dotnet publish -c Release` + артефакт `wwwroot`; шаг деплоя в Azure Static Web Apps (по секрету `AZURE_STATIC_WEB_APPS_API_TOKEN`) и инструкции по фоллбэкам (Cloudflare Pages, Yandex Object Storage).
- **Блокер:** фактический деплой и публичный URL невозможны без одобрения заявки Azure SWA либо учётных данных провайдера. Статус оставлен `pending` до появления доступа.

## TASK-014 — Секция пет-проектов — done

- Создан `ProjectCard.razor`; `ProjectsSection.razor` рендерит сетку из `ProjectCard` по данным `projects.json`.
- Карточка: изображение (если есть), название, описание, технологии, ссылки «Репозиторий»/«Демо».
- Ссылки рендерятся только при наличии URL, открываются в новой вкладке с `rel="noopener noreferrer"`; проект без ссылок (JsonConfig) отображается корректно.
- Добавлен адаптивный grid `.projects__grid` (`repeat(auto-fill, minmax(280px, 1fr))`).
- Проверка (CDP): 4 карточки, заголовки совпадают с `projects.json`, все 4 ссылки имеют `target=_blank` и `rel=noopener noreferrer`.

## TASK-015 — Секция контактов — done

- `ContactSection` выводит контакты из `profile.json`: Telegram (`https://t.me/...`), hh (`https://hh.ru/...`), email (`mailto:`).
- Каждому контакту присвоен класс типа (`contact--telegram|hh|email`) и `data-type` — типы различаются.
- Telegram/hh открываются в новой вкладке с `rel="noopener noreferrer"`; email — `mailto:` без `target`.
- Добавлены базовые стили списка/кнопок контактов (иконки и hover — в TASK-026).
- Проверка (CDP): 3 контакта, корректные href, `target`/`rel` только у внешних ссылок.

## TASK-016 — CTA на hh.ru в Hero — done

- В Hero добавлена акцентная кнопка «Смотреть резюме на hh.ru» (URL берётся из `profile.json`, контакт типа `hh`), `target="_blank"` + `rel="noopener noreferrer"`.
- Скорректирована мобильная типографика Hero: на ≤720px фото уменьшено до круглого аватара 168×168, уменьшены отступы — весь первый экран помещается.
- Проверка (CDP): при 360×640, 360×700 и 1200×900 кнопка hh полностью в пределах первого экрана (`aboveFold=true`), горизонтального скролла нет.

## TASK-017 — Связывание ContentService с секциями — done

- Все секции получают данные через `ContentService`; кэширование `Task`-полей гарантирует отсутствие дублирующих запросов.
- Проверка (CDP, `performance.getEntriesByType('resource')`): при загрузке страницы запрошены ровно `profile.json`, `projects.json`, `experience.json` — по одному разу каждый, несмотря на 5 секций.
- Пустые состояния: `AboutSection`, `ExperienceTimeline`, `ProjectsSection`, `ContactSection` показывают аккуратное `.empty-state`.
- Проверка на пустых данных: временно `projects.json = []` → секция проектов показывает пустое состояние, приложение не падает, остальные секции (3 карточки опыта) работают; файл восстановлен.

## TASK-018 — Защита email от спам-ботов — done

- Email в HTML/DOM не хранится: для контакта типа `email` рендерится `<button>` без `href`; адрес собирается только в момент клика.
- Добавлен `wwwroot/js/app.js` с `marsCv.openMailto(local, domain)` → `window.location.href = 'mailto:' + local + '@' + domain`; вызывается через JS-interop.
- Telegram/hh остались обычными `<a>` и не затронуты.
- Проверка (CDP): статический `index.html` не содержит `ivan.marsov@example.com`/`mailto:`; живой DOM также не содержит адрес; клик по кнопке email вызывает `openMailto` с `ivan.marsov@example.com`.
- Примечание: адрес остаётся в `profile.json` (данные, не HTML) — согласно схеме §5.1 (`mailto:`).

## TASK-019 — CSP и харденинг внешних ссылок — done

- В `index.html` добавлена meta CSP: `default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self'; base-uri 'self'; form-action 'self'; object-src 'none'`.
- Чтобы строгий `script-src` не давал ошибок из-за inline-скриптов Blazor, отключён фингерпринтинг (`OverrideHtmlAssetPlaceholders=false`), удалён inline importmap и пустой `<link rel="preload" id="webassembly">`; загрузчик подключён как `_framework/blazor.webassembly.js`.
- Внешние ссылки (Hero hh, контакты Telegram/hh, ссылки проектов) — с `target="_blank"` и `rel="noopener noreferrer"`.
- Проверка (CDP, dev и published): приложение рендерит 5 секций, `CONSOLE_ENTRIES: 0` (нет CSP-ошибок); в опубликованном `index.html` 0 inline-скриптов; все 7 внешних ссылок `allSafe=true`.

## TASK-025 — Адаптивная сетка пет-проектов — done

- Сетка `.projects__grid`: `repeat(auto-fill, minmax(280px, 1fr))`; карточки содержат название, описание, технологии, ссылки; стиль согласован с темой (фон, рамки, hover-подъём).
- Проверка (CDP, число колонок по `gridTemplateColumns`): 360px → 1, 768px → 2, 1024px → 3, 1440px → 3; горизонтального скролла нет.

## TASK-026 — Оформление контактов с иконками — done

- Добавлен `ContactIcon.razor` с inline-SVG для типов `telegram`, `hh`, `email` (+ fallback), цвет — акцентный, при hover — ярче.
- Композиция контактов адаптивна: на ≤520px список становится колонкой, кнопки на всю ширину.
- Проверка (CDP): 3 SVG-иконки (по одной на каждый тип контакта), на 360px переполнения нет.

## TASK-027 — MarsBackground (пыль/атмосфера) — done

- Создан `Components/MarsBackground.razor`, подключён в `Home.razor`.
- Слой: fixed, `z-index: -1`, `pointer-events: none`, `aria-hidden` — не перекрывает контент и не ловит клики.
- Атмосфера: радиальные свечения + 14 частиц пыли на чистом CSS (`transform`/`opacity`, `@keyframes dust-drift`), без библиотек и Canvas.
- Проверка (CDP): 14 частиц, `z-index=-1`, `pointer-events=none`, консоль чистая; скриншот подтверждает, что контент читаем поверх фона.

## TASK-028 — Анимации появления при скролле — done

- `wwwroot/js/app.js`: `marsCv.initReveal()` через `IntersectionObserver` помечает `.section:not(.hero)` классом `reveal` и снимает по попаданию в viewport (`is-visible`), после чего `unobserve`.
- `Components/ScrollReveal.razor` вызывает инициализацию после первого рендера (JS-interop с обработкой отключения).
- CSS: `.reveal` использует только `opacity` + `translateY` и `transition`; при отсутствии JS/reduced-motion контент виден (класс вешает JS).
- Проверка (CDP): до скролла 4 секции `.reveal`, 0 видимых; после прокрутки вниз — 4 `is-visible` из 5 секций (hero исключён), консоль чистая.

## TASK-029 — prefers-reduced-motion — done

- Глобальный блок `@media (prefers-reduced-motion: reduce)`: отключены все `animation`/`transition`, `scroll-behavior: auto`.
- Дополнительно: `.hero__scroll-arrow` — `animation: none`; `.mars-bg__particle` — `display: none` (фон без движения); `.reveal` принудительно видим.
- `marsCv.initReveal()` при reduce-motion не добавляет класс `reveal` вовсе (контент сразу читаем).
- Проверка (CDP с `Emulation.setEmulatedMedia` reduce): `revealCount=0`, частицы `display:none`, анимация стрелки `none`, opacity секции `1`.

## TASK-030 — Адаптивность 360/768/1024/1440 — done

- Проверка (CDP, эмуляция ширин): при 360/768/1024/1440 `scrollWidth == innerWidth`, документ не имеет горизонтального переполнения.
- Единственный выходящий за viewport элемент — `.mars-bg__glow` (декоративный слой внутри `.mars-bg` с `overflow:hidden`) — на overflow страницы не влияет.
- CTA hh видна на всех ширинах; карточки проектов перестраиваются (1/2/3 колонки), таймлайн и контакты адаптируются.

## TASK-031 — Оптимизация изображений — done

- Портретное фото сконвертировано в WebP (ffmpeg/libwebp, quality 80): `img/profile.png` (13.5 КБ) → `img/profile.webp` (5.8 КБ, 640×800); PNG удалён, `profile.json.photoUrl` обновлён на `/img/profile.webp`.
- Hero-изображение: `decoding="async"`, `fetchpriority="high"` (LCP), вес 5.8 КБ ≪ 150 КБ.
- Изображения проектов используют `loading="lazy" decoding="async"`.
- Проверка (CDP): `profile.webp` загружен (640×800, `complete && naturalWidth>0`), единственный запрошенный образ — `profile.webp`, консоль чистая.

## TASK-033 — Общая доступность — done

- Семантика: `lang="ru"`; один `h1` (имя в Hero), по `h2` в секциях About/Experience/Projects/Contacts; каждая секция связана с заголовком через `aria-labelledby`.
- Изображения: у hero-фото осмысленный `alt` («Фото — Иван Марсов»); изображения проектов имеют `alt` (при наличии).
- Контраст (WCAG AA, расчёт): text/bg 15.88, muted/bg 8.65, muted/surface 7.96, dim/surface 4.84, accent/bg 5.6, sand/bg 11.19, кнопка 5.53 — все ≥ 4.5:1.
- Фокус: глобальный `:focus-visible` (3px контур) на интерактивных элементах (кнопки таймлайна, ссылки, контакты).
- Проверка (CDP DOM-аудит): `h1Count=1`, `h2Count=4`, `alt` заполнен, `aria-labelledby` корректен.

## TASK-034 — Производительность Blazor WASM — done

- Установлен workload `wasm-tools`: publish выполняет нативную оптимизацию (`wasm-opt -O2`, relinking) и генерирует Brotli+gzip (`.br`/`.gz`).
- В csproj: `PublishTrimmed=true`, `BlazorEnableCompression=true`, `InvariantGlobalization=true` (удалены ICU-данные `icudt*` ~2.5 МБ).
- Удалены неиспользуемые шаблонные ресурсы/страницы (Bootstrap `lib/`, `sample-data/`, Counter/Weather/NavMenu) — размер публикации снижен с 34.4 МБ до 8.8 МБ.
- До гидратации показывается лёгкий скелет Hero (`boot-skeleton`) + тонкий прогресс-бар по `--blazor-load-percentage`; фото-заглушка — inline-SVG `<img>`, поэтому становится ранним LCP-кандидатом.
- Проверка (CDP, эмуляция 390×844, `Network` ~1.6 Мбит/с + `CPU×4`, published + Brotli-сервер):
  - **LCP = 676 мс** (≤ 2.5 с), элемент — скелет-фото;
  - **CLS = 0.064** (≤ 0.1);
  - приложение полностью отрисовано (5 секций), консоль чистая.

## TASK-020 — Проверка отсутствия секретов — done

- Скан репозитория (исключая `bin/obj/.git`) по паттернам `api key`, `secret`, `password`, `token`, `PRIVATE KEY`, `connection string`, `AccountKey`, `client_secret`, `Bearer ...` — реальных секретов нет.
- Единственные совпадения: выражения GitHub Actions `${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}` в `.github/workflows/deploy.yml` (секреты не хранятся в репозитории, а передаются из CI) и текст в документации.
- Итог: API-ключей, токенов и паролей в коде/конфигах нет.

## TASK-035 — Финальная сквозная проверка — done

Проверка опубликованной сборки (Brotli-сервер, эмуляция 1200×900, CDP):
- Порядок секций: `hero → about → experience → projects → contacts` (PRD §3.1).
- Контент: 3 записи опыта, 4 проекта, 3 контакта, 3 абзаца «Обо мне».
- Внешние ссылки: 7 шт., все `linksSafe=true` (`target=_blank`, `rel="noopener noreferrer"`).
- Интерактив: клик по 2-й карточке опыта → открыта «Orbit Retail», ровно 1 открытая карточка; scroll-reveal → 4 секции `is-visible`.
- Консоль: `CONSOLE_ENTRIES: 0`.

## TASK-036 — Превью ссылки в Telegram/hh — BLOCKED (pending)

- Требуется публичный URL (зависит от TASK-006), которого пока нет из-за отсутствия одобрения хостинга/доступа.
- OG/Twitter-теги и изображение 1200×630 готовы (TASK-004) и присутствуют в статическом `index.html`; после деплоя останется только проверить разворот ссылки. Статус оставлен `pending`.

## TASK-037 — Файл решения .slnx — done

- Создан `MarsCV.slnx` (`dotnet new sln`, формат slnx), в него добавлен `MarsCV.csproj`.
- Проверка: `dotnet build MarsCV.slnx` — успешно, 0 ошибок/предупреждений. Формат `.slnx` открывается Visual Studio.

## TASK-038 — Наложение кнопки hh и скролл-хинта на десктопе — done

- Причина: CTA и подсказка были inline-flex соседями и вставали в одну строку вплотную.
- Исправление: оба элемента обёрнуты в `.hero__actions` (`display:flex; flex-direction:column; align-items:flex-start; gap: var(--space-5)`); на ≤720px `align-items:center`.
- Проверка (CDP, bounding boxes): при 1024/1440/360 `intersect=false`, отступ между элементами 24px, горизонтального переполнения нет.

## TASK-041 — Модель SkillGroup и skills.json — done

- Создана модель `Models/SkillGroup.cs`: `Id`, `Title`, `Description`, `Items` (List<string>).
- Создан `wwwroot/content/skills.json` — 4 группы (Backend / .NET, Android, AI / ML, DevOps / Tooling); включая Android и AI.
- Проверка: `dotnet build` без ошибок; JSON валиден; десериализация в `List<SkillGroup>` подтверждена тестовым прогоном (4 группы, наполнены Items).

## TASK-042 — ContentService загружает skills.json — done

- Добавлено поле `_skillsTask` и метод `GetSkillsAsync()` (кэширование по тому же паттерну `??=`), загрузка `content/skills.json` в `List<SkillGroup>`.
- Проверка (CDP, `performance.getEntriesByType('resource')`): среди `/content/*` запрошены `profile.json`, `skills.json`, `projects.json`, `experience.json` — `skills.json` ровно один раз.

## TASK-043 — SkillsSection — done

- Создан `Components/Sections/SkillsSection.razor`: рендерит группы из `skills.json` (Title, Description, список Items), получает данные через `ContentService`.
- Пустое состояние: `.empty-state` при отсутствии групп.
- Проверка (CDP): 4 группы, у каждой заголовок/описание/навыки; при временном `skills.json = []` — аккуратное пустое состояние, приложение не падает.

## TASK-044 — Skills между Experience и Projects — done

- `SkillsSection` вставлен в `Home.razor` между `ExperienceSection` и `ProjectsSection`.
- Проверка (CDP): порядок секций `hero → about → experience → skills → projects → contacts`.

## TASK-045 — Оформление и адаптивность Skills — done

- Стили `.skills__grid` / `.skill-group` (карточки с заголовком-акцентом, описанием и чипами навыков), в едином Mars-стиле, hover-подъём.
- Проверка (CDP, `gridTemplateColumns`): 360→1, 768→2, 1024→3, 1440→3; горизонтального скролла нет.

## TASK-039 — Хинт «Подробнее» — done

- Текст скролл-хинта в Hero заменён на «Подробнее»; анимация стрелки и позиционирование сохранены.
- Проверка (CDP): текст = «Подробнее», старого текста в DOM нет, стрелка на месте.

## TASK-040 — Заголовок «Pet-проекты» — done

- Заголовок секции проектов изменён на «Pet-проекты».
- Проверка (CDP): заголовок = «Pet-проекты», старого варианта в DOM нет, 4 карточки проектов на месте.

## TASK-046 — Обновление PRD.md — done

- §3.1: порядок секций теперь `Hero → Обо мне → Таймлайн опыта → Навыки → Pet-проекты → Контакты`.
- §3.2: хинт «Подробнее»; §3.5 переименована в «Pet-проекты».
- §5.4: добавлена модель `skills.json` (`SkillGroup`); §5.5 — диаграмма с `SKILLGROUP`; §5.6 — сопоставление `SkillGroup → SkillsSection.razor`.
- §6.4 wireframe: добавлен блок «Навыки», исправлены «Подробнее» и «Pet-проекты»; milestone M4 обновлён.
- Проверка: в `PRD.md` отсутствуют устаревшие «Пет-проекты» и «Полный опыт ниже»; порядок и раздел данных соответствуют реализации.

## TASK-047 — Регресс-проверка — done

Проверка (CDP) на dev и на опубликованной сборке (360/1024/1440):
- Порядок секций: `hero → about → experience → skills → projects → contacts`.
- Hero: кнопка hh и скролл-хинт не пересекаются (`heroIntersect=false`); хинт = «Подробнее».
- Заголовок проектов = «Pet-проекты».
- Контент: 4 группы навыков, 3 карточки опыта (1 раскрыта), 4 проекта, 3 контакта.
- Нет горизонтального переполнения; `CONSOLE_ENTRIES: 0` (регрессий нет).

## TASK-052 — Реальное фото профиля — done

- Исходник `profile-source.png` (1086×1448, 2 МБ) размещён в корне проекта (вне `wwwroot`, в публикацию не попадает).
- Конвертация ffmpeg/libwebp: `scale=640:800:force_original_aspect_ratio=increase,crop=640:800` → `wwwroot/img/profile.webp`.
- Результат: 640×800, **41 КБ** (≤150 КБ). `profile.json.photoUrl` = `/img/profile.webp` — не менялся.
- Проверка: `ffprobe` подтверждает 640×800; файл на месте в `wwwroot/img`.

## TASK-048 — Hero: кнопка hh и «Подробнее» в одну строку — done

- Отменён ошибочный `flex-direction: column` (из TASK-038): `.hero__actions` снова `row`, `align-items: center`, `gap: var(--space-4)`; на ≤720px `gap: var(--space-3)` и уменьшенный padding кнопки.
- Проверка (CDP, bounding boxes): при 1024/1440/360 `sameRow=true`, зазор по X = 16px (десктоп) / 12px (мобайл), хинт не под кнопкой, горизонтального скролла нет.

## TASK-050 — Skills как вертикальный аккордеон (в стиле «Опыт») — done

- Удалена grid-раскладка (`.skills__grid`/`.skill-group`); созданы `Components/Skills/SkillsTimeline.razor` и `SkillGroupCard.razor`, `SkillsSection` рендерит таймлайн.
- Карточка группы переиспользует стили таймлайна: вертикальная линия, маркеры-точки, свежая/первая группа акцентирована (бейдж «Основное»), панель раскрывается так же.
- Аккордеон: одновременно раскрыта одна группа, первая раскрыта по умолчанию; свёрнуто — заголовок, раскрыто — описание и теги навыков.
- Доступность как в таймлайне: нативный `<button>`, `aria-expanded`/`aria-controls`, `role="region"`, `aria-labelledby`, управление Enter/Space.
- Проверка (CDP): 4 группы, при загрузке открыта «Backend / .NET»; клик по 2-й → открыта «Android» (одна); фокус + Enter на 3-й → «AI / ML», `aria-expanded=[false,false,true,false]`; ширины 360/768/1024/1440 без переполнения; скриншот подтверждает вид, идентичный секции «Опыт».

## TASK-049 — Ярче фоновое свечение — done

- `.mars-bg__glow`: альфы градиентов `0.16→0.24` и `0.14→0.20` (как предложено).
- Чтобы контраст остался ≥4.5:1 даже в пике свечения, `--color-text-dim` поднят `#a17f6c → #b0907b` (на пике glow: 4.71:1; на базовом фоне выше).
- Слой по-прежнему `z-index:-1`, `pointer-events:none`, без влияния на overflow; reduced-motion не ухудшен.
- Проверка (CDP): computed background-image содержит `rgba(...,0.24)`/`rgba(...,0.2)`, переполнения нет, `CONSOLE_ENTRIES: 0`; скриншот — свечение заметно ярче, текст читаем.

## TASK-051 — Регресс после TASK-048/049/050 — done

Проверка (CDP) на dev и опубликованной сборке (360/1024/1440):
- Hero: кнопка hh и «Подробнее» на одной строке (`heroSameRow=true`), зазор 12px (мобайл) / 16px (десктоп).
- Свечение ярче (`rgba 0.24`), читаемость сохранена.
- Skills: 4 группы, открыта одна, первая — «Backend / .NET», вид как у «Опыта».
- Без регрессий: порядок секций корректен, опыт 3/1, проекты 4, контакты 3; `source` не публикуется; переполнения нет; `CONSOLE_ENTRIES: 0`.

## TASK-053 — Центрирование хинта «Подробнее» по кнопке hh — done

- Хинт переведён из вертикального (текст над стрелкой) в одну строку: `.hero__scroll { flex-direction: row; align-self: center; line-height: 1 }` — текст визуально на уровне центра кнопки.
- Проверка (CDP): при 1024/1440/360 разница центров кнопки и хинта ≤0.01px, центр подписи «Подробнее» отклоняется от центра кнопки на 0.5px (≤1px); раскладка в одну строку, горизонтального скролла нет.

## TASK-054 — Убрать бейдж «Основное» у группы навыков — done

- Удалён бейдж из `SkillGroupCard`; также убран акцент `exp-card--latest` у первой группы (все навыки равнозначны), параметр `IsFirst` удалён.
- Первая группа по-прежнему раскрыта по умолчанию; стиль таймлайна сохранён.
- Проверка (CDP): текст «Основное» в секции Skills отсутствует, `.exp-card__badge`/`.exp-card--latest` = 0, при этом 4 группы и одна открыта («Backend / .NET»), `CONSOLE_ENTRIES: 0`.

## TASK-055 — Регресс после TASK-053/054 — done

Проверка (CDP) на dev и опубликованной сборке (360/1024/1440):
- Hero: центры кнопки hh и хинта совпадают (≤0.01px), подпись «Подробнее» в пределах 0.5px от центра кнопки.
- Skills: бейдж «Основное» отсутствует (0), 4 группы, открыта одна.
- Без регрессий: порядок секций, опыт 3, проекты 4, контакты 3; горизонтального переполнения нет; `CONSOLE_ENTRIES: 0`.
