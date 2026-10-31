# Greenstem Automotive Workshop Management Mobile Solution 🚗🔧

[![Platform](https://img.shields.io/badge/Platform-Android%20%2F%20Mobile-green.svg)](https://developer.android.com/)
[![Domain](https://img.shields.io/badge/Domain-Automotive%20Aftermarket%20WMS-blue.svg)]()
[![Design](https://img.shields.io/badge/Architecture-Clean%20Mobile%20MVP-orange.svg)]()

A mobile application solution commissioned by Greenstem Business Software Sdn Bhd to modernize client interactions for their flagship **Workshop Management System (WMS)**. 

The application replaces phone-call-based workshop coordination with a digital, transparent customer pipeline featuring real-time vehicle repair tracking, automated maintenance reminders, digital invoicing, and service appointment bookings.

---

## ⚙️ Automotive Business Problem & Solution

| Operational Bottleneck | Mobile Digital Solution |
| :--- | :--- |
| Customers forget maintenance schedules, leading to delayed repairs and engine damage. | **Automated Maintenance Push Notifications** dispatched based on vehicle mileage and scheduled intervals. |
| Lack of visibility into vehicle status requires continuous phone calls to workshop technicians. | **Live Repair Status Tracker** detailing lifecycle stages from inspection to collection. |
| Unexpected final repair bills cause disputes and delays during vehicle collection. | **Transparent E-Billing & Digital Invoicing** showing upfront labor and parts estimates. |
| Workshop managers lack direct feedback mechanisms to monitor technician repair quality. | **Integrated Post-Service Rating & Feedback Engine** tied directly to completed work orders. |

---

## 📱 Service Lifecycle Progression

The vehicle service tracking engine models actual workshop workflows through strict lifecycle statuses:

```
[Pending Booking] ➔ [In Inspection] ➔ [Parts Awaiting] ➔ [In Repair] ➔ [Ready for Collection] ➔ [Collected]
```

1. **Pending:** Customer submits desired service (Oil Change, Brake Service, Diagnostic Check) for a specific vehicle.
2. **In Inspection:** Technicians perform preliminary safety checks.
3. **Parts Awaiting:** System checks inventory; flags waiting states if parts need procurement.
4. **In Repair:** Active mechanical work underway.
5. **Ready for Collection:** System notifies customer via push notification and issues digital invoice.
6. **Collected:** Vehicle handed over; post-service feedback form unlocked.

---

## 🗄️ Database Architecture (Entity Relationships)

```
┌──────────────────┐       ┌──────────────────────┐       ┌──────────────────┐
│      User        ├───────┤       Vehicle        ├───────┤     Booking      │
│  (Customer/Staff)│ 1   * │ (Plate, Model, Type) │ 1   * │ (Date, Time, Status)
└──────────────────┘       └──────────────────────┘       └─────────┬────────┘
                                                                    │ 1
                                                                    │
                                                           ┌────────┴─────────┐
                                                           │     Payment      │
                                                           │ (Method, Amount) │
                                                           └──────────────────┘
```

---

## 🛠️ Tech Stack & Architecture

* **Mobile Architecture:** Native Android / Mobile Multi-platform (Kotlin / Flutter)
* **Backend Integration:** RESTful APIs for service status updates and invoice retrieval
* **Database & Schema:** Relational storage modeling vehicle models, service price tiers (Hatchback, Sedan, SUV, 4x4), and work orders
* **Notifications:** Push notification services for milestone alerting

---

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/Iz040622/Greenstem-Automotive-Service-App.git
   cd Greenstem-Automotive-Service-App
   ```
2. Open the project in **Android Studio** or your mobile IDE.
3. Configure your local mobile emulator (Pixel 6 / API 33+ recommended).
4. Build and deploy the application.

---

## 👨‍💻 Project Information
* Developed as an enterprise mobile solutions project for **Greenstem Business Software Sdn Bhd**.
* Lead Architect & Developer: **Isaac Lim Tian Le** ([@Iz040622](https://github.com/Iz040622))