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
