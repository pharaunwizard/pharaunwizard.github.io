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
