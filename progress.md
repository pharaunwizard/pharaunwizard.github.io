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
