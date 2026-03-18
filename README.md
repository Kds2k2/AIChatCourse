# AI Chat Course
This repository contains the source code for **AI Chat Course**, a full-featured iOS application built with SwiftUI. The app allows users to create and interact with AI-powered avatars, engaging in dynamic conversations. It serves as a comprehensive example of modern iOS development practices, showcasing a modular architecture, multiple backend service integrations, and advanced features like in-app purchases and A/B testing.

## Key Features

-   **Dynamic AI Conversations:** Chat with a variety of avatars powered by OpenAI through Firebase Functions.
-   **Avatar Creation:** Design and create your own custom avatars, including generating a unique profile image using AI.
-   **Flexible Authentication:** Supports anonymous login, Sign in with Apple, and email/password authentication.
-   **Seamless Onboarding:** A guided, multi-step onboarding experience for new users, with A/B tested flows.
-   **Monetization Engine:** Implements in-app subscriptions using both RevenueCat and native StoreKit, with different paywall versions for A/B testing.
-   **Comprehensive Analytics:** In-depth event tracking and user property management with Firebase Analytics, Crashlytics, and Mixpanel.
-   **A/B Testing Framework:** Leverages Firebase Remote Config and a local service to test different user experiences (e.g., onboarding flow, UI layouts, paywalls).
-   **Robust Networking & Data:** Manages data through Firebase (Firestore for database, Storage for images) and a clean, protocol-oriented service layer.
-   **Rich UI Components:** A library of custom, reusable SwiftUI views, modifiers, and components, including carousels, floating text fields, and chat bubbles.
-   **Multiple Build Environments:** Configured with `Development`, `Mock`, and `Production` schemes for streamlined development, testing, and deployment.

## Technical Stack & Architecture

The project is built entirely in **Swift** using the **SwiftUI** framework and embraces modern concurrency with `async/await`.

-   **Architecture:**
    -   **Modular & Service-Oriented:** The codebase is organized into distinct services (Authentication, AI, Chat, etc.), each managed by a dedicated manager. This separation of concerns is facilitated by a central `DependencyContainer` for dependency injection.
    -   **MVVM + Interactor:** Views are powered by ViewModels (`@Observable`), which communicate with services through a central `CoreInteractor`. This facade simplifies data flow and logic access from the UI layer.
    -   **Protocol-Oriented:** Services are defined by protocols, allowing for easy mocking and testing. Mock implementations are provided for every key service.

-   **Backend & Services:**
    -   **Firebase:** Firestore, Authentication, Storage, Functions, Remote Config, Analytics, and Crashlytics.
    -   **OpenAI:** For AI-driven text and image generation, accessed via Firebase Functions.
    -   **RevenueCat:** For managing in-app subscriptions.
    -   **Mixpanel:** For advanced product analytics.

-   **Key Dependencies:**
    -   `SDWebImageSwiftUI`: Asynchronous image loading.
    -   `SignInAppleAsync`: A helper for modern Sign in with Apple implementation.
    -   `SwiftfulFirestore`: A wrapper to simplify Firestore interactions.

## Project Structure

The repository is organized to maintain a clean and scalable codebase.

```
AIChatCourse/
├── Core/             # Main feature views and view models (Explore, Chat, Profile, etc.)
├── Services/         # Backend and data services (Auth, AI, Avatar, Chat, Purchases, etc.)
│   ├── ABTests/      # A/B testing logic
│   ├── AI/           # AI generation services
│   ├── Auth/         # Authentication services
│   ├── Avatar/       # Avatar data management (remote and local)
│   ├── Chat/         # Chat and message handling
│   ├── Logs/         # Analytics and crash reporting services
│   └── Purchases/    # In-app purchase management
├── Components/       # Reusable SwiftUI components, view modifiers, and property wrappers
├── Root/             # App entry, dependency injection, and CoreInteractor
├── Configurations/   # Build schemes and test plans
├── Utilities/        # Helper classes and extensions
└── ...
```

## Getting Started

To build and run this project, you will need Xcode and the following setup steps:

1.  **Clone the Repository:**
    ```sh
    git clone https://github.com/kds2k2/aichatcourse.git
    cd aichatcourse
    ```

2.  **Open in Xcode:**
    Open the `AIChatCourse.xcodeproj` file in Xcode.

3.  **Firebase Configuration:**
    This project uses Firebase. You will need to set up your own Firebase project and add the corresponding configuration files:
    -   `AIChatCourse/GoogleServicePLists/GoogleService-Info-Dev.plist` for the Development scheme.
    -   `AIChatCourse/GoogleServicePLists/GoogleService-Info-Prod.plist` for the Production scheme.

4.  **API Keys & Secrets:**
    The project uses an `xcconfig` file to manage secrets. You will need to create a `Secrets.xcconfig` file inside the `AIChatCourse/Configurations/` directory and add your own keys:
    ```
    // AIChatCourse/Configurations/Secrets.xcconfig

    MIXPANEL_PROJECT_TOKEN = your_mixpanel_token
    REVENUECAT_API_KEY = your_production_revenuecat_key
    REVENUECAT_DEV_API_KEY = your_development_revenuecat_key
    REVENUECAT_TEST_API_KEY = your_test_revenuecat_key
    ```

5.  **Choose a Scheme:**
    Select one of the available schemes in Xcode to build and run:
    -   **AIChatCourse - Production:** Simulates the live app environment.
    -   **AIChatCourse - Development:** Uses development keys and enables developer tools.
    -   **AIChatCourse - Mock:** Runs the app with mocked data, ideal for UI development and testing without network dependencies.
