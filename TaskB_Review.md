# Task B: Review and Raise the Bar

## A. Technical Review Framework

When joining a team where the app ships slowly, crashes on older devices, and has an oversized main bundle, I would implement the following structured technical review framework. The order is designed to identify the most critical user-facing issues first (crashes), then performance (bundle size), and finally velocity (architecture).

### 1. Stability & Crash Analysis (First Priority)
*   **What to inspect**: Crashlytics/Sentry logs, specifically focusing on Out of Memory (OOM) errors and fatal exceptions on older devices (e.g., Android 8/9, iPhone 8).
*   **What this tells me**: Identifying whether crashes are due to memory leaks (e.g., unclosed streams, holding context in long-lived objects) or unhandled exceptions in asynchronous operations.

### 2. Bundle Size Audit
*   **What to inspect**: Run `flutter build apk --analyze-size` and `flutter build ios --analyze-size`. Inspect the DevTools App Size tool.
*   **What this tells me**: It pinpoints exactly which assets (images, fonts) or dependencies are bloating the 4MB bundle. Often, unused heavy packages or uncompressed high-res images are the culprits.

### 3. Architecture and State Management Review
*   **What to inspect**: How state is passed down the widget tree. Search for `setState` in large, deeply nested widgets. Review the `build` methods for expensive synchronous operations.
*   **What this tells me**: Scattered `setState` causes unnecessary re-renders of the entire widget tree, leading to UI jank and slow performance, especially on older devices. This indicates a need for a scoped state management solution like Riverpod or Bloc.

### 4. Dependency & Package Health
*   **What to inspect**: `pubspec.yaml` and `flutter pub outdated`.
*   **What this tells me**: Identifying outdated packages that might lack performance optimizations or contain known bugs affecting older OS versions.

---

## B. Written Code Review

*(Awaiting your codebase for the concrete written code review!)*

**Findings:**
1. ...
2. ...
3. ...

---

## C. Release Process Proposal

To resolve the issue of the app shipping slowly and crashing, I propose the following release process:

### 1. Branching Strategy (Trunk-Based Development)
*   Adopt Trunk-Based Development with short-lived feature branches.
*   Require Pull Requests (PRs) for all merges to `main`.

### 2. Testing Gates (CI/CD)
*   **Unit Tests**: Must pass on every PR.
*   **Widget/Integration Tests**: Run nightly or on release branches to catch UI regressions without slowing down PR merges.
*   **Automated Bundle Size Check**: A CI step that fails the build if the new commit increases the bundle size beyond a defined threshold (e.g., +100kb).

### 3. Staged Rollout
*   **Alpha (Internal)**: Auto-deployed from `main` to team members via Firebase App Distribution.
*   **Beta (External)**: Shipped to a closed group of beta testers via Google Play Console Internal Testing / TestFlight.
*   **Production (Phased)**: Rollout in increments (10% -> 20% -> 50% -> 100%) monitoring crash rates at each step. Halt rollout if crash rate exceeds 1%.

### 4. Crash Monitoring
*   Integrate **Firebase Crashlytics** and **Sentry**.
*   Setup alerting (e.g., Slack/Teams webhook) for any new fatal crash that occurs in a newly released version.

---

## D. Performance Budget

To ensure the team maintains discipline and prevents the app from degrading again, I would enforce the following performance budget:

### The Budget
*   **Main Bundle Size**: Max **3 MB** for the core engine + logic. Assets must be loaded on demand or highly compressed.
*   **Time to Interactive (TTI)**: < **1.5 seconds** on an average mid-range device.
*   **Frame Rate**: Sustained **60 fps** (or 120 fps on supported devices) during list scrolling without dropping frames.
*   **Crash-Free Users**: Maintain **> 99.5%** crash-free users.

### Enforcement
1.  **CI/CD Integration**: Use `flutter analyze` and custom shell scripts to measure bundle size. If the size exceeds 3MB, the CI pipeline **fails**, blocking the merge.
2.  **Performance Profiling**: Mandatory performance profiling using Flutter DevTools for any PR that introduces complex UI animations or large list views.
3.  **Code Review Requirement**: Any new dependency added to `pubspec.yaml` must be explicitly justified in the PR description, including its impact on the bundle size.
