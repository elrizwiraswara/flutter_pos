# Flutter POS

A powerful and flexible Point of Sale (POS) application built with Flutter. This application is designed to cater to the needs of small to medium-sized businesses, providing features such as product management, sales tracking, and reporting.

## Features

- **Product Management**: Add, update, and delete products.
- **Sales Tracking**: Record and manage sales transactions.
- **Reporting**: Generate sales reports for better business insights.
- **User Authentication**: Secure login and user management.
- **Responsive UI**: Optimized for both mobile and tablet devices.

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (>= 2.0.0)
- [Dart](https://dart.dev/get-dart)
- Firebase account for backend services

### Installation

1. **Clone the repository:**
    ```sh
    git clone https://github.com/elrizwiraswara/flutter_pos.git
    cd flutter_pos
    ```

2. **Install dependencies:**
    ```sh
    flutter pub get
    ```

3. **Set up Firebase:**
    - Create a new project on [Firebase](https://firebase.google.com/).
    - Follow the instructions to add Firebase to your Flutter app.
    - Download the `google-services.json` file and place it in the `android/app` directory.
    - Download the `GoogleService-Info.plist` file and place it in the `ios/Runner` directory.

4. **Run the application:**
    ```sh
    flutter run
    ```

## Project Structure

lib/
│
├── main.dart # Entry point of the application
├── core/ # Core functionalities
│ ├── models/ # Data models
│ ├── providers/ # State management
│ ├── services/ # Business logic and API interactions
│ └── utils/ # Utility classes and functions
├── screens/ # UI screens
└── widgets/ # Reusable UI components

## Usage

### Adding a Product

1. **Navigate to the Product Management Screen:**

    Open the app and go to the product management section from the menu.

2. **Add a new product:**

    Fill in the product details such as name, price, and category, then click on the "Add Product" button.

### Recording a Sale

1. **Select Products:**

    Go to the sales section and select the products being sold.

2. **Complete the Sale:**

    Enter the customer details and payment method, then click on the "Complete Sale" button.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any bugs, feature requests, or improvements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
