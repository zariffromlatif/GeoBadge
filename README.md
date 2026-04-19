# 🛡️ GeoBadge

**A High-Velocity, Fraud-Proof Zero-Click Attendance Ecosystem**

Developed as a final-year Computer Science thesis project at BRAC University, GeoBadge is designed to eliminate "buddy punching" and administrative payroll lag. By combining geofencing, dynamic QR codes, and passive biometric verification, it provides a "Zero-Click" user experience that respects employee privacy while maintaining absolute data integrity.

## 🚀 Milestone 2: Core Engine Implementation

This repository represents the **Milestone 2** submission, encompassing the core frontend architecture, state management, and localized biometric logic.

### Key Features Implemented:

- **The Gatekeeper (AuthWrapper):** A persistent state management system that seamlessly routes the user between Login, Enrollment, and the Scanner based on encrypted local storage flags.
- **Professional Onboarding:** A branded Splash Screen and secure Login interface for initial HR credential verification.
- **Privacy-First Face Enrollment:** A one-time setup that captures facial landmarks and converts them into a 512-character mathematical Biometric Vector, ensuring actual photos are never saved.
- **The "Zero-Click" Scanner:** Automatically initiates the back-camera upon launch. Once a valid site QR is detected, it triggers a sub-800ms camera flip to verify the user.
- **Passive Liveness Detection:** Integrates Google ML Kit to analyze blink probability (`leftEyeOpenProbability` / `rightEyeOpenProbability`) and head orientation (`headEulerAngleY`) to prevent photo-based spoofing.
- **Sensory Feedback Loop:** Utilizes the `flutter/services` package to trigger heavy haptic impact and a smooth green UI pulse upon successful verification.
- **Local Audit Trail:** An integrated SQLite/SharedPreferences history screen logging atomic timestamps and GPS coordinates for audit-ready reporting.

## 🧮 The Mathematics of Verification

GeoBadge relies on mathematical vector comparison rather than image saving to ensure BIPA and GDPR compliance. Identity verification is calculated using the **Euclidean Distance** between the stored enrollment vector ($p$) and the live scan vector ($q$):

$$d(p, q) = \sqrt{\sum_{i=1}^{n} (q_i - p_i)^2}$$

If the distance $d$ falls below the security threshold (e.g., $d < 0.6$), the identity is cryptographically confirmed.

## 🛠️ Technology Stack

- **Framework:** Flutter (Dart)
- **Computer Vision:** Google ML Kit (Face Detection)
- **Scanning Engine:** Mobile Scanner
- **Local Storage:** SharedPreferences (Data serialization via JSON)
- **Target OS:** Android (Tested on hardware level)

## ⚙️ Installation & Running Locally

1. Clone the repository:
   ```bash
   git clone [https://github.com/zariffromlatif/GeoBadge.git](https://github.com/zariffromlatif/GeoBadge.git)
   ```
