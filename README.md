# JobConnect — Full-Stack Job Search & Recruitment Platform

JobConnect is a modern, production-style job search and recruitment platform. It connects **Job Seekers** with **Employers**, managed by **Administrators**. 

Built with a **Flutter** web/mobile frontend and a **Node.js/TypeScript** backend, the application uses **PostgreSQL** for core data, **Elasticsearch** for high-performance fuzzy search, and **Redis** for caching.

## 🚀 Key Features

### For Job Seekers
*   **Authentication:** Secure JWT-based registration and login.
*   **Advanced Search:** Full-text search with fuzzy matching, relevance ranking, and filters (salary, location, working model).
*   **Job Details:** View full job descriptions, company information, and apply directly.
*   **Profile Management:** Upload profile pictures and resumes (CVs). Dynamically add skills, experience, and education.
*   **Application Tracking:** Save jobs, apply to jobs, and track application statuses (Applied, Reviewing, Shortlisted, Interview, Hired, Rejected).
*   **Notifications:** Receive alerts when application statuses change.

### For Employers
*   **Company Profile:** Manage company details, upload logos, and verify company status.
*   **Job Posting:** Create, edit, and delete job postings with detailed requirements and responsibilities.
*   **Applicant Management:** Review applicants, view their uploaded CVs, and update their status pipeline.
*   **Analytics:** View basic hiring analytics (active jobs, total applicants).
*   **Notifications:** Receive alerts when new applications arrive.

### For Administrators
*   **Platform Dashboard:** View real-time statistics (users, companies, jobs, applications).
*   **User Management:** Suspend and reactivate user accounts.
*   **Company Verification:** Review and verify/reject company profiles.
*   **Moderation:** Review and resolve content reports flagged by users.
*   **Search Analytics:** View real-time search performance (cache hit rate, average latency, top searches).

## 🛠️ Tech Stack

*   **Frontend:** Flutter (Dart), StatefulWidgets, REST API integration.
*   **Backend:** Node.js, Express.js, TypeScript.
*   **Database:** PostgreSQL (Relational data).
*   **Search Engine:** Elasticsearch (Job search, fuzzy matching, ranking).
*   **Caching:** Redis (Search result caching, latency reduction).
*   **Authentication:** JWT (JSON Web Tokens), bcrypt.
*   **Testing:** Jest, Supertest (8 Integration tests).
*   **Documentation:** Swagger / OpenAPI 3.0.
*   **DevOps:** Docker, Docker Compose.

## 🏗️ Architecture

```text
Flutter Web/App
      │
      │ REST API (JSON)
      ▼
Node.js + Express (TypeScript)
      │
      ├── PostgreSQL (Source of truth)
      ├── Elasticsearch (Job Indexing & Search)
      └── Redis (Search Caching)