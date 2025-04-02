# AMRRIC Mobile Application

A Flutter application for the Australian Marine Mammal Research and Information Centre (AMRRIC).

## Setup Instructions

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Set up environment variables for Upstash Redis:
Create a `.env` file in the root directory with the following variables:
```
UPSTASH_REDIS_URL=your_redis_url
UPSTASH_REDIS_TOKEN=your_redis_token
```

3. Run the application:
```bash
flutter run
```

## Project Structure

```
lib/
├── config/           # Configuration files
│   ├── theme.dart    # App theme configuration
│   └── upstash_config.dart  # Upstash Redis configuration
├── features/         # Feature modules
├── shared/          # Shared components and utilities
└── main.dart        # Application entry point
```

## Dependencies

- flutter_riverpod: State management
- go_router: Navigation
- upstash_redis: Backend integration
- flutter_secure_storage: Secure storage
- google_fonts: Typography
- flutter_svg: SVG support
- intl: Internationalization
- logger: Logging

## Development

1. Follow the Flutter style guide
2. Use feature-first architecture
3. Implement proper error handling
4. Write unit tests for critical functionality
5. Document complex logic

## Building for Production

1. Update version in pubspec.yaml
2. Run build command:
```bash
flutter build apk --release  # For Android
flutter build ios --release  # For iOS
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request
4. Ensure CI passes
5. Get code review approval

## License

Proprietary - All rights reserved
