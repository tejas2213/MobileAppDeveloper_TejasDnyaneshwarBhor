# Offline-First Order Management App

Built for Digital Heroes Training Task.

## Architecture Rationale

This application is designed with an offline-first architecture to ensure a seamless user experience regardless of network connectivity.

### 1. State Management: Riverpod
I chose **Riverpod** over raw `setState` or Provider for the following reasons:
*   **Compile-Safe**: Errors are caught at compile time, preventing runtime `ProviderNotFoundException`.
*   **Decoupled Logic**: Business logic (e.g., Syncing, Filtering) is completely decoupled from the UI widgets.
*   **Async handling**: `AsyncNotifier` makes it extremely simple to handle loading, error, and data states for async operations like fetching orders from the local database or network.

### 2. Local Database: Sqflite
I used `sqflite` to persist data locally.
*   **Offline-first capabilities**: By storing both the `Orders` and an `ActionQueue`, the app can immediately load data from the local cache on startup.
*   **Queueing**: `sqflite` provides reliable, transaction-based storage for the offline action queue.

### 3. Sync Logic & Conflict Handling
*   **Action Queue**: When an action (like updating an order status) occurs while offline, it is written to the `action_queue` table. 
*   **Optimistic Updates**: The local database and Riverpod state are updated immediately to provide instant UI feedback to the user, masking the network latency.
*   **Connectivity Listener**: The app listens to connectivity changes using `connectivity_plus`. When internet is restored, it triggers the `SyncRepository` to process the `action_queue` chronologically (FIFO).
*   **Conflict Resolution Strategy (Last Write Wins)**: In this mock implementation, we assume a "client-authoritative" or "last-write-wins" approach for simple status updates. In a production scenario with complex conflicts, a server-authoritative timestamp approach or versioning vector would be implemented.

### 4. Routing: GoRouter
*   Declarative routing that simplifies deep linking and nested navigation, which is the modern standard for Flutter apps.

## How to Run
```bash
flutter pub get
flutter run
```

## How to Test Sync Logic
```bash
flutter test
```
