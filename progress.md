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
