# 🎓 eCampus - University Education System 🎓

Welcome to **eCampus**! 🎓

An open-source platform designed for higher education institutions. Unlike other Learning Management Systems (LMS) like Moodle, OpenEDX, etc, eCampus is built specifically for universities, offering features that cater to the needs of academic institutions. Let's dive into what makes eCampus unique! 🚀

## ✨ Features

-   **Academic subjects, not Courses**: Manage university-level subjects 📚, with academic rigor and depth.
-   **Timetables and Schedules**: Built-in support for managing semester schedules 🗓️ and real-time updates.
-   **Study Programs**: Customize and track entire study programs 🎓, including degree requirements.
-   **Student and Faculty Management**: Comprehensive student and faculty management features 👩‍🏫👨‍🎓.
-   **Grading System**: Tools for managing grades and evaluations, tailored for university standards 🏅.
-   **Exam Scheduling and Management**: Organize and automate exam schedules, and provide access to results seamlessly ✍️.

## 🛠️ Tech Stack

-   **App**: Powered by [Elixir](https://elixir-lang.org/), [Phoenix Framework](https://www.phoenixframework.org/) and [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) ⚙️
-   **Database**: Robust support with [PostgreSQL](https://www.postgresql.org/) for managing vast amounts of university data 📊

## 🚀 How to Get Started

1. **Clone the repository**

    ```bash
    git clone https://github.com/ecampus-org/ecampus-live.git
    ```

2. **Create .env.prod or .env.dev file**

```bash
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_PORT=5432
POSTGRES_HOSTNAME=localhost
PHX_SERVER=true
MIX_ENV=prod
DEFAULT_LOCALE=en
```

3. **Run the Application**

    ```bash
    mix deps.get
    mix ecto.migrate
    mix phx.server
    ```

4. **Access the platform**

    Open your browser and navigate to `http://localhost:4000` 🌐.

## 🤝 Contributing

Contributions are always welcome!

Please make sure to update tests as appropriate. ✅

## 📝 License

This project is licensed under the MIT License.
