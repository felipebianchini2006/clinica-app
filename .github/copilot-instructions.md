# Copilot Instructions for Clinica App

## Project Overview
A Rails 8.1 clinic management system (Sistema de Gestão de Pequena Clínica) with patient records, appointment scheduling, and financial reports. Uses PostgreSQL, Hotwire (Turbo + Stimulus), Tailwind CSS, and Importmap for JavaScript.

## Tech Stack
- **Rails 8.1** with Propshaft asset pipeline
- **PostgreSQL** for all environments (development: `clinica_app_development`, test: `clinica_app_test`)
- **Hotwire**: Turbo Rails for SPA-like navigation, Stimulus for JS controllers
- **Tailwind CSS 4.x** via `tailwindcss-rails` gem
- **Pundit** for role-based authorization (admin, practitioner, receptionist)
- **Importmap** for JavaScript (no Node.js/npm required) - configure in `config/importmap.rb`
- **FullCalendar 6.x** for appointment calendar (CDN via importmap)
- **Active Storage** for medical record attachments
- **Solid Queue/Cache/Cable** for background jobs, caching, and WebSockets (database-backed)
- **Kamal** for Docker-based deployment

## Domain Models

### User (Authentication & Authorization)
```ruby
# Roles: receptionist (0), practitioner (1), admin (2)
has_secure_password
enum :role, { receptionist: 0, practitioner: 1, admin: 2 }
has_one :practitioner
```

### Patient (Paciente)
```ruby
# CPF validation, searchable by name/CPF
has_many :appointments, :medical_records, :invoices
scope :search, ->(query) { where("name ILIKE :q OR cpf ILIKE :q", q: "%#{query}%") }
```

### Practitioner (Profissional de Saúde)
```ruby
# CRM validation, linked to User account
belongs_to :user
has_many :appointments, :medical_records
```

### Appointment (Agendamento)
```ruby
# Status: scheduled, confirmed, completed, cancelled, no_show
enum :status, { scheduled: 0, confirmed: 1, completed: 2, cancelled: 3, no_show: 4 }
belongs_to :patient, :practitioner
has_one :medical_record, :invoice
scope :today, :upcoming, :by_practitioner
```

### MedicalRecord (Prontuário)
```ruby
# diagnosis, treatment, notes + file attachments
has_many_attached :attachments
belongs_to :patient, :practitioner, :appointment
```

### Invoice (Fatura)
```ruby
# Status: pending, paid, cancelled
enum :status, { pending: 0, paid: 1, cancelled: 2 }
belongs_to :patient, :appointment
scope :pending, :paid, :overdue
```

## Key Commands

### Development
```bash
bin/setup              # Full setup: bundle install, db:prepare, starts server
bin/dev                # Start development server (Puma on port 3000)
bin/rails db:seed      # Load sample data (patients, practitioners, appointments)
bin/rails dev:cache    # Toggle Action Controller caching
```

### Testing & CI
```bash
bin/ci                 # Run full CI pipeline locally (setup, lint, security, tests)
bin/rails test         # Run unit/integration tests (parallel by default)
bin/rails test:system  # Run Capybara system tests with Selenium
```

### Code Quality (run before committing)
```bash
bin/rubocop            # Ruby linting (Omakase style guide)
bin/brakeman           # Security static analysis
bin/bundler-audit      # Gem vulnerability scanning
bin/importmap audit    # JavaScript dependency audit
```

## Project Conventions

### Authentication Pattern
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_user!
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
```

### Authorization with Pundit
```ruby
# app/policies/application_policy.rb - Base policy
# Roles: admin (full access), practitioner (own records), receptionist (read + schedule)

# Usage in controllers:
authorize @patient  # Raises Pundit::NotAuthorizedError if not allowed
policy(@patient).update?  # Returns boolean
```

### Controller Pattern
```ruby
class PatientsController < ApplicationController
  before_action :set_patient, only: [:show, :edit, :update, :destroy]
  
  def index
    @patients = Patient.search(params[:query]).order(:name).page(params[:page])
  end
  
  private
  
  def set_patient
    @patient = Patient.find(params[:id])
    authorize @patient
  end
  
  def patient_params
    params.require(:patient).permit(:name, :cpf, :birth_date, :phone, :email, :address, :notes)
  end
end
```

### View Conventions
- Shared partials in `app/views/shared/` (_navbar.html.erb, _flash.html.erb)
- Tailwind CSS for all styling
- Turbo Frames for partial page updates
- Format: `<%= turbo_frame_tag "patients" do %>...<% end %>`

### Stimulus Controllers
```ruby
# config/importmap.rb
pin "@fullcalendar/core", to: "https://cdn.skypack.dev/@fullcalendar/core@6.1.17"
pin_all_from "app/javascript/controllers", under: "controllers"
```

```javascript
// app/javascript/controllers/calendar_controller.js
import { Controller } from "@hotwired/stimulus"
import { Calendar } from "@fullcalendar/core"

export default class extends Controller {
  connect() {
    this.calendar = new Calendar(this.element, { ... })
    this.calendar.render()
  }
}
```

### Routes Structure
```ruby
# config/routes.rb
Rails.application.routes.draw do
  root "dashboard#index"
  
  # Authentication
  get "login", to: "sessions#new"
  resources :sessions, only: [:create, :destroy]
  resources :registrations, only: [:new, :create]
  
  # Domain resources
  resources :patients
  resources :practitioners
  resources :appointments do
    get :calendar, on: :collection
    member do
      patch :confirm, :complete, :cancel
    end
  end
  resources :medical_records
  resources :invoices do
    member { patch :mark_paid, :mark_cancelled }
  end
  
  # Reports
  get "reports", to: "reports#index"
  get "reports/financial", to: "reports#financial"
  get "reports/appointments", to: "reports#appointments"
end
```

## Testing Patterns

### Fixtures
Located in `test/fixtures/*.yml` with realistic Brazilian data:
- Users: admin, doctors, receptionist
- Patients: with CPF, addresses
- Appointments: past/today/future with different statuses

### Model Tests
```ruby
class PatientTest < ActiveSupport::TestCase
  test "validates CPF presence" do
    patient = Patient.new(name: "Test")
    assert_not patient.valid?
    assert_includes patient.errors[:cpf], "can't be blank"
  end
end
```

## Database Architecture
Production uses multiple databases for Solid Queue/Cache/Cable:
- `clinica_app_production` - primary
- `clinica_app_production_cache` - Solid Cache
- `clinica_app_production_queue` - Solid Queue
- `clinica_app_production_cable` - Solid Cable

## Sample Login Credentials (after db:seed)
- **Admin**: admin@clinica.com / password123
- **Doctor**: carlos@clinica.com / password123
- **Receptionist**: recepcao@clinica.com / password123

## Deployment
Docker-based via Kamal (`config/deploy.yml`):
- Uses Thruster for HTTP compression/caching
- Solid Queue runs in Puma process (`SOLID_QUEUE_IN_PUMA: true`)
- Persistent storage mounted at `/rails/storage`

## CI/CD Pipeline
GitHub Actions workflow (`.github/workflows/ci.yml`) runs:
1. Security scans (Brakeman, bundler-audit, importmap audit)
2. RuboCop linting
3. Rails tests with PostgreSQL service
4. System tests with screenshot artifacts
