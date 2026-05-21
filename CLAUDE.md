# CLAUDE.md

Этот файл предоставляет инструкции для Claude Code (claude.ai/code) при работе с данным репозиторием.

## Обзор проекта

Antepli — Flutter ERP-приложение (Anteplioglu ERP) с поддержкой нескольких платформ (Android, iOS, Web, Windows, Linux, macOS). Используется Melos-монорепо с feature-модулями в `modules/`.

## Основные команды

```bash
# Запуск приложения
flutter run

# Генерация кода маршрутизации (после добавления/изменения роутов)
dart run build_runner build --delete-conflicting-outputs

# Запуск тестов
flutter test

# Запуск тестов всех пакетов (через Melos)
melos run test

# Анализ всех пакетов
melos run analyze

# Установка зависимостей всех модулей
melos bootstrap
```

## Настройка окружения

Требуется файл `.env` в корне проекта:
```
BASE_URL=https://api.antepli.itopiatech.com.tr/api/v1/
```

## Архитектура и принципы

### Чистая архитектура (Clean Architecture)

Каждая фича строго делится на слои:

- `data/` — Репозитории, источники данных, модели (DTO с `fromJson`)
- `domain/` — Сущности (Entities), интерфейсы репозиториев, Use Cases
- `logic/` — Cubit/BLoC: управление состоянием, вся бизнес-логика
- `presentation/` — UI-виджеты и страницы, без бизнес-логики

**Вся бизнес-логика — только в BLoC/Cubit, никогда в виджетах.**

### Принципы SOLID

- **Single Responsibility:** Каждый класс и функция выполняет только одну задачу.
- **Dependency Inversion:** Зависеть от абстракций (интерфейсов), а не от конкретных реализаций. Репозитории регистрируются в DI через интерфейсы.

### Структура модулей (монорепо)

`modules/` содержит отдельные Dart-пакеты (управляются Melos):
- `core` — Общие экспорты ядра
- `shared_ui` — Переиспользуемые UI-компоненты
- `shared_utils` — Утилиты
- `module_auth`, `module_admin`, `module_warehouse` (module_depo), `module_production` (module_produksiyon), `module_branch` (module_sube), `module_personnel` (module_personel), `module_customer` (module_musteri)

### Внедрение зависимостей (DI)

GetIt настроен в [lib/core/di/di.dart](lib/core/di/di.dart). Все репозитории, сервисы и роутер регистрируются там. `AuthCubit` — factory (пересоздаётся), остальное — singleton или lazy singleton.

### Маршрутизация

Auto_route. Роуты объявляются в [lib/core/routing/app_router.dart](lib/core/routing/app_router.dart). После добавления нового роута — запустить `build_runner` для регенерации `app_router.gr.dart`.

### HTTP / API

`ApiService` ([lib/core/api_service.dart](lib/core/api_service.dart)) — обёртка над Dio. Автоматически добавляет Bearer-токен, обрабатывает обновление токена (через `Completer` для предотвращения конкурентных запросов), конвертирует `DioException` в `ApiError` с пользовательскими сообщениями — [lib/core/network/api_error.dart](lib/core/network/api_error.dart).

### Аутентификация

`AuthCubit` ([lib/features/auth/logic/auth_cubit.dart](lib/features/auth/logic/auth_cubit.dart)) управляет глобальным состоянием:
- `AuthUnknown` → инициализация
- `AuthUnauthenticated` → показать SignIn
- `AuthAuthenticated(User)` → показать главную страницу

Токены хранятся через `TokenStorage` (SharedPreferences, ключи: `auth.accessToken`, `auth.refreshToken`).

### Управление состоянием

Flutter BLoC (Cubits). `AppBlocObserver` логирует все переходы состояний в debug-режиме. Для сравнения моделей и состояний использовать `equatable`.

### Локализация

`easy_localization`, турецкий (`tr`) — fallback, английский (`en`). Файлы переводов — `assets/translations/`.

## Стандарты кода

### Именование файлов и структура

- Все файлы и директории — `lowercase_with_underscores` (snake_case).
- Организация по фиче (feature-first): `login_repository.dart`, `user_card_widget.dart`, `home_cubit.dart`.

### Виджеты

Запрещено использовать устаревшие виджеты:
- `ElevatedButton` вместо `RaisedButton`
- `TextButton` вместо `FlatButton`
- `PopScope` вместо `WillPopScope`

Использовать `const`-конструкторы везде, где возможно. Большие `build`-методы разбивать на меньшие виджеты или функции.

### Переменные и модели

- `final` для переменных, которые не изменяются.
- `equatable` для сравнения моделей и состояний BLoC.

### Хранение данных

Для локального хранения — Hive или SharedPreferences.

### Обработка ошибок

Обработка ошибок — на уровне репозитория. В UI передавать только через состояния BLoC/Cubit с понятными для пользователя сообщениями.

### Комментарии

Писать самодокументируемый код с понятными именами. Комментарии — только для сложной логики, которую нельзя упростить.


### Кнопки назад
Все кнопки назад должны быть круглыми

### Кнопки на Appbar
ВСЕ КНОПКИ на апбар имеют цвет gold gradient